---
description: Create ast-grep YAML rules for code search, linting, and automated refactoring
---

# ast-grep Rule Crafter

Create AST-based code search and rewrite rules using ast-grep YAML syntax.

## Usage

Describe what you want to find or transform:
- `/ast-grep-craft find all console.log statements`
- `/ast-grep-craft migrate useState to useSignal`
- `/ast-grep-craft lint rule for empty catch blocks`

## Quick Reference

```yaml
# Basic rule structure
id: rule-name
language: JavaScript  # TypeScript, Python, Go, Rust, etc.
rule:
  pattern: console.log($$$ARGS)
fix: logger.log($$$ARGS)
message: Use logger instead of console.log
severity: warning  # hint, info, warning, error
```

## Pattern Syntax

| Pattern | Matches |
|---------|---------|
| `$VAR` | Single node (identifier, expression) |
| `$$$ARGS` | Multiple nodes (variadic) |
| `$_` | Any single node (wildcard) |

## Running Rules

```bash
# Test single rule
sg scan -r rule.yml

# Scan with project config
sg scan  # uses sgconfig.yml
```

Now creating the ast-grep rule based on your requirements...
