---
name: ast-grep
description: AST-based code search and refactoring tool. Use when migrating code patterns, bulk refactoring, renaming across codebase, removing debug statements, or any structural code transformation. Triggers include "ast-grep", "code migration", "bulk refactor", "rename pattern", "structural search", "AST search".
---

# ast-grep - Structural Code Search & Rewrite

ast-grep searches and rewrites code by AST structure, not text. Safer and smarter than sed/grep for code transformations.

## Quick Reference

```bash
# Search pattern
ast-grep -p 'console.log($$$)' -l ts src/

# Search and replace (interactive)
ast-grep -p 'oldFunc($ARG)' -r 'newFunc($ARG)' -l ts src/ -i

# Replace all without confirmation
ast-grep -p 'oldFunc($ARG)' -r 'newFunc($ARG)' -l ts src/ -U
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `-p` | Pattern to match |
| `-r` | Replacement pattern |
| `-l` | Language (ts, tsx, js, py, go, rust, etc.) |
| `-U` | Update all (no confirmation) |
| `-i` | Interactive mode |
| `-A/-B/-C` | Context lines |
| `--json` | JSON output |

## Meta Variable Syntax

| Syntax | Matches | Example |
|--------|---------|---------|
| `$VAR` | Single node | `func($ARG)` matches `func(x)` |
| `$$$VAR` | Zero or more | `func($$$ARGS)` matches `func(a, b, c)` |
| `$_VAR` | Non-capturing | Performance optimization |
| `$$VAR` | Unnamed nodes | Captures operators, punctuation |

**Important:** Same variable name = same content. `$A == $A` matches `x == x` but NOT `x == y`.

## Common Patterns

### Property/Method Renaming
```bash
# Simple rename
ast-grep -p 's.textColor' -r 'sx.textColor' -l tsx src/ -U

# With arguments preserved
ast-grep -p 's.txt($ARG)' -r 'sx.txt($ARG)' -l tsx src/ -U

# Method chain
ast-grep -p 'obj.oldMethod($$$ARGS)' -r 'obj.newMethod($$$ARGS)' -l ts src/ -U
```

### Optional Chaining Migration
```bash
ast-grep -p '$PROP && $PROP()' -r '$PROP?.()' -l ts src/ -U
ast-grep -p '$OBJ && $OBJ.$PROP' -r '$OBJ?.$PROP' -l ts src/ -U
```

### Remove Debug Statements
```bash
ast-grep -p 'console.log($$$)' -r '' -l ts src/ -U
ast-grep -p 'debugger' -r '' -l ts src/ -U
```

### Function Signature Changes
```bash
# Add parameter
ast-grep -p 'createUser($NAME)' -r 'createUser($NAME, {})' -l ts src/ -U

# Swap parameters
ast-grep -p 'doThing($A, $B)' -r 'doThing($B, $A)' -l ts src/ -U
```

### Import Rewrites
```bash
# Rename import source
ast-grep -p "import { $$$IMPORTS } from 'old-lib'" \
  -r "import { $$$IMPORTS } from 'new-lib'" -l ts src/ -U

# Change named import
ast-grep -p "import { oldName } from '$MOD'" \
  -r "import { newName } from '$MOD'" -l ts src/ -U
```

### React Patterns
```bash
# Class to hooks (simplified)
ast-grep -p 'this.state.$PROP' -r '$PROP' -l tsx src/ -U

# PropTypes to TypeScript
ast-grep -p '$COMP.propTypes = $$$' -r '' -l tsx src/ -U
```

## Workflow: Code Migration

When user says "migrate X to Y" or "refactor pattern":

1. **Search first** - find all occurrences
   ```bash
   ast-grep -p 'pattern' -l lang src/
   ```

2. **Preview interactively** - review changes
   ```bash
   ast-grep -p 'pattern' -r 'replacement' -l lang src/ -i
   ```

3. **Apply all** - after confirming pattern works
   ```bash
   ast-grep -p 'pattern' -r 'replacement' -l lang src/ -U
   ```

4. **Verify** - run tests/build
   ```bash
   npm test  # or appropriate test command
   ```

## Language Codes

| Language | Flag |
|----------|------|
| TypeScript | `-l ts` |
| TSX | `-l tsx` |
| JavaScript | `-l js` |
| Python | `-l py` |
| Go | `-l go` |
| Rust | `-l rust` |
| Java | `-l java` |
| C/C++ | `-l c` / `-l cpp` |

## Debugging Patterns

```bash
# See how ast-grep parses your pattern
ast-grep run -p 'yourPattern' -l ts --debug-query=ast

# Test pattern on single file first
ast-grep -p 'pattern' -l ts src/specific/file.ts
```

## Common Pitfalls

| Problem | Solution |
|---------|----------|
| Pattern not matching | Check with `--debug-query=ast` |
| Shell expanding `$VAR` | Use single quotes `'$VAR'` |
| Wrong language | Verify `-l` flag (ts vs tsx) |
| Partial matches | Be more specific with context |
| Whitespace issues | ast-grep ignores trivial whitespace |

## Tips

- **Quote patterns** with single quotes to prevent shell expansion of `$`
- **Test on subset first** - use specific file path before `src/`
- **Use `-i` interactive** for unfamiliar patterns
- **Use `--debug-query`** to see AST structure when pattern fails
- **Combine with sed** for non-AST cleanup (like removing empty lines)

## When to Use ast-grep vs Other Tools

| Task | Tool |
|------|------|
| Structural code changes | **ast-grep** |
| Simple text find/replace | `sed` |
| Search only (no replace) | `grep` / `rg` |
| Single file edit | Editor / `Edit` tool |

## Resources

- Docs: https://ast-grep.github.io/
- Playground: https://ast-grep.github.io/playground.html
- Pattern examples: https://ast-grep.github.io/catalog/
