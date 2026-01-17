# Graph-Loop Skill - Implementation Summary

Production-ready skill for executing multi-stage workflows with conditional loops, parallel execution, and quality gates.

## Files Created

```
~/.claude/skills/graph-loop/
├── SKILL.md                              # Main skill documentation (9.2KB)
├── README.md                             # This file
└── references/
    ├── workflow-schema.md                # Complete YAML schema (14KB)
    └── example-workflows.md              # 5 ready-to-use templates (20KB)
```

## Quick Start

```bash
# View skill
cat ~/.claude/skills/graph-loop/SKILL.md

# Use in Claude Code
/graph-loop /tmp/my-workflow.yaml
```

## What's Included

### SKILL.md (Main Documentation)

- ✅ Frontmatter with name, description, tags
- ✅ Quick Start with simple YAML example
- ✅ When to Use comparison table
- ✅ Core concepts (nodes, edges, state, limits)
- ✅ Node types reference (task, decision, parallel, join, human, checkpoint)
- ✅ Edge syntax (conditional and unconditional)
- ✅ Quality gates pattern (P0/P1/P2/clean)
- ✅ Human interrupts pattern
- ✅ Execution protocol (how Claude simulates the graph)
- ✅ Constraints (MUST/MUST NOT)
- ✅ Comparison table vs Ralph and /team

### workflow-schema.md (Complete Reference)

- ✅ Full YAML schema with all fields documented
- ✅ Type definitions for each node type
- ✅ Edge condition syntax examples
- ✅ State management fields
- ✅ Limits and safety configuration
- ✅ Interrupts configuration
- ✅ Completion conditions
- ✅ State file format (JSON)
- ✅ Validation rules
- ✅ Error handling patterns

### example-workflows.md (Ready-to-Use Templates)

1. **Simple Sequential** - Basic implement → review → done loop
2. **Iterative Self-Improvement** - Ralph-style with quality scoring (1-10)
3. **Parallel Research** - Fan-out research → aggregate → implement → review
4. **TDD with Spec Compliance** - Two-stage review (spec + quality)
5. **Multi-Environment Deployment** - Dev → staging → production pipeline

Plus 8 tips for creating custom workflows.

## Key Features

### Graph Execution Model

- Claude simulates graph execution (no external engine required)
- State persisted as JSON to `/tmp/graph-loop-state-{workflow}.json`
- Checkpoint/recovery support
- Iteration and cost limits

### Node Types

| Type | Purpose |
|------|---------|
| task | Execute work (AI agent or bash) |
| decision | Branch based on condition |
| parallel | Fan-out to multiple paths |
| join | Wait for parallel completion |
| human | Request user input |
| checkpoint | Save state for recovery |

### Quality Gates

Standard severity routing:
- **P0** (critical) → must fix, loop back
- **P1** (should fix) → loop back
- **P2** (nice to have) → user decides
- **clean** → done

### Safety Constraints

```yaml
limits:
  max_iterations: 10
  max_time_minutes: 60
  max_cost_dollars: 5.00
```

### Human Interrupts

```yaml
interrupts:
  - before: deploy
    prompt: "Ready to deploy. Proceed?"
    required: true
```

## Comparison to Other Tools

| Feature | graph-loop | Ralph | /team |
|---------|-----------|-------|-------|
| Iterative loops | ✅ Explicit graph | ✅ Autonomous | ❌ Single-shot |
| Quality gates | ✅ Built-in routing | ✅ Self-assessment | ❌ Manual |
| Parallel work | ✅ Parallel nodes | ❌ Sequential | ❌ Sequential |
| Human control | ✅ Interrupt points | ❌ Autonomous | ✅ Full control |
| Visibility | ✅ Full trace | ⚠️ Limited | ✅ Full control |
| Best for | Multi-stage workflows | Autonomous refinement | Expert collaboration |

## Example Usage

```bash
# Simple review loop
cat > /tmp/review-loop.yaml << 'YAML'
workflow: implement-review
nodes:
  implement:
    type: task
    agent: self
    prompt: "Implement the feature"
    outputs: [done]
  
  review:
    type: task
    agent: codex
    prompt: "Review and output: P0/P1/P2/clean"
    outputs: [P0, P1, P2, clean]

edges:
  - from: START
    to: implement
  - from: implement
    to: review
  - from: review
    to: implement
    condition: any(P0, P1)
  - from: review
    to: END
    condition: any(P2, clean)

limits:
  max_iterations: 5
YAML

# Execute
/graph-loop /tmp/review-loop.yaml
```

## Design Philosophy

1. **Explicit over implicit** - Graph structure is clearly defined in YAML
2. **Human control** - Interrupt points for approval gates
3. **Safety by default** - Iteration and cost limits required
4. **Visibility** - Full execution trace and state tracking
5. **Composability** - Nodes can be AI agents, bash commands, or human input

## Implementation Notes

- Works within Claude Code's constraints (no actual graph engine)
- Claude simulates graph execution through disciplined orchestration
- State is persisted for checkpoint/recovery
- All workflows are validated before execution
- Uses standard severity routing (P0/P1/P2/clean) for predictability

## Next Steps

1. Test with simple workflow
2. Try example templates from `example-workflows.md`
3. Create custom workflows for your use cases
4. Share workflows across team

## See Also

- `/team` skill - Single-shot expert delegation
- Ralph agent - Fully autonomous iterative refinement
- Task tool - Simple parallel task execution
