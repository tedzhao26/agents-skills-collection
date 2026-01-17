---
name: tldr
description: Semantic code analysis tool. Use when searching for code by behavior ("find auth logic"), analyzing call graphs, finding callers of a function, or getting LLM-optimized context. Triggers include "semantic search", "who calls this", "what affects line", "call graph", "impact analysis", "tldr".
---

# TLDR - Semantic Code Analysis (CLI)

TLDR provides semantic code understanding via CLI - search by behavior, not just text patterns.

**Usage:** `uvx --from llm-tldr tldr <command>`

## Pre-flight Check

Before using TLDR semantic features, verify the project is indexed:

```bash
# Check if daemon is running
uvx --from llm-tldr tldr daemon status

# If not indexed, warm the project first
uvx --from llm-tldr tldr warm .
```

**Auto-index trigger:** If semantic search returns empty or errors, run `tldr warm .` first.

## When to Use TLDR vs Grep

| Need | Tool | Command |
|------|------|---------|
| Exact text match | Grep | `Grep(pattern)` |
| Find by behavior | TLDR | `uvx --from llm-tldr tldr semantic "validates user input" .` |
| Who calls this? | TLDR | `uvx --from llm-tldr tldr impact functionName .` |
| What affects line N? | TLDR | `uvx --from llm-tldr tldr slice file.py func 42` |
| Regex pattern | Grep | `Grep(pattern)` |
| Call graph | TLDR | `uvx --from llm-tldr tldr calls .` |

## Quick Reference

### Semantic Search (Natural Language)

```bash
# Find code by what it does, not what it's named
tldr semantic "handle authentication" .
tldr semantic "database connection pooling" .
tldr semantic "error handling for API calls" .
```

### Impact Analysis

```bash
# Find all callers of a function (reverse call graph)
tldr impact login .
tldr impact processPayment .

# Find what tests are affected by changes
tldr change-impact src/auth.py
```

### Code Context (LLM-Optimized)

```bash
# Get 95% token savings vs raw code
tldr context main --project .
tldr context authenticate --project .
```

### Program Slicing (Debugging)

```bash
# What affects line 42? Shows only relevant lines
tldr slice src/auth.py login 42
```

### Structure Overview

```bash
# File tree
tldr tree src/

# Functions and classes
tldr structure src/ --lang python
```

## Workflow

1. **First time in project:** `uvx --from llm-tldr tldr warm .`
2. **Search by behavior:** `uvx --from llm-tldr tldr semantic "query" .`
3. **Exact matches:** Use Grep (faster for known identifiers)
4. **After major changes:** Re-warm with `uvx --from llm-tldr tldr warm .`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Empty semantic results | `uvx --from llm-tldr tldr warm .` |
| Daemon not responding | `uvx --from llm-tldr tldr daemon start` |
| Stale results | `uvx --from llm-tldr tldr warm .` |
