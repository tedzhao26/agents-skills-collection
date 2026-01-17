#!/usr/bin/env python3
"""
PreToolUse hook: Block modifications to protected paths.

Blocks Write/Edit/MultiEdit operations on:
- ~/.claude/plugins/cache/ - Plugin cache (managed by plugin system)
- node_modules/, .venv/, vendor/ - Package manager directories
- .git/ - Git internals

Exit code 2 blocks the operation and shows stderr to Claude.
JSON permissionDecision: "deny" provides structured feedback.
"""
import json
import os
import sys

# Protected path patterns (expanded at runtime)
PROTECTED_PATHS = [
    "~/.claude/plugins/cache/",
    "node_modules/",
    ".venv/",
    "vendor/",
    ".git/",
]


def is_protected(file_path: str) -> tuple[bool, str]:
    """Check if file_path is under a protected directory."""
    if not file_path:
        return False, ""

    # Normalize and expand the path
    normalized = os.path.normpath(os.path.expanduser(file_path))

    for pattern in PROTECTED_PATHS:
        # Expand pattern (for ~ paths)
        expanded = os.path.normpath(os.path.expanduser(pattern))

        # Check if file is under protected path
        # Use path segment matching to avoid false positives (e.g., .git vs .github)
        pattern_segment = f"/{pattern.rstrip('/')}/"
        if normalized.startswith(expanded) or pattern_segment in normalized:
            return True, pattern

    return False, ""


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)  # Invalid JSON, allow

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Only check Write/Edit operations
    if tool_name not in ("Write", "Edit", "MultiEdit"):
        sys.exit(0)

    # Get file path from tool input
    file_path = tool_input.get("file_path") or tool_input.get("path")

    if not file_path:
        sys.exit(0)

    protected, pattern = is_protected(file_path)

    if protected:
        # Block the operation with structured feedback
        result = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": (
                    f"PROTECTED PATH: Cannot modify '{file_path}'. "
                    f"The path '{pattern}' is protected from modifications. "
                    "This protection is enforced by ~/.claude/hooks/protect-paths.py"
                ),
            }
        }
        print(json.dumps(result))
        sys.exit(0)

    # Allow the operation
    sys.exit(0)


if __name__ == "__main__":
    main()
