# Claude Agent Instructions

<!-- Last updated: 2026-01-14 -->

## Quick Reference

1. Classify intent before acting (Intent Gate)
2. Evidence required before completion
3. Bash for bulk ops, agents for reasoning
4. Gemini for breadth, Codex for depth, Claude for judgment

---

## Intent Gate (EVERY message)

Before acting on ANY request, classify it first.

### Request Classification

| Type | Signal | Action |
|------|--------|--------|
| **Trivial** | Single file, obvious fix, direct answer | Just do it |
| **Explicit** | User said "implement", "build", "create" | Plan with todos, then execute |
| **Exploratory** | "How does X work?", "Find Y", "Explain" | Research only, NO implementation |
| **Open-ended** | "Improve", "Refactor", "Add feature" | Assess codebase first, propose approach |
| **Ambiguous** | Unclear scope, multiple interpretations | Ask ONE clarifying question |

### Key Rule

**NEVER START IMPLEMENTING UNLESS USER EXPLICITLY WANTS IMPLEMENTATION.**

If user asks "how does X work?" - explain, don't rewrite.
If user asks "look into Y" - investigate, don't fix.

### Ambiguity Check

| Situation | Action |
|-----------|--------|
| Single valid interpretation | Proceed |
| Multiple interpretations, similar effort | Proceed with default, note assumption |
| Multiple interpretations, 2x+ effort difference | **MUST ask** |
| Missing critical info | **MUST ask** |

---

## Completion (Evidence Required)

### Evidence Requirements

Before marking ANY task complete:

| Action | Required Evidence |
|--------|-------------------|
| File edit | `lsp_diagnostics` clean on changed files |
| Build command | Exit code 0 |
| Test run | Pass (or note pre-existing failures) |
| Delegation | Agent result received and verified |

**"No Evidence = Not Complete."**

Never say "it should work" - run the actual command and report output.

### Completion Checklist

- [ ] All planned todo items marked done
- [ ] Diagnostics clean on changed files
- [ ] Build passes (if applicable)
- [ ] User's original request fully addressed

---

## When Things Go Wrong

| Situation | Action |
|-----------|--------|
| Tool returns error | Report error, suggest alternatives |
| Evidence gathering fails | State what failed, ask user for direction |
| Conflicting instructions | Project CLAUDE.md overrides global |
| Stuck > 3 attempts | Stop, explain blockers, ask for help |

---

## Codebase Assessment (for Open-ended tasks)

Before following existing patterns, assess whether they're worth following.

### State Classification

| State | Signals | Your Behavior |
|-------|---------|---------------|
| **Disciplined** | Consistent patterns, tests exist, CI passes | Follow existing style strictly |
| **Transitional** | Mixed patterns, partial coverage | Ask which pattern to follow |
| **Legacy/Chaotic** | No consistency, outdated patterns | Propose modern approach, ask first |
| **Greenfield** | New/empty project | Apply modern best practices |

### Quick Assessment Steps

1. Check config files: linter, formatter, type config
2. Sample 2-3 similar files for consistency
3. Note project age signals (dependencies, patterns)

---

## Efficiency Guidelines

### Bulk Operations Strategy

**Prefer simple bash commands over AI agents for:**
- Appending/prepending content to multiple files
- Find and replace across files
- Adding sections to files
- Any operation that doesn't require AI reasoning

**Use Task agents only when:**
- Content requires AI reasoning (restructuring, summarizing, rewriting)
- Complex analysis is needed
- Use `model: "sonnet"` for routine bulk tasks to save cost

### Model Selection for Task Agents

| Task Type | Model |
|-----------|-------|
| Bulk formatting, simple updates | `sonnet` |
| Complex analysis, planning | `opus` (default) |
| Quick simple tasks | `haiku` |

### Plan Formatting

**Plans must be actionable, not explanatory.**

| Include | Omit |
|---------|------|
| Concrete steps (what to do) | Rationale (why it's needed) |
| File paths affected | Alternatives considered |
| Commands to run | Problem restatement |
| Success criteria | Preamble/context-setting |

**Format:** Numbered steps or bullet points. Max 10 items for most tasks. If more steps needed, group into phases.

---

## AI Agent Routing

Custom agents in `~/.claude/agents/` extend Claude with external CLI tools.

### Quick Reference

| Task Type | Agent | How to Invoke |
|-----------|-------|---------------|
| Large codebase analysis | Gemini | "use gemini agent to..." |
| Cross-file pattern detection | Gemini | "have gemini analyze..." |
| Complex bug root cause | Gemini | "trace with gemini..." |
| Code review | Codex | "use codex to review..." |
| Code prototypes & diffs | Codex | "get a diff from codex..." |
| Architecture design | Claude | (stay in session) |
| Documentation | Claude | (stay in session) |
| Final implementation | Claude | (stay in session) |

### Collaboration Workflow

1. **Gemini** for breadth - large-scale codebase understanding, mapping dependencies
2. **Codex** for depth - code prototypes (diff only), code review
3. **Claude** for judgment - orchestrate, question outputs, write final code
4. "Reading books without thinking is worse than not reading" - always validate agent outputs

### Agent Communication

**Core Principle:** Pass file paths to subagents, not content.

→ See `/agent-file-pattern` skill for patterns and examples.

---

## Tool Selection

### Code Search

| Tool | Use For |
|------|---------|
| `Grep` | Exact text/regex patterns, known identifiers |
| `tldr` | Semantic search, call graphs, impact analysis |

→ See `/tldr` skill for commands and examples.

### Browser Automation

| Need | Tool | Skill |
|------|------|-------|
| Fresh browser, scraping, testing | agent-browser | `/browser-automation` |
| Static content, docs, APIs | WebFetch | (built-in) |
