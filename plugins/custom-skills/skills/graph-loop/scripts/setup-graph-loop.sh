#!/bin/bash

# Graph-Loop Setup Script
# Initializes a workflow for execution with optional hook-driven mode
#
# Usage:
#   setup-graph-loop.sh <workflow.yaml> [options]
#   setup-graph-loop.sh --simple "<prompt>" [options]
#
# Options:
#   --task-name <name>        Name for this workflow execution
#   --mode <hook-driven|manual>  Execution mode (default: manual)
#   --max-iterations <n>      Maximum iterations (default: 10)
#   --max-time-minutes <n>    Maximum time in minutes (default: 60)
#   --completion-promise <text>  Ralph-style completion promise

set -euo pipefail

# Defaults
TASK_NAME=""
MODE="manual"
MAX_ITERATIONS=10
MAX_TIME_MINUTES=60
COMPLETION_PROMISE="null"
WORKFLOW_FILE=""
SIMPLE_PROMPT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Graph-Loop Setup - Initialize workflow execution

USAGE:
  setup-graph-loop.sh <workflow.yaml> [options]
  setup-graph-loop.sh --simple "<prompt>" [options]

ARGUMENTS:
  workflow.yaml    YAML workflow definition file

OPTIONS:
  --task-name <name>           Name for this execution (auto-generated if omitted)
  --mode <hook-driven|manual>  Execution mode (default: manual)
                               - hook-driven: Stop hook controls iteration
                               - manual: Claude controls iteration explicitly
  --max-iterations <n>         Maximum iterations (default: 10)
  --max-time-minutes <n>       Maximum time limit (default: 60)
  --completion-promise <text>  Ralph-style exit phrase (use with hook-driven mode)
  --simple "<prompt>"          Create simple implement->review loop from prompt
  -h, --help                   Show this help

EXAMPLES:
  # Start workflow from file
  setup-graph-loop.sh workflows/tdd-loop.yaml --task-name auth-feature

  # Hook-driven mode with completion promise
  setup-graph-loop.sh workflow.yaml --mode hook-driven --completion-promise "DONE"

  # Simple loop (creates implement->review workflow from prompt)
  setup-graph-loop.sh --simple "Build a REST API for todos" --max-iterations 5

MODES:
  manual (default):
    - Claude explicitly executes each node
    - Best for: parallel branches, human approval, complex workflows
    - Claude calls Task agents, evaluates conditions, updates state

  hook-driven:
    - Stop hook intercepts exit and continues to next node
    - Best for: simple implement->review loops
    - Claude just works on task; hook handles iteration

FILES CREATED:
  .graph-loop/<task-name>/
    workflow.yaml    - Workflow definition
    state.json       - Execution state (hook reads/writes)
    memory.md        - Learnings across iterations
    history/         - Iteration snapshots

MONITORING:
  # View current state
  cat .graph-loop/<task-name>/state.json | jq .

  # View memory
  cat .graph-loop/<task-name>/memory.md

  # View iteration history
  ls .graph-loop/<task-name>/history/
HELP_EOF
      exit 0
      ;;
    --task-name)
      if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
        echo "❌ Error: --task-name requires a value" >&2
        exit 1
      fi
      TASK_NAME="$2"
      shift 2
      ;;
    --mode)
      if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
        echo "❌ Error: --mode requires a value (hook-driven or manual)" >&2
        exit 1
      fi
      MODE="$2"
      if [[ "$MODE" != "hook-driven" ]] && [[ "$MODE" != "manual" ]]; then
        echo "❌ Error: --mode must be 'hook-driven' or 'manual', got: $MODE" >&2
        exit 1
      fi
      shift 2
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
        echo "❌ Error: --max-iterations requires a number" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      if ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: --max-iterations must be a positive integer, got: $MAX_ITERATIONS" >&2
        exit 1
      fi
      shift 2
      ;;
    --max-time-minutes)
      if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
        echo "❌ Error: --max-time-minutes requires a number" >&2
        exit 1
      fi
      MAX_TIME_MINUTES="$2"
      if ! [[ "$MAX_TIME_MINUTES" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: --max-time-minutes must be a positive integer, got: $MAX_TIME_MINUTES" >&2
        exit 1
      fi
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
        echo "❌ Error: --completion-promise requires a value" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --simple)
      if [[ -z "${2:-}" ]] || [[ "$2" == --* ]]; then
        echo "❌ Error: --simple requires a prompt string" >&2
        exit 1
      fi
      SIMPLE_PROMPT="$2"
      shift 2
      ;;
    *)
      # Assume it's the workflow file
      if [[ -z "$WORKFLOW_FILE" ]] && [[ -f "$1" ]]; then
        WORKFLOW_FILE="$1"
      else
        echo "❌ Error: Unknown argument or file not found: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

# Validate inputs
if [[ -z "$WORKFLOW_FILE" ]] && [[ -z "$SIMPLE_PROMPT" ]]; then
  echo "❌ Error: Must provide workflow.yaml file or --simple prompt" >&2
  echo "   Run with --help for usage" >&2
  exit 1
fi

# Generate task name if not provided
if [[ -z "$TASK_NAME" ]]; then
  if [[ -n "$WORKFLOW_FILE" ]]; then
    # Use workflow filename without extension
    TASK_NAME=$(basename "$WORKFLOW_FILE" .yaml)
    TASK_NAME=$(basename "$TASK_NAME" .yml)
  else
    # Generate from timestamp
    TASK_NAME="loop-$(date +%Y%m%d-%H%M%S)"
  fi
fi

# Sanitize task name (kebab-case)
TASK_NAME=$(echo "$TASK_NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -cd 'a-z0-9-')

# Create task directory
TASK_DIR=".graph-loop/$TASK_NAME"
mkdir -p "$TASK_DIR/history"

# Create or copy workflow file
if [[ -n "$SIMPLE_PROMPT" ]]; then
  # Create simple implement->review workflow
  cat > "$TASK_DIR/workflow.yaml" << YAML_EOF
workflow: $TASK_NAME
description: Simple implement->review loop

nodes:
  implement:
    type: task
    agent: self
    prompt: |
      $SIMPLE_PROMPT

      Work on the task. When done, indicate completion status.
      Use [OUTPUT:done] when the task is complete.
      Use [OUTPUT:needs_work] if more work is needed.
    outputs: [done, needs_work]

  review:
    type: task
    agent: self
    prompt: |
      Review the implementation critically.

      Check for:
      - Correctness (does it work?)
      - Completeness (handles edge cases?)
      - Code quality (readable, maintainable?)

      Output ONE of:
      - P0: Critical issues (security, correctness bugs)
      - P1: Should fix (bugs, style violations)
      - P2: Nice to have (minor improvements)
      - clean: No issues, ready to ship

      Be honest and critical.
    outputs: [P0, P1, P2, clean]

edges:
  - from: START
    to: implement

  - from: implement
    to: review
    condition: "done"

  - from: implement
    to: implement
    condition: "needs_work"

  - from: review
    to: implement
    condition: "any(P0, P1)"

  - from: review
    to: END
    condition: "any(P2, clean)"

limits:
  max_iterations: $MAX_ITERATIONS
  max_time_minutes: $MAX_TIME_MINUTES
YAML_EOF
else
  # Copy provided workflow
  cp "$WORKFLOW_FILE" "$TASK_DIR/workflow.yaml"
fi

# Extract workflow name from file
WORKFLOW_NAME=$(grep '^workflow:' "$TASK_DIR/workflow.yaml" | sed 's/workflow: *//' | tr -d '"' || echo "$TASK_NAME")

# Create initial state file
COMPLETION_PROMISE_JSON="null"
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  COMPLETION_PROMISE_JSON="\"$COMPLETION_PROMISE\""
fi

cat > "$TASK_DIR/state.json" << JSON_EOF
{
  "_workflow": "$WORKFLOW_NAME",
  "_task_name": "$TASK_NAME",
  "_mode": "$MODE",
  "_current_node": "START",
  "_iteration": 0,
  "_started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "_updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "_completion_promise": $COMPLETION_PROMISE_JSON,
  "_last_output": null,
  "_exit_reason": null,
  "limits": {
    "max_iterations": $MAX_ITERATIONS,
    "max_time_minutes": $MAX_TIME_MINUTES
  },
  "nodes_executed": [],
  "outputs": {},
  "variables": {}
}
JSON_EOF

# Create memory file
cat > "$TASK_DIR/memory.md" << MEMORY_EOF
# Memory: $TASK_NAME

Learnings, decisions, and gotchas discovered during workflow execution.

## Initial Context

- Workflow: $WORKFLOW_NAME
- Mode: $MODE
- Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Max iterations: $MAX_ITERATIONS
- Time limit: $MAX_TIME_MINUTES minutes

## Learnings

<!-- Add insights as they emerge -->

## Decisions Made

<!-- Record architectural/design decisions -->

## Gotchas

<!-- Note unexpected issues and workarounds -->
MEMORY_EOF

# Output setup message
echo "🔄 Graph-loop initialized!"
echo ""
echo "Task: $TASK_NAME"
echo "Workflow: $WORKFLOW_NAME"
echo "Mode: $MODE"
echo "Max iterations: $MAX_ITERATIONS"
echo "Time limit: $MAX_TIME_MINUTES minutes"
if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo "Completion promise: $COMPLETION_PROMISE"
fi
echo ""
echo "Files created:"
echo "  $TASK_DIR/workflow.yaml"
echo "  $TASK_DIR/state.json"
echo "  $TASK_DIR/memory.md"
echo ""

if [[ "$MODE" == "hook-driven" ]]; then
  echo "═══════════════════════════════════════════════════════════"
  echo "HOOK-DRIVEN MODE"
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo "The stop hook will control iteration. When you try to exit,"
  echo "the hook will evaluate edges and continue to the next node."
  echo ""
  if [[ "$COMPLETION_PROMISE" != "null" ]]; then
    echo "To complete: output <promise>$COMPLETION_PROMISE</promise>"
    echo ""
    echo "⚠️  The promise must be TRUE. Do not lie to exit!"
  fi
  echo "═══════════════════════════════════════════════════════════"
else
  echo "═══════════════════════════════════════════════════════════"
  echo "MANUAL MODE"
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo "You control the workflow execution explicitly."
  echo "Read state.json to know current node, execute the node's"
  echo "prompt, then update state.json with the output."
  echo ""
  echo "The hook will not intercept exits in manual mode."
  echo "═══════════════════════════════════════════════════════════"
fi

echo ""
echo "To monitor progress:"
echo "  cat $TASK_DIR/state.json | jq '._current_node, ._iteration'"
echo ""

# Output initial prompt for first node
# Pass path via environment to avoid shell injection issues
FIRST_PROMPT=$(WORKFLOW_PATH="$TASK_DIR/workflow.yaml" python3 << 'PYEOF'
import yaml
import os

try:
    workflow_path = os.environ.get("WORKFLOW_PATH", "workflow.yaml")
    with open(workflow_path, "r") as f:
        workflow = yaml.safe_load(f)

    # Find first node from START edge
    edges = workflow.get("edges", [])
    first_node = None
    for edge in edges:
        if edge.get("from") == "START":
            first_node = edge.get("to")
            break

    if first_node:
        node = workflow.get("nodes", {}).get(first_node, {})
        prompt = node.get("prompt", f"Begin with node: {first_node}")
        print(prompt)
    else:
        print("Begin the workflow.")

except Exception as e:
    print(f"Begin the workflow. (Error loading: {e})")
PYEOF
)

echo "═══════════════════════════════════════════════════════════"
echo "INITIAL PROMPT"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "$FIRST_PROMPT"
echo ""
echo "═══════════════════════════════════════════════════════════"
