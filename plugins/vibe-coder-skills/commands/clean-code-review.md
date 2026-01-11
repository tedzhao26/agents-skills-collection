---
description: Analyze code quality using Clean Code principles - naming, function size, DRY, YAGNI, magic numbers
---

# Clean Code Review

Run a code quality analysis based on "Clean Code" principles.

## Usage

Specify files or directories to review:
- Single file: `/clean-code-review src/utils/parser.ts`
- Directory: `/clean-code-review src/components/`
- Recent changes: `/clean-code-review` (reviews unstaged changes)

## What It Checks

| Dimension | Issues Detected |
|-----------|-----------------|
| **Naming** | Meaningless names (`data1`, `temp`), inconsistent verbs |
| **Functions** | >100 lines, >3 arguments, multiple responsibilities |
| **DRY** | Copy-pasted logic, repeated patterns |
| **YAGNI** | Unused code, over-abstraction, premature optimization |
| **Magic Numbers** | Hardcoded values without named constants |

## Output

Issues are rated by severity (High/Medium/Low) with:
- Location (file:line)
- Code snippet showing the problem
- Suggested refactoring

Now analyzing the specified code using Clean Code principles...
