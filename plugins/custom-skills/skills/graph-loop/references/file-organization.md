# Graph-Loop File Organization

## Directory Structure

```
.graph-loop/                              # Root folder (gitignored)
├── {task-name}/                          # One folder per workflow execution
│   ├── workflow.yaml                     # The workflow definition
│   ├── state.json                        # Current execution state
│   ├── memory.md                         # Persistent learnings across iterations
│   ├── plan.md                           # Optional: detailed plan if complex
│   └── history/                          # Execution history
│       ├── iteration-001.json            # State snapshot after iteration 1
│       ├── iteration-002.json            # State snapshot after iteration 2
│       └── ...
└── templates/                            # Reusable workflow templates
    ├── implement-review.yaml
    ├── tdd-loop.yaml
    └── parallel-research.yaml
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Root folder | `.graph-loop/` | Always this exact name |
| Task folder | `kebab-case` | `user-auth-feature/`, `fix-login-bug/` |
| Workflow file | `workflow.yaml` | Fixed name, one per task |
| State file | `state.json` | Fixed name, one per task |
| Memory file | `memory.md` | Fixed name, one per task |
| Plan file | `plan.md` | Optional |
| History folder | `history/` | Fixed name |
| History files | `iteration-{NNN}.json` | Zero-padded 3 digits |

## File Descriptions

### workflow.yaml

The graph definition. Created at workflow start, not modified during execution.

```yaml
workflow: add-user-auth

nodes:
  implement:
    type: task
    prompt: "Implement JWT authentication"
  review:
    type: task
    agent: codex
    prompt: "Review implementation"

edges:
  - from: START
    to: implement
  - from: implement
    to: review
  - from: review
    to: END
    condition: "clean"

limits:
  max_iterations: 5
```

### state.json

Current execution state. Updated after each node execution.

```json
{
  "_workflow": "add-user-auth",
  "_iteration": 3,
  "_current_node": "review",
  "_started_at": "2026-01-17T10:00:00Z",
  "_updated_at": "2026-01-17T10:45:00Z",
  "_history": [
    {"node": "implement", "output": "done", "timestamp": "..."},
    {"node": "review", "output": "P1", "timestamp": "..."},
    {"node": "implement", "output": "done", "timestamp": "..."}
  ],
  "implementation_path": "src/auth/jwt.ts",
  "review_result": "P1",
  "issues_found": ["Missing refresh token rotation"]
}
```

### memory.md

Persistent learnings that survive across iterations. Claude reads this at each iteration to avoid repeating mistakes.

```markdown
# Memory: add-user-auth

## Learnings

- JWT refresh tokens need 15min expiry, not 1hr (security requirement)
- Use `httpOnly` cookies for token storage, not localStorage
- The existing `AuthContext` in `src/contexts/` should be extended, not replaced

## Decisions Made

- Using RS256 algorithm (asymmetric) for JWT signing
- Storing refresh tokens in Redis with 7-day TTL

## Gotchas

- The `verifyToken` middleware already exists in `src/middleware/auth.ts`
- Tests require `TEST_JWT_SECRET` env var
```

### plan.md

Optional detailed plan for complex tasks. Created before execution if needed.

```markdown
# Plan: add-user-auth

## Overview
Add JWT-based authentication with refresh token rotation.

## Tasks

1. [ ] Create JWT utility functions
2. [ ] Add login/logout endpoints
3. [ ] Implement refresh token rotation
4. [ ] Add auth middleware
5. [ ] Write tests

## Architecture

[Details...]
```

### history/iteration-NNN.json

State snapshots for debugging and recovery. Created after each iteration.

```json
{
  "_snapshot_iteration": 2,
  "_snapshot_at": "2026-01-17T10:30:00Z",
  "_node_completed": "review",
  "_output": "P1",
  "state": {
    "implementation_path": "src/auth/jwt.ts",
    "review_result": "P1"
  }
}
```

## Workflow Lifecycle

### 1. Start New Workflow

```bash
# Claude creates task folder and files
.graph-loop/
└── add-user-auth/
    ├── workflow.yaml    # From user input or template
    ├── state.json       # Initialized with _iteration: 0
    └── memory.md        # Empty, ready for learnings
```

### 2. During Execution

```bash
# After each iteration, state.json updated
# History snapshots created
.graph-loop/
└── add-user-auth/
    ├── workflow.yaml
    ├── state.json       # _iteration: 2, _current_node: "review"
    ├── memory.md        # Updated with learnings
    └── history/
        ├── iteration-001.json
        └── iteration-002.json
```

### 3. Recovery After Interruption

```bash
# Resume from last state
/graph-loop resume .graph-loop/add-user-auth/

# Claude reads:
# 1. workflow.yaml (graph definition)
# 2. state.json (_current_node tells where to resume)
# 3. memory.md (context from previous iterations)
```

### 4. Completion

```bash
# Final state preserved for reference
.graph-loop/
└── add-user-auth/
    ├── workflow.yaml
    ├── state.json       # _current_node: "END", _exit_reason: "completed"
    ├── memory.md        # Final learnings
    └── history/
        ├── iteration-001.json
        ├── iteration-002.json
        └── iteration-003.json
```

## Templates

Store reusable workflow templates in `.graph-loop/templates/`:

```yaml
# .graph-loop/templates/implement-review.yaml
workflow: implement-review-template

nodes:
  implement:
    type: task
    prompt: |
      Implement the feature described in state.requirements.
      Follow existing patterns in the codebase.

  review:
    type: task
    agent: codex
    prompt: |
      Review the implementation.
      Output severity: P0 (critical), P1 (should fix), P2 (minor), clean

edges:
  - from: START
    to: implement
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

Use a template:

```bash
/graph-loop from-template implement-review --task fix-auth-bug --requirements "Fix the JWT expiry bug"
```

## Gitignore

Add to project `.gitignore`:

```gitignore
# Graph-loop execution state (contains runtime data)
.graph-loop/
```

Or selectively ignore:

```gitignore
# Ignore state and history, keep workflows and templates
.graph-loop/*/state.json
.graph-loop/*/history/
!.graph-loop/templates/
```

## Commands

| Command | Action |
|---------|--------|
| `/graph-loop workflow.yaml` | Start new workflow |
| `/graph-loop resume .graph-loop/{task}/` | Resume interrupted workflow |
| `/graph-loop from-template {template} --task {name}` | Start from template |
| `/graph-loop status` | Show current workflow status |
| `/graph-loop history` | Show iteration history |
| `/graph-loop clean` | Remove completed workflow folders |

## Best Practices

1. **One task per folder** - Don't reuse folders for different tasks
2. **Update memory.md** - Record learnings as they emerge, not just at the end
3. **Use templates** - Extract common patterns into reusable templates
4. **Clean up** - Remove old task folders after successful completion
5. **Commit workflows** - If workflow definitions are valuable, commit them separately from state

## Example Session

```bash
# Start a new workflow
/graph-loop
workflow: fix-auth-bug
nodes:
  investigate:
    type: task
    prompt: "Find the root cause of JWT expiry bug"
  fix:
    type: task
    prompt: "Fix the bug found in investigation"
  test:
    type: task
    prompt: "Run tests to verify fix"
edges:
  - from: START
    to: investigate
  - from: investigate
    to: fix
  - from: fix
    to: test
  - from: test
    to: END
    condition: "pass"
  - from: test
    to: fix
    condition: "fail"
limits:
  max_iterations: 5

# Claude creates:
# .graph-loop/fix-auth-bug/workflow.yaml
# .graph-loop/fix-auth-bug/state.json
# .graph-loop/fix-auth-bug/memory.md

# After interruption (Ctrl+C or timeout):
/graph-loop resume .graph-loop/fix-auth-bug/

# Claude reads state.json, continues from _current_node
```
