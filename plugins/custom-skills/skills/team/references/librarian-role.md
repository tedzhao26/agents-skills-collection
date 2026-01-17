# Librarian Role Reference

## Identity

The Librarian is the **researcher and knowledge finder**. Expert at navigating large codebases, finding patterns, and gathering relevant context.

## Default Model

**Gemini CLI** - 1M token context allows analyzing entire codebases at once.

Override to Claude when: Focused search in small codebase (<50 files).

## Core Responsibilities

1. **Codebase Exploration** - Find relevant files, patterns, implementations
2. **Pattern Discovery** - Identify existing conventions
3. **Dependency Analysis** - Map relationships between components
4. **Prior Art** - Find similar implementations to reference

## Invocation

### Full Codebase Analysis

```bash
gemini "
ROLE: Librarian (Researcher)
CODEBASE: $(pwd)
TASK: Find all authentication-related code and patterns

Report relevant files, existing patterns, and recommendations.
" --yolo
```

### Architecture Mapping

```bash
gemini "Map the architecture: list all major components and their purposes. Focus on: src/" --yolo
```

### Dependency Analysis

```bash
gemini "Map all dependencies and imports for [module]. Show the dependency graph and identify circular dependencies." --yolo
```

### Pattern Discovery

```bash
gemini "Find all uses of the Repository pattern in this codebase" --yolo
```

## Output Format

```markdown
## Research Results: [Topic]

### Relevant Files
| File | Purpose | Relevance |
|------|---------|-----------|
| path/to/file.ts | [what it does] | [why relevant] |

### Existing Patterns
#### Pattern: [Name]
- Location: `path/to/example.ts:L42`
- Description: [how it works]
- Applicability: [how to use for current task]

### Key Code References
```[language]
// From: path/to/file.ts:L42-L60
[relevant code snippet]
```

### Recommendations
1. [Based on findings]
```

## When to Invoke Librarian

- Starting work on unfamiliar codebase
- Looking for existing implementations to reference
- Understanding how similar features were built
- Mapping dependencies before refactoring

## Anti-patterns

- Don't use Librarian for implementation (use Coder)
- Don't skip Librarian when working in unfamiliar code
- Don't use for small searches (use Grep/Glob directly)
