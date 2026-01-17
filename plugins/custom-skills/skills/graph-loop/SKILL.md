---
name: graph-loop
description: Execute multi-stage workflows with conditional loops, parallel execution, and quality gates through graph-based orchestration
category: workflow
tags: [orchestration, loops, quality-gates, parallel, iterative, ralph-style]
---

# Graph-Loop Skill

Execute complex workflows as directed graphs with nodes (tasks/decisions) and edges (transitions). Supports two execution modes: **manual** (Claude controls) and **hook-driven** (Ralph-style automatic iteration).

## Quick Start

### Simplest: Use /team-loop

For most tasks needing iteration with role-based agents:

```
/team-loop "Build a REST API for todos"
```

This combines `/team`'s Oracle/Coder/Reviewer roles with iterative refinement. **No YAML needed.**

### Simple Loop (Direct)

For a basic implement→review loop without team roles:

```bash
# CLAUDE_SKILL_ROOT points to this skill's directory
# (typically ~/.claude/skills/graph-loop)

~/.claude/skills/graph-loop/scripts/setup-graph-loop.sh \
  --simple "Build a REST API for todos" \
  --mode hook-driven \
  --completion-promise "DONE" \
  --max-iterations 10
```

Then work on the task. The stop hook automatically continues to review when you try to exit, and loops back if issues are found.

### Full YAML Workflow

For complex workflows with parallel branches, human gates, or custom logic:

```yaml
workflow: implement-with-review
nodes:
  implement:
    type: task
    agent: self
    prompt: "Implement the feature"
    outputs: [done, needs_work]

  review:
    type: task
    agent: codex
    prompt: "Review implementation and output severity: P0/P1/P2/clean"
    outputs: [P0, P1, P2, clean]

edges:
  - from: START
    to: implement

  - from: implement
    to: review
    condition: "done"

  - from: review
    to: implement
    condition: "any(P0, P1)"

  - from: review
    to: END
    condition: "clean"

limits:
  max_iterations: 5
  max_time_minutes: 30
```

## Execution Modes

Graph-loop supports two execution modes:

| Mode | How It Works | Best For |
|------|--------------|----------|
| **hook-driven** | Stop hook intercepts exit, evaluates edges, continues automatically | Simple implement→review loops |
| **manual** | Claude explicitly executes nodes and updates state | Parallel branches, human gates, complex flows |

### Hook-Driven Mode (Ralph-Style)

The stop hook controls iteration automatically:

```bash
# Initialize with hook-driven mode
~/.claude/skills/graph-loop/scripts/setup-graph-loop.sh \
  workflow.yaml \
  --mode hook-driven \
  --completion-promise "TASK COMPLETE"
```

1. You work on the current node's task
2. When you try to exit, the hook intercepts
3. Hook reads your output to determine the edge condition (P0/P1/P2/clean/done)
4. Hook updates state and feeds the next node's prompt back
5. Loop continues until END or limits reached

**Completion Promise:** To exit a hook-driven loop, output:
```
<promise>TASK COMPLETE</promise>
```

The promise must be TRUE. Do not lie to exit!

### Manual Mode (Default)

Claude controls iteration explicitly:

```bash
# Initialize with manual mode
~/.claude/skills/graph-loop/scripts/setup-graph-loop.sh \
  workflow.yaml \
  --mode manual
```

1. Read `state.json` to know current node
2. Execute the node's prompt/task
3. Update `state.json` with output
4. Evaluate edges to determine next node
5. Repeat until END

Use manual mode when you need:
- Parallel branches (Task tool dispatch)
- Human approval gates
- Complex state manipulation
- Full control over execution

## When to Use Which Mode

| Scenario | Mode | Why |
|----------|------|-----|
| Simple implement→review→fix loop | hook-driven | Automatic, minimal overhead |
| Parallel research → converge | manual | Need Task tool for parallel dispatch |
| Human approval gates | manual | Need interactive prompts |
| TDD with test runner | hook-driven | Simple loop with clear outputs |
| Multi-environment deployment | manual | Human gates at each stage |
| Autonomous refinement | hook-driven | Like Ralph, but with graph structure |

## Hook-Driven Limitations

**Important:** The stop hook is a bash script that cannot invoke Claude's Task tool. This creates fundamental constraints:

| Capability | Hook-Driven | Manual Mode |
|------------|-------------|-------------|
| Sequential nodes | ✅ Works | ✅ Works |
| Parallel nodes | ❌ Cannot spawn agents | ✅ Claude dispatches |
| Join nodes | ❌ Cannot aggregate | ✅ Claude consolidates |
| Human nodes | ❌ Hook can't prompt | ✅ AskUserQuestion |
| External agents (codex/gemini) | ❌ Hook can't invoke | ✅ Task tool |

**When to use hook-driven:**
- Simple A→B→A loops (implement→review→implement)
- All nodes use `agent: self`
- No parallel branches needed

**When to use manual mode:**
- Any `parallel` or `join` nodes
- External agents (codex, gemini)
- Human approval gates
- Complex conditional branching

**Alternative:** Use `/team-loop` for role-based dispatch with iteration.

## Output Detection

In hook-driven mode, the hook detects your output using these patterns:

| Pattern | Detection |
|---------|-----------|
| `[OUTPUT:xxx]` | Explicit marker (preferred) |
| `P0`, `Critical` | Severity P0 |
| `P1`, `Should fix` | Severity P1 |
| `P2`, `Nice to have`, `Minor` | Severity P2 |
| `clean`, `No issues`, `LGTM` | Clean |
| `done`, `completed`, `success` | Done |
| `fail`, `error`, `blocked` | Failure |

**Best practice:** Use explicit output markers:
```
Implementation complete.
[OUTPUT:done]
```

## Memory Across Iterations

The `memory.md` file persists learnings across iterations:

```markdown
# Memory: my-task

## Learnings
- JWT refresh tokens need 15min expiry (security requirement)
- Use httpOnly cookies, not localStorage

## Decisions Made
- Using RS256 algorithm for JWT

## Gotchas
- Tests require TEST_JWT_SECRET env var
```

The hook automatically appends relevant learnings from your output and includes memory context in subsequent prompts.

## Core Concepts

### Nodes

| Type | Purpose | Example |
|------|---------|---------|
| `task` | Execute work (AI agent or bash) | Implement feature, run tests |
| `decision` | Branch based on condition | Check if tests pass |
| `parallel` | Fan-out to multiple paths | Research 3 approaches |
| `join` | Wait for parallel completion | Aggregate research |
| `human` | Request user input | Approval gate |
| `checkpoint` | Save state for recovery | Before expensive operation |

### Edges

```yaml
# Unconditional
- from: implement
  to: test

# Conditional
- from: review
  to: fix
  condition: "any(P0, P1)"

# State variable check
- from: check
  to: retry
  condition: "state.attempt_count < 3"
```

### Limits

```yaml
limits:
  max_iterations: 10        # Total node executions
  max_time_minutes: 60      # Wall clock time
```

## Quality Gates Pattern

Standard severity routing:

```yaml
nodes:
  implement:
    type: task
    agent: self
    prompt: "Implement feature"
    outputs: [done]

  review:
    type: task
    agent: self  # Can use self for self-review
    prompt: |
      Review critically. Output ONE of:
      - P0: Critical issues (security, correctness)
      - P1: Should fix (bugs, style violations)
      - P2: Nice to have (optimizations)
      - clean: No issues
    outputs: [P0, P1, P2, clean]

edges:
  - from: implement
    to: review

  - from: review
    to: implement
    condition: "any(P0, P1)"

  - from: review
    to: END
    condition: "any(P2, clean)"

limits:
  max_iterations: 5
```

## File Organization

```
.graph-loop/
├── {task-name}/
│   ├── workflow.yaml        # Graph definition
│   ├── state.json           # Current execution state
│   ├── memory.md            # Learnings across iterations
│   └── history/             # Iteration snapshots
│       └── iteration-001.json
└── templates/               # Reusable templates
```

## Recovery

If interrupted, resume:

```bash
/graph-loop resume .graph-loop/{task-name}/
```

Or manually:
1. Read `state.json` → `_current_node` tells where to resume
2. Read `memory.md` for context
3. Continue execution

## Comparison to Other Tools

| Feature | graph-loop | Ralph | /team |
|---------|-----------|-------|-------|
| **Iterative loops** | ✅ Both modes | ✅ Autonomous | ⚠️ Via `/team-loop` |
| **Quality gates** | ✅ Built-in | ✅ Self-assessment | ✅ P0/P1/P2 format |
| **Parallel work** | ⚠️ Manual mode only | ❌ Sequential | ✅ Fan-out/fan-in |
| **Human control** | ✅ Configurable | ❌ Autonomous | ✅ Full control |
| **Hook-driven** | ✅ Sequential only | ✅ Always | ❌ No |
| **Visibility** | ✅ Full trace | ⚠️ Limited | ✅ Full |
| **YAML workflow** | ✅ Yes | ❌ No | ❌ No |
| **Completion promise** | ✅ Optional | ✅ Core | ❌ No |
| **Role templates** | ⚠️ Via templates | ❌ No | ✅ Oracle/Coder/etc |

**Note:** For parallel agent dispatch, use `/team`. For iterative refinement with `/team`'s roles, use `/team-loop`.

## Commands

| Command | Action |
|---------|--------|
| `/graph-loop workflow.yaml` | Start workflow (manual mode) |
| `/graph-loop --simple "prompt"` | Create simple loop |
| `/graph-loop resume .graph-loop/task/` | Resume interrupted workflow |
| `/graph-loop status` | Show current state |

## Script Reference

### Setup Script

```bash
~/.claude/skills/graph-loop/scripts/setup-graph-loop.sh [options]

Options:
  --simple "<prompt>"          Create simple implement->review loop
  --task-name <name>           Name for this execution
  --mode <hook-driven|manual>  Execution mode (default: manual)
  --max-iterations <n>         Iteration limit (default: 10)
  --max-time-minutes <n>       Time limit (default: 60)
  --completion-promise <text>  Ralph-style exit phrase
```

**Note:** `CLAUDE_SKILL_ROOT` environment variable also points to the skill directory when Claude loads the skill.

## Advanced Features

### Self-Review Pattern

Like Ralph's self-assessment:

```yaml
self_review:
  type: task
  agent: self
  prompt: |
    Review your own implementation critically.
    Score from 1-10 on:
    - Correctness
    - Completeness
    - Code quality
    - Test coverage

    Output: SCORE: X/10 and specific improvements needed.
  outputs: [scored]
```

### Dynamic Routing

```yaml
edges:
  - from: analyze
    to: quick_fix
    condition: "state.complexity == 'low'"

  - from: analyze
    to: deep_refactor
    condition: "state.complexity == 'high'"
```

## Gitignore

```gitignore
# Graph-loop execution state
.graph-loop/
```

## Role Templates

Use predefined role templates from `/team` for consistent agent behavior:

```yaml
# Reference templates in your workflow
nodes:
  research:
    template: librarian
    prompt: "Find existing auth patterns"

  design:
    template: oracle
    prompt: "Design the authentication system"

  implement:
    template: coder
    prompt: "Implement based on Oracle's design"

  review:
    template: reviewer
    # Default P0/P1/P2/clean output
```

**Available templates** (see `templates/team-roles.yaml`):

| Template | Agent | Best For |
|----------|-------|----------|
| `oracle` | Opus | Architecture, design decisions |
| `librarian` | Gemini | Research, codebase exploration |
| `coder` | Codex | Implementation, refactoring |
| `reviewer` | Codex | Code review, quality gates |
| `self_reviewer` | Self | Ralph-style self-assessment |

## See Also

- `/team` - Single-shot parallel dispatch with role-based agents
- `/team-loop` - Team orchestration with iterative refinement
- Ralph plugin (`/ralph-loop`) - Pure autonomous iteration
- `references/workflow-schema.md` - Complete YAML schema
- `references/example-workflows.md` - Ready-to-use templates
- `templates/team-roles.yaml` - Role template definitions
