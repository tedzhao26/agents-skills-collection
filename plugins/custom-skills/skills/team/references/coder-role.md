# Coder Role Reference

## Identity

The Coder is the **implementation specialist**. Expert at turning specs into working code with high first-try success through thorough codebase analysis before writing.

## Default Model

**Codex CLI** - Token-efficient, thorough codebase reader, optimized for implementation.

Override to Opus when: Requirements are ambiguous, need architectural decisions, or greenfield design.

## Core Strengths

| Aspect | Coder (Codex) | Backend (Opus) |
|--------|---------------|----------------|
| Context window | 400K tokens | 200K tokens |
| Working style | Reads 15+ mins before writing | Eager to start |
| First-try success | Higher | Lower (more iterations) |
| Best for | Refactors, implementation | Design, greenfield |

## When to Use Coder (Codex)

- Spec is clear and scoped
- Change is localized or incremental
- Large-scale refactoring
- Adding features to existing codebase
- Implementation-heavy: tests, bugfixing

## When to Use Opus Instead

- Requirements are ambiguous
- Significant architecture choices needed
- New systems, greenfield designs
- Time-sensitive small changes

## Invocation

### Implementation Mode

```bash
codex -a auto-edit "
ROLE: Coder
SPEC: [From design phase]
TARGET: src/services/auth.ts, src/routes/login.ts
TESTS: npm test -- --grep 'auth'

Implement per spec. Keep changes minimal. Run tests after.
Output: diff summary + test results.
"
```

### Prototype Mode (Diff Only)

```bash
codex -a auto-edit "
ROLE: Coder (Prototype)
SPEC: [Feature specification]

Build a minimal vertical slice that proves the approach.
OK to stub integrations. Call out limitations.
Output: unified diff patches only.
"
```

### Refactoring Mode

```bash
codex -a auto-edit "
ROLE: Coder (Refactor)
TASK: Rename UserService to AuthService across codebase
CONSTRAINTS: Maintain all existing tests passing

Read the entire codebase structure first.
Identify all usages before making changes.
"
```

## Output Format

```markdown
## Implementation: [Feature]

### Approach
[Brief description]

### Changes Made
| File | Change Type | Description |
|------|-------------|-------------|
| src/auth.ts | Modified | Added JWT validation |

### Diff Summary
```diff
[Key changes]
```

### Tests Run
- [x] `npm test` - 42 passed

### Handoff Notes
**Assumptions made:**
- [Assumption 1]

**TODOs:**
- [ ] [Open item]
```

## Anti-patterns

- Don't use Coder for ambiguous requirements (use Oracle first)
- Don't skip the "read thoroughly" phase
- Don't use for greenfield design (use Opus)
- Don't expect speed - Codex is thorough, not fast
