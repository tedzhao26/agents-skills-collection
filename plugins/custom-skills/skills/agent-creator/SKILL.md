---
name: agent-creator
description: Create custom Claude Code agents (subagents). Use when creating new agents, adding agents, writing subagents, or setting up agent files. Triggers include "create agent", "new agent", "add agent", "subagent", "agent file".
---

# Agent Creator

Create custom agents in `~/.claude/agents/` (user-level) or `.claude/agents/` (project-level).

## File Structure

```
~/.claude/agents/           # User agents (all projects)
.claude/agents/             # Project agents (version controlled, higher priority)
```

## Agent Template

```yaml
---
name: agent-name
description: When and why to use this agent (guides auto-invocation)
tools: Read, Grep, Glob, Bash
model: sonnet
---

[System prompt in Markdown]
```

## YAML Frontmatter Fields

### Required

| Field | Description |
|-------|-------------|
| `name` | Unique identifier (lowercase, hyphens): `code-reviewer` |
| `description` | When to use - this guides automatic invocation |

### Optional

| Field | Options | Default |
|-------|---------|---------|
| `model` | `sonnet`, `opus`, `haiku`, `inherit` | `sonnet` |
| `tools` | Comma-separated allowlist | Inherits all |
| `disallowedTools` | Comma-separated denylist | None |
| `permissionMode` | `default`, `acceptEdits`, `bypassPermissions`, `plan` | `default` |
| `color` | `blue`, `purple`, `yellow`, `red`, `green`, `orange`, `pink`, `cyan` | None |

## Available Tools

**File Operations:**
- `Read` - Read files (text, images, PDFs, notebooks)
- `Write` - Create or overwrite files
- `Edit` - String replacements in existing files
- `Glob` - File pattern matching (`**/*.js`)
- `Grep` - Search file contents (regex)
- `NotebookEdit` - Edit Jupyter cells

**Command Execution:**
- `Bash` - Shell commands
- `BashOutput` - Background process output
- `KillShell` - Terminate processes

**Web & Research:**
- `WebSearch` - Search the web
- `WebFetch` - Fetch URL content

**Task Management:**
- `Task` - Launch sub-agents
- `TodoWrite` - Task lists

**Scoped Bash:**
```yaml
tools: Bash(git:*), Bash(npm:*), Bash(python:*)
```

## Description Best Practices

The description is the primary signal for matching user intent to agents.

**DO:**
- Use action-oriented language: "Use when analyzing code for security"
- Be explicit about purpose and trigger conditions
- Define expected inputs and outputs

**DON'T:**
- Be vague: "Helps with code"
- Use passive voice: "Can be used for..."

## System Prompt Guidelines

1. **Role Definition**: Clear identity
   ```markdown
   You are an expert security auditor with OWASP Top 10 expertise.
   ```

2. **Task Scope**: What the agent should do
   ```markdown
   When given code:
   1. Analyze for SQL injection
   2. Check auth patterns
   3. Identify data exposure
   ```

3. **Output Format**: Expected deliverables
   ```markdown
   Report format:
   - Critical issues first
   - Include file:line references
   - Provide remediation advice
   ```

4. **Constraints**: Boundaries
   ```markdown
   HITL Rule: Stop and ask before modifying production files.
   ```

5. **Definition of Done**: Completion criteria

## Example: Read-Only Researcher

```yaml
---
name: researcher
description: Research agent for exploring codebases without modification. Use for codebase analysis, finding patterns, understanding architecture.
model: sonnet
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
color: blue
---

You are a read-only research specialist.

## Capabilities
- Search for patterns across files
- Analyze code structure
- Execute read-only commands

## Constraints
- NEVER modify files
- Report findings in structured format

## Output
1. Summary of findings
2. Relevant file paths
3. Key code snippets
4. Recommendations
```

## Example: Code Reviewer

```yaml
---
name: code-reviewer
description: Expert code review for security, performance, and maintainability. Use for PR reviews, code audits, or quality checks.
model: opus
tools: Read, Grep, Glob, Bash
color: purple
---

You are an expert code reviewer.

## Review Process
1. Understand context by reading related files
2. Security: injection risks, auth issues, data exposure
3. Performance: N+1 queries, inefficient algorithms
4. Maintainability: naming, structure, documentation

## Severity Levels
- **Critical**: Security vulnerabilities, data loss
- **High**: Performance issues, logic errors
- **Medium**: Code style, missing tests
- **Low**: Suggestions

## Output Format
### Code Review Summary

#### Critical Issues
- [File:Line] Description and fix

#### Recommendations
- Suggested improvements

#### Status
- [ ] Approved / [ ] Changes Requested
```

## Tool Selection by Agent Type

| Agent Type | Recommended Tools |
|------------|-------------------|
| Researcher | Read, Grep, Glob, WebSearch |
| Reviewer | Read, Grep, Glob, Bash (for tests) |
| Implementer | Read, Write, Edit, Bash |
| Architect | Read, Grep, Glob, Write (for docs) |

## Creating an Agent

1. Choose location:
   - `~/.claude/agents/` for personal use
   - `.claude/agents/` for project-specific

2. Create file: `agent-name.md`

3. Add frontmatter with required fields

4. Write system prompt

5. Restart Claude Code to load

## References

- [Official Docs](https://code.claude.com/docs/en/sub-agents)
