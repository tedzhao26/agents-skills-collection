#!/bin/bash

# Graph-Loop Stop Hook
# Controls workflow iteration by intercepting session exit
# and continuing to next node based on workflow graph definition
#
# Supports two modes:
#   - hook-driven: Hook controls iteration (simple workflows)
#   - manual: Claude controls iteration (complex workflows with parallel/human nodes)

set -euo pipefail

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Find active graph-loop state file
# Look in current directory first, then common locations
find_state_file() {
  local candidates=(
    ".graph-loop/*/state.json"
    "$HOME/.graph-loop/*/state.json"
  )

  for pattern in "${candidates[@]}"; do
    # Use nullglob-like behavior: check if pattern expands to real files
    local files
    files=$(ls -1 $pattern 2>/dev/null || true)

    for file in $files; do
      if [[ -f "$file" ]]; then
        # Check if this workflow is active (hook-driven mode)
        local mode
        mode=$(jq -r '._mode // "manual"' "$file" 2>/dev/null || echo "manual")
        if [[ "$mode" == "hook-driven" ]]; then
          echo "$file"
          return 0
        fi
      fi
    done
  done
  return 1
}

STATE_FILE=$(find_state_file || echo "")

# No active hook-driven workflow - allow exit
if [[ -z "$STATE_FILE" ]]; then
  exit 0
fi

WORKFLOW_DIR=$(dirname "$STATE_FILE")
WORKFLOW_FILE="$WORKFLOW_DIR/workflow.yaml"
MEMORY_FILE="$WORKFLOW_DIR/memory.md"

# Validate files exist
if [[ ! -f "$WORKFLOW_FILE" ]]; then
  echo "⚠️  Graph-loop: Workflow file not found" >&2
  echo "   Expected: $WORKFLOW_FILE" >&2
  exit 0
fi

# Parse state file
CURRENT_NODE=$(jq -r '._current_node // "START"' "$STATE_FILE")
ITERATION=$(jq -r '._iteration // 0' "$STATE_FILE")
MAX_ITERATIONS=$(jq -r '.limits.max_iterations // 0' "$STATE_FILE")
WORKFLOW_NAME=$(jq -r '._workflow // "unknown"' "$STATE_FILE")
COMPLETION_PROMISE=$(jq -r '._completion_promise // null' "$STATE_FILE")
STARTED_AT=$(jq -r '._started_at // ""' "$STATE_FILE")

# Validate numeric fields
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "⚠️  Graph-loop: State file corrupted (invalid iteration: $ITERATION)" >&2
  exit 0
fi

# Check if already at END
if [[ "$CURRENT_NODE" == "END" ]]; then
  echo "✅ Graph-loop: Workflow '$WORKFLOW_NAME' completed successfully"
  # Mark as complete, not hook-driven anymore
  jq '._mode = "completed" | ._completed_at = (now | todate) | ._exit_reason = "completed"' "$STATE_FILE" > "${STATE_FILE}.tmp"
  mv "${STATE_FILE}.tmp" "$STATE_FILE"
  exit 0
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "🛑 Graph-loop: Max iterations ($MAX_ITERATIONS) reached for '$WORKFLOW_NAME'"
  jq '._mode = "limit_reached" | ._exit_reason = "max_iterations"' "$STATE_FILE" > "${STATE_FILE}.tmp"
  mv "${STATE_FILE}.tmp" "$STATE_FILE"
  exit 0
fi

# Check time limit if set
MAX_TIME_MINUTES=$(jq -r '.limits.max_time_minutes // 0' "$STATE_FILE")
if [[ $MAX_TIME_MINUTES -gt 0 ]] && [[ -n "$STARTED_AT" ]]; then
  # Cross-platform date parsing (macOS vs Linux)
  # Note: macOS date -j ignores 'Z' suffix, so we must set TZ=UTC explicitly
  if [[ "$(uname)" == "Darwin" ]]; then
    # Remove 'Z' suffix and parse as UTC
    STARTED_AT_CLEAN="${STARTED_AT%Z}"
    START_EPOCH=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$STARTED_AT_CLEAN" "+%s" 2>/dev/null || echo 0)
  else
    START_EPOCH=$(date -d "$STARTED_AT" "+%s" 2>/dev/null || echo 0)
  fi
  NOW_EPOCH=$(date "+%s")
  ELAPSED_MINUTES=$(( (NOW_EPOCH - START_EPOCH) / 60 ))

  if [[ $ELAPSED_MINUTES -ge $MAX_TIME_MINUTES ]]; then
    echo "🛑 Graph-loop: Time limit ($MAX_TIME_MINUTES min) reached for '$WORKFLOW_NAME'"
    jq '._mode = "limit_reached" | ._exit_reason = "max_time"' "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"
    exit 0
  fi
fi

# Get transcript path and extract last assistant output
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "⚠️  Graph-loop: Transcript file not found" >&2
  exit 0
fi

# Extract last assistant message
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "⚠️  Graph-loop: No assistant messages found in transcript" >&2
  exit 0
fi

LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "⚠️  Graph-loop: Could not extract last assistant output" >&2
  exit 0
fi

# Check for completion promise (if set)
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "✅ Graph-loop: Completion promise detected - <promise>$COMPLETION_PROMISE</promise>"
    jq '._mode = "completed" | ._completed_at = (now | todate) | ._exit_reason = "completion_promise"' "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"
    exit 0
  fi
fi

# Determine output from last message for edge evaluation
# Look for standardized output markers: [OUTPUT:xxx] or severity codes P0/P1/P2/clean
DETECTED_OUTPUT=""

# Check for explicit output marker
if echo "$LAST_OUTPUT" | grep -qE '\[OUTPUT:[^\]]+\]'; then
  DETECTED_OUTPUT=$(echo "$LAST_OUTPUT" | grep -oE '\[OUTPUT:[^\]]+\]' | tail -1 | sed 's/\[OUTPUT:\(.*\)\]/\1/')
fi

# Check for severity codes (P0, P1, P2, clean)
if [[ -z "$DETECTED_OUTPUT" ]]; then
  if echo "$LAST_OUTPUT" | grep -qiE '\bP0\b|critical|Critical'; then
    DETECTED_OUTPUT="P0"
  elif echo "$LAST_OUTPUT" | grep -qiE '\bP1\b|should.?fix|Should.?fix'; then
    DETECTED_OUTPUT="P1"
  elif echo "$LAST_OUTPUT" | grep -qiE '\bP2\b|nice.?to.?have|Nice.?to.?have|minor|Minor'; then
    DETECTED_OUTPUT="P2"
  elif echo "$LAST_OUTPUT" | grep -qiE '\bclean\b|no.?issues|No.?issues|LGTM|lgtm'; then
    DETECTED_OUTPUT="clean"
  elif echo "$LAST_OUTPUT" | grep -qiE '\bdone\b|completed|success'; then
    DETECTED_OUTPUT="done"
  elif echo "$LAST_OUTPUT" | grep -qiE '\bfail|error|blocked'; then
    DETECTED_OUTPUT="failure"
  else
    DETECTED_OUTPUT="done"  # Default
  fi
fi

# Update memory.md with learnings from this iteration
if [[ -f "$MEMORY_FILE" ]]; then
  # Extract any learnings/insights from output
  LEARNINGS=$(echo "$LAST_OUTPUT" | grep -iE '(learn|insight|note|remember|gotcha|decision|chose|because)' | head -5 || true)
  if [[ -n "$LEARNINGS" ]]; then
    echo "" >> "$MEMORY_FILE"
    echo "## Iteration $ITERATION" >> "$MEMORY_FILE"
    echo "$LEARNINGS" >> "$MEMORY_FILE"
  fi
fi

# Read workflow to get current node definition and find next edge
# Using python for YAML parsing (more reliable than bash)
# Pass variables via environment to avoid shell injection issues
NEXT_NODE=$(WORKFLOW_FILE="$WORKFLOW_FILE" CURRENT_NODE="$CURRENT_NODE" DETECTED_OUTPUT="$DETECTED_OUTPUT" python3 << 'PYEOF'
import yaml
import os
import sys

try:
    workflow_file = os.environ.get("WORKFLOW_FILE", "")
    current_node = os.environ.get("CURRENT_NODE", "START")
    detected_output = os.environ.get("DETECTED_OUTPUT", "done")

    with open(workflow_file, "r") as f:
        workflow = yaml.safe_load(f)

    edges = workflow.get("edges", [])

    # Find matching edge
    for edge in edges:
        if edge.get("from") != current_node:
            continue

        condition = edge.get("condition", "")

        # No condition = unconditional match
        if not condition:
            print(edge.get("to", "END"))
            sys.exit(0)

        # Simple condition: exact match
        if condition == detected_output:
            print(edge.get("to", "END"))
            sys.exit(0)

        # any(a, b, c) condition
        if condition.startswith("any("):
            options = condition[4:-1].split(",")
            options = [o.strip().strip('"').strip("'") for o in options]
            if detected_output in options:
                print(edge.get("to", "END"))
                sys.exit(0)

        # Quoted condition
        if condition.strip('"').strip("'") == detected_output:
            print(edge.get("to", "END"))
            sys.exit(0)

    # No matching edge found - report and go to END
    print(f"WARNING: No edge matched from '{current_node}' with output '{detected_output}'", file=sys.stderr)
    print("END")

except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)
    print("END")
PYEOF
)

if [[ "$NEXT_NODE" == "END" ]] || [[ "$NEXT_NODE" == "ERROR"* ]]; then
  echo "✅ Graph-loop: Workflow '$WORKFLOW_NAME' reached END"
  jq '._mode = "completed" | ._current_node = "END" | ._completed_at = (now | todate) | ._exit_reason = "completed"' "$STATE_FILE" > "${STATE_FILE}.tmp"
  mv "${STATE_FILE}.tmp" "$STATE_FILE"
  exit 0
fi

# Get next node's prompt from workflow
# Pass variables via environment to avoid shell injection issues
NEXT_PROMPT=$(WORKFLOW_FILE="$WORKFLOW_FILE" NEXT_NODE="$NEXT_NODE" python3 << 'PYEOF'
import yaml
import os

try:
    workflow_file = os.environ.get("WORKFLOW_FILE", "")
    next_node = os.environ.get("NEXT_NODE", "")

    with open(workflow_file, "r") as f:
        workflow = yaml.safe_load(f)

    node = workflow.get("nodes", {}).get(next_node, {})
    prompt = node.get("prompt", f"Continue with the next step: {next_node}")

    # Include context files if specified
    context_files = node.get("context_files", [])
    if context_files:
        prompt += "\n\nContext files to read: " + ", ".join(context_files)

    print(prompt)

except Exception as e:
    print(f"Continue with node: {os.environ.get('NEXT_NODE', 'unknown')}")
PYEOF
)

# Update state
NEXT_ITERATION=$((ITERATION + 1))

# Create history snapshot
HISTORY_DIR="$WORKFLOW_DIR/history"
mkdir -p "$HISTORY_DIR"
HISTORY_FILE=$(printf "$HISTORY_DIR/iteration-%03d.json" "$ITERATION")

jq --arg node "$CURRENT_NODE" --arg output "$DETECTED_OUTPUT" \
  '{snapshot_iteration: ._iteration, node_completed: $node, output: $output, state: .}' \
  "$STATE_FILE" > "$HISTORY_FILE"

# Update state file
jq --arg node "$NEXT_NODE" --argjson iter "$NEXT_ITERATION" --arg output "$DETECTED_OUTPUT" \
  '._current_node = $node | ._iteration = $iter | ._last_output = $output | ._updated_at = (now | todate)' \
  "$STATE_FILE" > "${STATE_FILE}.tmp"
mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Build system message
SYSTEM_MSG="🔄 Graph-loop: $WORKFLOW_NAME | Node: $NEXT_NODE | Iteration: $NEXT_ITERATION"
if [[ $MAX_ITERATIONS -gt 0 ]]; then
  SYSTEM_MSG="$SYSTEM_MSG/$MAX_ITERATIONS"
fi
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="$SYSTEM_MSG | Promise: <promise>$COMPLETION_PROMISE</promise>"
fi

# Build full prompt with node prompt and memory context
FULL_PROMPT="$NEXT_PROMPT"

# Add memory context if exists and non-empty
if [[ -f "$MEMORY_FILE" ]] && [[ -s "$MEMORY_FILE" ]]; then
  MEMORY_CONTENT=$(cat "$MEMORY_FILE")
  FULL_PROMPT="$FULL_PROMPT

---
## Memory from previous iterations:
$MEMORY_CONTENT
---"
fi

# Output JSON to block exit and continue workflow
jq -n \
  --arg prompt "$FULL_PROMPT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
