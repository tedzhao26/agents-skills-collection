# Graph-Loop Workflow Schema

Complete YAML schema reference for graph-loop workflows.

## Top-Level Structure

```yaml
workflow: string                    # Workflow identifier
description: string                 # Optional description
version: string                     # Optional schema version (default: "1.0")

nodes:                              # Map of node_id -> node_definition
  node_id:
    type: task|decision|parallel|join|human|checkpoint
    # ... type-specific fields

edges:                              # List of transitions
  - from: string                    # Source node (or START)
    to: string                      # Target node (or END)
    condition: string               # Optional condition (always quote)

state:                              # Initial state (optional)
  variables:
    key: value

limits:                             # Safety constraints
  max_iterations: int
  max_time_minutes: int
  max_cost_dollars: float

interrupts:                         # Human interrupt points
  - before|after: string
    condition: string
    prompt: string
    required: boolean

completion:                         # Success conditions
  - string                          # e.g., "review.clean"
```

## Node Types

### task

Execute work via AI agent or bash command.

```yaml
node_id:
  type: task
  agent: self|codex|gemini|bash    # Required
  
  # For AI agents
  prompt: string                    # Required for AI agents
  context_files: [string]           # Optional file paths
  
  # For bash agent
  command: string                   # Required for bash agent
  cwd: string                       # Optional working directory
  
  # Common fields
  outputs: [string]                 # Possible outputs (required)
  timeout_minutes: int              # Optional (default: 10)
  retry_on_failure: boolean         # Optional (default: false)
  
  # Output handlers
  on_output:
    output_name:
      set:                          # Set state variables
        var_name: value
      append:                       # Append to lists
        list_name: value
```

**Example:**

```yaml
implement:
  type: task
  agent: self
  prompt: "Implement user authentication"
  context_files:
    - src/auth.ts
    - docs/requirements.md
  outputs: [done, blocked]
  timeout_minutes: 15
  on_output:
    done:
      set:
        implementation_complete: true
```

### decision

Branch based on condition evaluation.

```yaml
node_id:
  type: decision
  condition: string                 # Expression to evaluate
  outputs: [pass, fail]             # Typically two outputs
```

**Condition Syntax:**

```yaml
# State variable comparison
condition: "state.score >= 8"
condition: "state.attempts < 3"
condition: "state.status == 'ready'"

# Node output check
condition: "outputs.review == 'clean'"

# Boolean logic
condition: "state.tests_pass && state.lint_pass"
condition: "state.p0_count == 0 || state.force_approve"
```

**Example:**

```yaml
check_quality:
  type: decision
  condition: "state.review_score >= 8 && state.test_coverage >= 80"
  outputs: [pass, fail]
```

### parallel

Fan-out to multiple branches. Parallel nodes are dispatched as background tasks using Task tool. Claude waits for all to complete at join node.

```yaml
node_id:
  type: parallel
  branches: [string]                # List of node IDs to execute
  outputs: [all_done]               # Typically single output
```

**Example:**

```yaml
research_approaches:
  type: parallel
  branches:
    - research_auth0
    - research_passport
    - research_custom
  outputs: [all_done]
```

### join

Wait for parallel branches to complete, then aggregate.

```yaml
node_id:
  type: join
  wait_for: [string]                # Node IDs to wait for (required)
  agent: self|codex|gemini          # Optional agent for aggregation
  prompt: string                    # Optional aggregation prompt
  outputs: [string]                 # Required outputs
```

**Example:**

```yaml
aggregate_research:
  type: join
  wait_for:
    - research_auth0
    - research_passport
    - research_custom
  agent: self
  prompt: |
    Review findings from all research branches.
    Recommend best approach based on: security, maintainability, cost.
  outputs: [recommendation_ready]
```

### human

Request input from user.

```yaml
node_id:
  type: human
  prompt: string                    # Question/request to user
  outputs: [string]                 # Possible user responses
  timeout_minutes: int              # Optional (default: 1440 = 24h)
  default_output: string            # Optional default if timeout
```

**Example:**

```yaml
approval_gate:
  type: human
  prompt: |
    Review the implementation and approve deployment.
    
    Files changed: (reference state.files_changed)
    Tests passed: (reference state.tests_passed)
    
    Approve? (yes/no/defer)
  outputs: [yes, no, defer]
  timeout_minutes: 60
  default_output: defer
```

### checkpoint

Save workflow state for recovery.

```yaml
node_id:
  type: checkpoint
  outputs: [done]                   # Always single output
```

**Example:**

```yaml
save_before_deploy:
  type: checkpoint
  outputs: [done]
```

## Edge Definitions

Edges define transitions between nodes.

### Basic Edge

```yaml
- from: node_a
  to: node_b
```

### Conditional Edge

**IMPORTANT:** Always quote condition strings.

```yaml
# Simple output match
- from: review
  to: fix
  condition: "P1"

# Any of multiple outputs
- from: review
  to: fix
  condition: "any(P0, P1, P2)"

# All conditions must match
- from: validation
  to: proceed
  condition: "all(tests_pass, lint_pass, security_pass)"

# State expression
- from: check
  to: retry
  condition: "state.attempts < 5"

# Complex boolean
- from: gate
  to: proceed
  condition: "(state.approved || state.emergency) && state.tests_pass"
```

### Special Nodes

- `START` - Entry point (implicit)
- `END` - Exit point (marks completion)

**Example:**

```yaml
edges:
  - from: START
    to: initialize
  
  - from: initialize
    to: process
    condition: "success"
  
  - from: process
    to: END
    condition: "done"
```

## State Management

### Initial State

```yaml
state:
  variables:
    attempt_count: 0
    max_attempts: 5
    complexity: "unknown"
    files_to_process: []
```

### State Updates

State is automatically updated with:

- `current_node` - Current node ID
- `iteration` - Total iterations
- `started_at` - ISO 8601 timestamp
- `nodes_executed` - List of executed nodes
- `outputs` - Map of node_id -> last output

Custom variables updated via `on_output` handlers:

```yaml
track_progress:
  type: task
  agent: bash
  command: "wc -l src/**/*.ts"
  outputs: [done]
  on_output:
    done:
      set:
        # Agent output assigned directly
        total_lines: output
```

## Limits Configuration

### Safety Constraints

```yaml
limits:
  max_iterations: 10                # Total node executions
  max_time_minutes: 60              # Wall clock time
  max_cost_dollars: 5.00            # Estimated API cost
  max_parallel_branches: 5          # Max parallel nodes
```

### Limit Behavior

When limit is reached:
1. Current node completes
2. State is saved
3. Execution stops with status: `LIMIT_REACHED`
4. Report shows which limit was hit

## Interrupts Configuration

### Interrupt Points

```yaml
interrupts:
  # Before node execution
  - before: deploy
    prompt: "Ready to deploy to production. Proceed?"
    required: true
  
  # After node execution
  - after: implement
    condition: "state.iteration >= 3"
    prompt: "3 iterations complete. Continue refining?"
    required: false
  
  # Conditional interrupt
  - before: expensive_operation
    condition: "state.estimated_cost > 1.00"
    prompt: "Operation will cost (reference state.estimated_cost). Proceed?"
    required: true
```

### Interrupt Response

User can respond:
- `yes` / `proceed` / `continue` - Continue execution
- `no` / `stop` / `cancel` - Stop execution
- `skip` - Skip this node (if `required: false`)

## Completion Conditions

Define success criteria:

```yaml
completion:
  # Node output match
  - review.clean
  
  # State variable check
  - "state.all_tests_pass == true"
  
  # Multiple conditions (ANY)
  - review.clean
  - user_approval.approved
  
  # Reaching END node (implicit if not specified)
```

## Full Example

```yaml
workflow: full-feature-implementation
description: Implement feature with parallel research, TDD, and quality gates
version: "1.0"

state:
  variables:
    approaches_researched: []
    test_coverage: 0
    review_score: 0

nodes:
  # Parallel research
  research:
    type: parallel
    branches: [research_approach_a, research_approach_b]
    outputs: [all_done]
  
  research_approach_a:
    type: task
    agent: gemini
    prompt: "Research approach A for authentication"
    outputs: [done]
    on_output:
      done:
        append:
          approaches_researched: "approach_a"
  
  research_approach_b:
    type: task
    agent: gemini
    prompt: "Research approach B for authentication"
    outputs: [done]
    on_output:
      done:
        append:
          approaches_researched: "approach_b"
  
  # Aggregate findings
  aggregate:
    type: join
    wait_for: [research_approach_a, research_approach_b]
    agent: self
    prompt: "Compare approaches and recommend best option"
    outputs: [recommendation_ready]
  
  # Checkpoint before implementation
  save_research:
    type: checkpoint
    outputs: [done]
  
  # Implementation
  write_tests:
    type: task
    agent: self
    prompt: "Write tests based on requirements"
    outputs: [done]
  
  implement:
    type: task
    agent: self
    prompt: "Implement feature following TDD"
    outputs: [done, blocked]
  
  run_tests:
    type: task
    agent: bash
    command: "npm test -- --coverage"
    outputs: [pass, fail]
    on_output:
      pass:
        set:
          # Parse coverage from test output
          test_coverage: output
  
  # Quality review
  review:
    type: task
    agent: codex
    prompt: |
      Review implementation and output severity:
      - P0: Critical issues
      - P1: Should fix
      - P2: Nice to have
      - clean: No issues
    outputs: [P0, P1, P2, clean]
    on_output:
      clean:
        set:
          review_score: 10
      P2:
        set:
          review_score: 8
      P1:
        set:
          review_score: 5
      P0:
        set:
          review_score: 0
  
  # User approval
  approval:
    type: human
    prompt: "Approve for deployment?"
    outputs: [yes, no]

edges:
  - from: START
    to: research
  
  - from: research
    to: aggregate
    condition: "all_done"
  
  - from: aggregate
    to: save_research
    condition: "recommendation_ready"
  
  - from: save_research
    to: write_tests
  
  - from: write_tests
    to: implement
  
  - from: implement
    to: run_tests
    condition: "done"
  
  - from: run_tests
    to: implement
    condition: "fail"
  
  - from: run_tests
    to: review
    condition: "pass"
  
  - from: review
    to: implement
    condition: "any(P0, P1)"
  
  - from: review
    to: approval
    condition: "any(P2, clean)"
  
  - from: approval
    to: implement
    condition: "no"
  
  - from: approval
    to: END
    condition: "yes"

limits:
  max_iterations: 20
  max_time_minutes: 60
  max_cost_dollars: 10.00

interrupts:
  - after: aggregate
    prompt: "Research complete. Review findings before implementing?"
    required: false
  
  - before: approval
    prompt: "Ready for final approval gate"
    required: true

completion:
  - approval.yes
```

## State File Format

Persisted to `.graph-loop/{task-name}/state.json`:

See `file-organization.md` for the complete folder structure including `workflow.yaml`, `memory.md`, and `history/`.

```json
{
  "workflow": "full-feature-implementation",
  "version": "1.0",
  "current_node": "review",
  "iteration": 8,
  "started_at": "2026-01-17T10:00:00Z",
  "last_updated": "2026-01-17T10:15:32Z",
  "status": "running",
  "nodes_executed": [
    "research",
    "research_approach_a",
    "research_approach_b",
    "aggregate",
    "save_research",
    "write_tests",
    "implement",
    "run_tests"
  ],
  "outputs": {
    "research": "all_done",
    "research_approach_a": "done",
    "research_approach_b": "done",
    "aggregate": "recommendation_ready",
    "save_research": "done",
    "write_tests": "done",
    "implement": "done",
    "run_tests": "pass"
  },
  "variables": {
    "approaches_researched": ["approach_a", "approach_b"],
    "test_coverage": 87,
    "review_score": 0
  },
  "limits": {
    "max_iterations": 20,
    "max_time_minutes": 60,
    "max_cost_dollars": 10.00
  },
  "usage": {
    "iterations_used": 8,
    "time_elapsed_minutes": 15.5,
    "estimated_cost_dollars": 0.42
  }
}
```

## Validation Rules

### Workflow Validation

- ✅ All nodes referenced in edges must exist
- ✅ All edge conditions must reference valid outputs
- ✅ `START` must have at least one outgoing edge
- ✅ At least one path must lead to `END`
- ✅ No unreachable nodes (all nodes reachable from START)
- ✅ Parallel branches must have corresponding join
- ✅ Join must wait for all parallel branches

### Node Validation

- ✅ `task` must have `agent` and either `prompt` or `command`
- ✅ `decision` must have `condition`
- ✅ `parallel` must have `branches` list
- ✅ `join` must have `wait_for` list
- ✅ `human` must have `prompt`
- ✅ All nodes must have `outputs` list

### Edge Validation

- ✅ `from` and `to` must be valid node IDs or START/END
- ✅ `condition` must reference valid output or state variable
- ✅ No duplicate edges (same from/to/condition)
- ✅ All node outputs must have corresponding edges

## Error Handling

### Execution Errors

```yaml
# Automatic retry on failure
node_with_retry:
  type: task
  agent: bash
  command: "flaky-command"
  outputs: [success, failure]
  retry_on_failure: true
  max_retries: 3

edges:
  - from: node_with_retry
    to: next_step
    condition: "success"
  
  - from: node_with_retry
    to: fallback
    condition: "failure"
```

### Timeout Handling

```yaml
# Task timeout
slow_task:
  type: task
  agent: codex
  prompt: "Complex analysis"
  outputs: [done, timeout]
  timeout_minutes: 5

edges:
  - from: slow_task
    to: next_step
    condition: "done"
  
  - from: slow_task
    to: manual_review
    condition: "timeout"
```

## See Also

- `SKILL.md` - Main skill documentation
- `example-workflows.md` - Ready-to-use templates
