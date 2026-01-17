---
name: agent-file-pattern
description: Agent communication patterns for passing data between agents efficiently. Use when orchestrating multi-agent workflows, passing data to subagents, or designing agents that accept file inputs. Triggers include "pass data to agent", "agent input output", "agent communication", "file path pattern", "parallel agents".
---

# Agent File-Path Pattern

Pass file paths to subagents, not content. This reduces context usage by 90%+ and enables parallel execution.

## Core Principle

```
INSTEAD OF: agent "Do X with this data: $(cat large-file.txt)"
DO THIS:    agent "SPEC: /tmp/spec.txt INPUT: file.txt OUTPUT: /tmp/result.txt"
```

## Why This Matters

| Benefit | Explanation |
|---------|-------------|
| **Context savings** | 90%+ reduction in prompt size |
| **Parallelism** | Multiple agents run simultaneously without interference |
| **Chainability** | Agent A's OUTPUT becomes Agent B's INPUT |
| **Debuggability** | Inspect /tmp files to see what agents exchanged |

---

## Standard Invocation Pattern

```bash
# 1. Create spec file
cat > /tmp/agent-spec.txt <<EOF
[Task description]
[Requirements]
EOF

# 2. Invoke agent with paths
agent-cli "
ROLE: [Agent role]
SPEC: /tmp/agent-spec.txt
INPUT: [path/to/input]
OUTPUT: /tmp/agent-output.txt

Read SPEC and INPUT, write results to OUTPUT.
"

# 3. Read results
cat /tmp/agent-output.txt
```

---

## File Naming Convention

```
/tmp/<context>-<agent>-<type>.<ext>

Examples:
/tmp/team-librarian-findings.json
/tmp/review-codex-report.md
/tmp/impl-approach-1.diff
```

## File Types by Purpose

| Purpose | Format | Example |
|---------|--------|---------|
| Specs/Requirements | Plain text | `/tmp/task-spec.txt` |
| Research findings | JSON | `/tmp/research-findings.json` |
| Designs/Plans | Markdown | `/tmp/design.md` |
| Code/Diffs | Text/Diff | `/tmp/implementation.diff` |

---

## Parallel Execution

Launch multiple agents with unique output paths:

```bash
# Each agent gets unique output path
agent-1 --spec=/tmp/spec.txt --output=/tmp/result-1.txt &
agent-2 --spec=/tmp/spec.txt --output=/tmp/result-2.txt &
agent-3 --spec=/tmp/spec.txt --output=/tmp/result-3.txt &
wait

# No interference, all results preserved
cat /tmp/result-*.txt
```

---

## Agent Design Requirements

When creating agents (see `/agent-creator`), design them to:

1. **Accept file path parameters** (SPEC, INPUT, OUTPUT)
2. **Read input files themselves** (don't expect embedded content)
3. **Write output to specified path**
4. **Return the output file path**

### Example Agent Prompt Structure

```markdown
You receive tasks via file paths:
- SPEC: Task specification file
- INPUT: Input data file(s)
- OUTPUT: Where to write results

Read the files, complete the task, write to OUTPUT.
```

---

## Common Patterns

### Chained Agents (Pipeline)

```bash
# Research → Design → Implement
agent research "INPUT: codebase OUTPUT: /tmp/findings.json"
agent design "INPUT: /tmp/findings.json OUTPUT: /tmp/design.md"
agent implement "INPUT: /tmp/design.md OUTPUT: /tmp/changes.diff"
```

### Fan-out/Fan-in

```bash
# Fan-out: parallel research
agent search-api "OUTPUT: /tmp/api-findings.md" &
agent search-db "OUTPUT: /tmp/db-findings.md" &
agent search-ui "OUTPUT: /tmp/ui-findings.md" &
wait

# Fan-in: consolidate
agent summarize "
INPUT: /tmp/api-findings.md /tmp/db-findings.md /tmp/ui-findings.md
OUTPUT: /tmp/consolidated.md
"
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Agent can't find file | Use absolute paths (`/tmp/...`) |
| Output overwritten | Use unique names per agent |
| Large output truncated | Use file output, not stdout |
| Context too large | Split into smaller specs |

---

## See Also

- `/agent-creator` - Creating new agents
- `/team` - Multi-agent orchestration
