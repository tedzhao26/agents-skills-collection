---
paths: "**/*.py"
---

## Python Rules (3.12+)

### Type Hints
- Use modern syntax: `list[str]` not `List[str]`, `str | None` not `Optional[str]`
- Add type hints to all function signatures
- Use `typing.TypeAlias` for complex types
- Prefer `unknown` patterns when type is truly unknown

### Imports
- Group: stdlib → third-party → local (blank line between groups)
- Use absolute imports over relative
- No circular imports
- Sort alphabetically within groups

### Async/Await
- Use `async def` for I/O-bound operations
- Never use `time.sleep()` in async code—use `await asyncio.sleep()`
- Always `await` coroutines (watch for "coroutine was never awaited" warnings)
- Use `asyncio.gather()` for concurrent execution
- Use `asyncio.Semaphore` for rate limiting
- Keep references to tasks to prevent garbage collection

### Error Handling
- Never use bare `except:` — always specify exception type
- Use `except Exception as e:` at minimum, prefer specific exceptions
- Log or re-raise, never silently swallow
- Use context managers (`with`) for resource cleanup

### Testing (pytest)
- Name test files `test_*.py` or `*_test.py`
- Use fixtures for setup/teardown
- Mock external dependencies (APIs, databases)
- Test both happy path and error cases
- Use `pytest.mark.parametrize` for multiple inputs

### Linting & Formatting
- Use **ruff** for linting and formatting (replaces black, isort, flake8)
- Use **mypy** for type checking
- Run `ruff check . --fix && ruff format .` before commit
- Start mypy with basic config, gradually increase strictness

### pyproject.toml Config
```toml
[tool.ruff]
line-length = 88
indent-width = 4

[tool.ruff.lint]
select = ["E4", "E7", "E9", "F"]

[tool.mypy]
python_version = "3.12"
warn_return_any = true
disallow_untyped_defs = true
```

### Hard Blocks (NEVER)
- `# type: ignore` without explanation
- Bare `except:` clauses
- `time.sleep()` in async functions
- Mutable default arguments (`def foo(items=[])`—use `None` instead)
