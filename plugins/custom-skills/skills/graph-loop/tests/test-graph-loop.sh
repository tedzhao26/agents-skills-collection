#!/bin/bash

# Graph-Loop Test Suite
# Tests for hooks and setup scripts
#
# Usage: ./test-graph-loop.sh [--verbose]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEST_TMP="/tmp/graph-loop-tests-$$"
VERBOSE="${1:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
SKIPPED=0

# Setup test environment
setup() {
  mkdir -p "$TEST_TMP"
  cd "$TEST_TMP"
}

# Cleanup test environment
cleanup() {
  cd /
  rm -rf "$TEST_TMP"
}

# Test helper: run test and report result
run_test() {
  local name="$1"
  local cmd="$2"

  if [[ "$VERBOSE" == "--verbose" ]]; then
    echo -e "${YELLOW}Running: $name${NC}"
  fi

  if eval "$cmd" > "$TEST_TMP/test_output.txt" 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: $name"
    ((PASSED++))
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}: $name"
    if [[ "$VERBOSE" == "--verbose" ]]; then
      cat "$TEST_TMP/test_output.txt"
    fi
    ((FAILED++))
    return 1
  fi
}

# Test helper: expect command to fail
expect_fail() {
  local name="$1"
  local cmd="$2"

  if eval "$cmd" > "$TEST_TMP/test_output.txt" 2>&1; then
    echo -e "${RED}✗ FAIL${NC}: $name (expected failure, got success)"
    ((FAILED++))
    return 1
  else
    echo -e "${GREEN}✓ PASS${NC}: $name"
    ((PASSED++))
    return 0
  fi
}

# Test helper: check if output contains string
output_contains() {
  grep -q "$1" "$TEST_TMP/test_output.txt"
}

#######################################
# SETUP SCRIPT TESTS
#######################################

test_setup_help() {
  run_test "setup-graph-loop.sh --help shows usage" \
    "'$SKILL_DIR/scripts/setup-graph-loop.sh' --help"
}

test_setup_requires_input() {
  expect_fail "setup-graph-loop.sh fails without input" \
    "'$SKILL_DIR/scripts/setup-graph-loop.sh' 2>&1"
}

test_setup_simple_creates_files() {
  cd "$TEST_TMP"
  run_test "setup --simple creates workflow files" \
    "'$SKILL_DIR/scripts/setup-graph-loop.sh' --simple 'Test task' --task-name test-simple --mode manual && \
     [[ -f '.graph-loop/test-simple/workflow.yaml' ]] && \
     [[ -f '.graph-loop/test-simple/state.json' ]] && \
     [[ -f '.graph-loop/test-simple/memory.md' ]]"
}

test_setup_state_has_correct_mode() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name mode-test --mode hook-driven > /dev/null 2>&1
  run_test "state.json has correct mode" \
    "[[ \$(jq -r '._mode' '.graph-loop/mode-test/state.json') == 'hook-driven' ]]"
}

test_setup_validates_mode() {
  cd "$TEST_TMP"
  expect_fail "setup rejects invalid mode" \
    "'$SKILL_DIR/scripts/setup-graph-loop.sh' --simple 'Test' --mode invalid 2>&1"
}

test_setup_validates_max_iterations() {
  cd "$TEST_TMP"
  expect_fail "setup rejects non-numeric max-iterations" \
    "'$SKILL_DIR/scripts/setup-graph-loop.sh' --simple 'Test' --max-iterations abc 2>&1"
}

test_setup_missing_option_value() {
  cd "$TEST_TMP"
  expect_fail "setup rejects --task-name without value" \
    "'$SKILL_DIR/scripts/setup-graph-loop.sh' --simple 'Test' --task-name 2>&1"
}

test_setup_completion_promise_in_state() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name promise-test --completion-promise 'DONE' > /dev/null 2>&1
  run_test "completion promise stored in state" \
    "[[ \$(jq -r '._completion_promise' '.graph-loop/promise-test/state.json') == 'DONE' ]]"
}

test_setup_workflow_yaml_valid() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test task' --task-name yaml-test > /dev/null 2>&1
  run_test "generated workflow.yaml is valid YAML" \
    "python3 -c \"import yaml; yaml.safe_load(open('.graph-loop/yaml-test/workflow.yaml'))\""
}

test_setup_sanitizes_task_name() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name 'My Task Name!' > /dev/null 2>&1
  run_test "task name is sanitized to kebab-case" \
    "[[ -d '.graph-loop/my-task-name' ]]"
}

#######################################
# HOOK SCRIPT TESTS
#######################################

test_hook_syntax_valid() {
  run_test "graph-loop-hook.sh has valid bash syntax" \
    "bash -n '$SKILL_DIR/hooks/graph-loop-hook.sh'"
}

test_hook_exits_cleanly_no_state() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  # Hook should exit 0 when no state file exists
  run_test "hook exits cleanly when no state file" \
    "echo '{}' | '$SKILL_DIR/hooks/graph-loop-hook.sh'"
}

test_hook_ignores_manual_mode() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name manual-test --mode manual > /dev/null 2>&1
  # Hook should exit 0 and not block when mode is manual
  run_test "hook ignores manual mode workflows" \
    "echo '{\"transcript_path\": \"/dev/null\"}' | '$SKILL_DIR/hooks/graph-loop-hook.sh'"
}

#######################################
# HOOKS.JSON TESTS
#######################################

test_hooks_json_valid() {
  run_test "hooks.json is valid JSON" \
    "jq . '$SKILL_DIR/hooks/hooks.json' > /dev/null"
}

test_hooks_json_has_stop_hook() {
  run_test "hooks.json defines Stop hook" \
    "jq -e '.hooks.Stop' '$SKILL_DIR/hooks/hooks.json' > /dev/null"
}

#######################################
# WORKFLOW SCHEMA TESTS
#######################################

test_workflow_has_required_fields() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name schema-test > /dev/null 2>&1
  run_test "workflow has 'workflow' field" \
    "grep -q '^workflow:' '.graph-loop/schema-test/workflow.yaml'"
}

test_workflow_has_nodes() {
  cd "$TEST_TMP"
  run_test "workflow has 'nodes' section" \
    "grep -q '^nodes:' '.graph-loop/schema-test/workflow.yaml'"
}

test_workflow_has_edges() {
  cd "$TEST_TMP"
  run_test "workflow has 'edges' section" \
    "grep -q '^edges:' '.graph-loop/schema-test/workflow.yaml'"
}

test_workflow_has_limits() {
  cd "$TEST_TMP"
  run_test "workflow has 'limits' section" \
    "grep -q '^limits:' '.graph-loop/schema-test/workflow.yaml'"
}

#######################################
# STATE FILE TESTS
#######################################

test_state_has_required_fields() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name state-test > /dev/null 2>&1
  run_test "state.json has _workflow field" \
    "jq -e '._workflow' '.graph-loop/state-test/state.json' > /dev/null"
}

test_state_starts_at_start() {
  cd "$TEST_TMP"
  run_test "state starts at START node" \
    "[[ \$(jq -r '._current_node' '.graph-loop/state-test/state.json') == 'START' ]]"
}

test_state_iteration_starts_at_zero() {
  cd "$TEST_TMP"
  run_test "state iteration starts at 0" \
    "[[ \$(jq -r '._iteration' '.graph-loop/state-test/state.json') == '0' ]]"
}

test_state_has_timestamps() {
  cd "$TEST_TMP"
  run_test "state has _started_at timestamp" \
    "jq -e '._started_at' '.graph-loop/state-test/state.json' > /dev/null"
}

#######################################
# EDGE CASE TESTS
#######################################

test_special_chars_in_prompt() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  # Test that special YAML characters don't break the workflow
  run_test "handles special characters in prompt" \
    "'$SKILL_DIR/scripts/setup-graph-loop.sh' --simple 'Test: with colon and #hash' --task-name special-chars && \
     python3 -c \"import yaml; yaml.safe_load(open('.graph-loop/special-chars/workflow.yaml'))\""
}

test_empty_task_name_generates_default() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' > /dev/null 2>&1
  run_test "empty task name generates default" \
    "ls .graph-loop/ | grep -q 'loop-'"
}

test_history_dir_created() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name history-test > /dev/null 2>&1
  run_test "history directory is created" \
    "[[ -d '.graph-loop/history-test/history' ]]"
}

#######################################
# CROSS-PLATFORM TESTS
#######################################

test_date_format_iso8601() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name date-test > /dev/null 2>&1
  # Check that date is in ISO 8601 format
  run_test "timestamps are ISO 8601 format" \
    "jq -r '._started_at' '.graph-loop/date-test/state.json' | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'"
}

#######################################
# HOOK OUTPUT DETECTION TESTS
#######################################

# Helper: create mock transcript with assistant message
create_mock_transcript() {
  local output="$1"
  local transcript_file="$TEST_TMP/mock_transcript.jsonl"
  cat > "$transcript_file" << EOF
{"role":"user","message":{"content":[{"type":"text","text":"test"}]}}
{"role":"assistant","message":{"content":[{"type":"text","text":"$output"}]}}
EOF
  echo "$transcript_file"
}

# Helper: create hook-driven workflow state
create_hook_state() {
  local node="$1"
  local iteration="${2:-1}"
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test task' --task-name hook-test --mode hook-driven > /dev/null 2>&1
  # Update state to specified node and reset timestamp to now
  local now_ts
  now_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq --arg node "$node" --argjson iter "$iteration" --arg ts "$now_ts" \
    '._current_node = $node | ._iteration = $iter | ._started_at = $ts' \
    .graph-loop/hook-test/state.json > .graph-loop/hook-test/state.json.tmp
  mv .graph-loop/hook-test/state.json.tmp .graph-loop/hook-test/state.json
}

test_output_detection_p0() {
  cd "$TEST_TMP"
  create_hook_state "review" 1
  local transcript
  transcript=$(create_mock_transcript "Review result: P0 - Critical security issue found")
  # The hook should detect P0 and try to continue to implement
  run_test "hook detects P0 severity from output" \
    "echo '{\"transcript_path\": \"$transcript\"}' | '$SKILL_DIR/hooks/graph-loop-hook.sh' | jq -e '.decision == \"block\"'"
}

test_output_detection_p1() {
  cd "$TEST_TMP"
  create_hook_state "review" 1
  local transcript
  transcript=$(create_mock_transcript "Found issues: P1 - Should fix these bugs")
  run_test "hook detects P1 severity from output" \
    "echo '{\"transcript_path\": \"$transcript\"}' | '$SKILL_DIR/hooks/graph-loop-hook.sh' | jq -e '.decision == \"block\"'"
}

test_output_detection_clean() {
  cd "$TEST_TMP"
  create_hook_state "review" 1
  local transcript
  transcript=$(create_mock_transcript "Code review: clean - No issues found, LGTM!")
  # Clean should transition to END, so hook should allow exit
  local result
  result=$(echo "{\"transcript_path\": \"$transcript\"}" | "$SKILL_DIR/hooks/graph-loop-hook.sh" 2>&1) || true
  # When transitioning to END, hook exits 0 without JSON output
  run_test "hook allows exit on clean review" \
    "[[ -z '$result' ]] || echo '$result' | grep -q 'completed'"
}

test_output_detection_explicit_marker() {
  cd "$TEST_TMP"
  create_hook_state "implement" 1
  local transcript
  transcript=$(create_mock_transcript "Work complete. [OUTPUT:done]")
  run_test "hook detects explicit [OUTPUT:xxx] marker" \
    "echo '{\"transcript_path\": \"$transcript\"}' | '$SKILL_DIR/hooks/graph-loop-hook.sh' | jq -e '.decision == \"block\"'"
}

test_output_detection_done_keyword() {
  cd "$TEST_TMP"
  create_hook_state "implement" 1
  local transcript
  transcript=$(create_mock_transcript "Task completed successfully, everything is done.")
  run_test "hook detects 'done' keyword from output" \
    "echo '{\"transcript_path\": \"$transcript\"}' | '$SKILL_DIR/hooks/graph-loop-hook.sh' | jq -e '.decision == \"block\"'"
}

#######################################
# HOOK MAX ITERATIONS TESTS
#######################################

test_max_iterations_enforced() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name iter-test --mode hook-driven --max-iterations 3 > /dev/null 2>&1
  # Set iteration to max and reset timestamp
  local now_ts
  now_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq --arg ts "$now_ts" '._iteration = 3 | ._started_at = $ts' .graph-loop/iter-test/state.json > .graph-loop/iter-test/state.json.tmp
  mv .graph-loop/iter-test/state.json.tmp .graph-loop/iter-test/state.json
  local transcript
  transcript=$(create_mock_transcript "Still working...")
  # Hook should exit and not block when at max iterations
  local result
  result=$(echo "{\"transcript_path\": \"$transcript\"}" | "$SKILL_DIR/hooks/graph-loop-hook.sh" 2>&1) || true
  run_test "hook enforces max iterations limit" \
    "echo '$result' | grep -q 'Max iterations'"
}

test_state_updated_on_limit() {
  cd "$TEST_TMP"
  # Check state was updated after max iterations
  run_test "state shows limit_reached after max iterations" \
    "[[ \$(jq -r '._mode' '.graph-loop/iter-test/state.json') == 'limit_reached' ]]"
}

#######################################
# HOOK COMPLETION PROMISE TESTS
#######################################

test_completion_promise_detected() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name promise-test --mode hook-driven --completion-promise 'TASK DONE' > /dev/null 2>&1
  local now_ts
  now_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq --arg ts "$now_ts" '._iteration = 1 | ._started_at = $ts' .graph-loop/promise-test/state.json > .graph-loop/promise-test/state.json.tmp
  mv .graph-loop/promise-test/state.json.tmp .graph-loop/promise-test/state.json
  local transcript
  transcript=$(create_mock_transcript "All work complete. <promise>TASK DONE</promise>")
  local result
  result=$(echo "{\"transcript_path\": \"$transcript\"}" | "$SKILL_DIR/hooks/graph-loop-hook.sh" 2>&1) || true
  run_test "hook detects completion promise in output" \
    "echo '$result' | grep -q 'Completion promise detected'"
}

test_completion_promise_must_match() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name promise-match --mode hook-driven --completion-promise 'EXACT MATCH' > /dev/null 2>&1
  local now_ts
  now_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq --arg ts "$now_ts" '._iteration = 1 | ._started_at = $ts' .graph-loop/promise-match/state.json > .graph-loop/promise-match/state.json.tmp
  mv .graph-loop/promise-match/state.json.tmp .graph-loop/promise-match/state.json
  local transcript
  transcript=$(create_mock_transcript "Done. <promise>WRONG TEXT</promise>")
  # Should block because promise doesn't match
  run_test "hook ignores non-matching completion promise" \
    "echo '{\"transcript_path\": \"$transcript\"}' | '$SKILL_DIR/hooks/graph-loop-hook.sh' | jq -e '.decision == \"block\"'"
}

#######################################
# HOOK STATE TRANSITION TESTS
#######################################

test_state_node_updated() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name transition-test --mode hook-driven > /dev/null 2>&1
  local now_ts
  now_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  jq --arg ts "$now_ts" '._current_node = "implement" | ._iteration = 1 | ._started_at = $ts' .graph-loop/transition-test/state.json > .graph-loop/transition-test/state.json.tmp
  mv .graph-loop/transition-test/state.json.tmp .graph-loop/transition-test/state.json
  local transcript
  transcript=$(create_mock_transcript "Implementation done. [OUTPUT:done]")
  echo "{\"transcript_path\": \"$transcript\"}" | "$SKILL_DIR/hooks/graph-loop-hook.sh" > /dev/null 2>&1 || true
  run_test "state node is updated after transition" \
    "[[ \$(jq -r '._current_node' '.graph-loop/transition-test/state.json') == 'review' ]]"
}

test_state_iteration_incremented() {
  cd "$TEST_TMP"
  run_test "state iteration is incremented" \
    "[[ \$(jq -r '._iteration' '.graph-loop/transition-test/state.json') == '2' ]]"
}

test_history_snapshot_created() {
  cd "$TEST_TMP"
  run_test "history snapshot is created after transition" \
    "[[ -f '.graph-loop/transition-test/history/iteration-001.json' ]]"
}

#######################################
# HOOK EDGE EVALUATION TESTS
#######################################

test_edge_any_condition() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name edge-test --mode hook-driven > /dev/null 2>&1
  # Set to review node - P0 should match any(P0, P1) and go to implement
  jq '._current_node = "review" | ._iteration = 1' .graph-loop/edge-test/state.json > .graph-loop/edge-test/state.json.tmp
  mv .graph-loop/edge-test/state.json.tmp .graph-loop/edge-test/state.json
  local transcript
  transcript=$(create_mock_transcript "Critical issue: P0")
  echo "{\"transcript_path\": \"$transcript\"}" | "$SKILL_DIR/hooks/graph-loop-hook.sh" > /dev/null 2>&1 || true
  run_test "edge evaluates any() condition correctly" \
    "[[ \$(jq -r '._current_node' '.graph-loop/edge-test/state.json') == 'implement' ]]"
}

test_edge_to_end() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name end-test --mode hook-driven > /dev/null 2>&1
  # Set to review node - clean should match any(P2, clean) and go to END
  jq '._current_node = "review" | ._iteration = 1' .graph-loop/end-test/state.json > .graph-loop/end-test/state.json.tmp
  mv .graph-loop/end-test/state.json.tmp .graph-loop/end-test/state.json
  local transcript
  transcript=$(create_mock_transcript "Review complete: clean, no issues found")
  echo "{\"transcript_path\": \"$transcript\"}" | "$SKILL_DIR/hooks/graph-loop-hook.sh" > /dev/null 2>&1 || true
  run_test "edge transitions to END on clean review" \
    "[[ \$(jq -r '._current_node' '.graph-loop/end-test/state.json') == 'END' ]]"
}

#######################################
# HOOK MEMORY TESTS
#######################################

test_memory_file_exists() {
  cd "$TEST_TMP"
  rm -rf .graph-loop
  "$SKILL_DIR/scripts/setup-graph-loop.sh" --simple 'Test' --task-name memory-test --mode hook-driven > /dev/null 2>&1
  run_test "memory.md file is created" \
    "[[ -f '.graph-loop/memory-test/memory.md' ]]"
}

test_memory_has_initial_context() {
  cd "$TEST_TMP"
  run_test "memory.md contains initial context" \
    "grep -q 'Initial Context' '.graph-loop/memory-test/memory.md'"
}

#######################################
# MAIN
#######################################

main() {
  echo "========================================"
  echo "Graph-Loop Skill Test Suite"
  echo "========================================"
  echo ""

  trap cleanup EXIT
  setup

  # Setup script tests
  echo "--- Setup Script Tests ---"
  test_setup_help
  test_setup_requires_input
  test_setup_simple_creates_files
  test_setup_state_has_correct_mode
  test_setup_validates_mode
  test_setup_validates_max_iterations
  test_setup_missing_option_value
  test_setup_completion_promise_in_state
  test_setup_workflow_yaml_valid
  test_setup_sanitizes_task_name

  # Hook script tests
  echo ""
  echo "--- Hook Script Tests ---"
  test_hook_syntax_valid
  test_hook_exits_cleanly_no_state
  test_hook_ignores_manual_mode

  # Hooks.json tests
  echo ""
  echo "--- Hooks Config Tests ---"
  test_hooks_json_valid
  test_hooks_json_has_stop_hook

  # Workflow schema tests
  echo ""
  echo "--- Workflow Schema Tests ---"
  test_workflow_has_required_fields
  test_workflow_has_nodes
  test_workflow_has_edges
  test_workflow_has_limits

  # State file tests
  echo ""
  echo "--- State File Tests ---"
  test_state_has_required_fields
  test_state_starts_at_start
  test_state_iteration_starts_at_zero
  test_state_has_timestamps

  # Edge case tests
  echo ""
  echo "--- Edge Case Tests ---"
  test_special_chars_in_prompt
  test_empty_task_name_generates_default
  test_history_dir_created

  # Cross-platform tests
  echo ""
  echo "--- Cross-Platform Tests ---"
  test_date_format_iso8601

  # Hook output detection tests (NEW)
  echo ""
  echo "--- Hook Output Detection Tests ---"
  test_output_detection_p0
  test_output_detection_p1
  test_output_detection_clean
  test_output_detection_explicit_marker
  test_output_detection_done_keyword

  # Hook max iterations tests (NEW)
  echo ""
  echo "--- Hook Max Iterations Tests ---"
  test_max_iterations_enforced
  test_state_updated_on_limit

  # Hook completion promise tests (NEW)
  echo ""
  echo "--- Hook Completion Promise Tests ---"
  test_completion_promise_detected
  test_completion_promise_must_match

  # Hook state transition tests (NEW)
  echo ""
  echo "--- Hook State Transition Tests ---"
  test_state_node_updated
  test_state_iteration_incremented
  test_history_snapshot_created

  # Hook edge evaluation tests (NEW)
  echo ""
  echo "--- Hook Edge Evaluation Tests ---"
  test_edge_any_condition
  test_edge_to_end

  # Hook memory tests (NEW)
  echo ""
  echo "--- Hook Memory Tests ---"
  test_memory_file_exists
  test_memory_has_initial_context

  # Summary
  echo ""
  echo "========================================"
  echo "Test Summary"
  echo "========================================"
  echo -e "${GREEN}Passed: $PASSED${NC}"
  echo -e "${RED}Failed: $FAILED${NC}"
  echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
  echo ""

  if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}TESTS FAILED${NC}"
    exit 1
  else
    echo -e "${GREEN}ALL TESTS PASSED${NC}"
    exit 0
  fi
}

main "$@"
