#!/usr/bin/env python3
"""
PostToolUse hook: Warn when code has excessive comments.

Features:
- Triggers after Write/Edit/MultiEdit operations
- Warns when comment ratio exceeds threshold (25%)
- Whitelists valid comment patterns (JSDoc, TODOs, directives)

Source: Adapted from jarrodwatts/claude-code-config
"""
import json
import sys
import re
import os

# Comment ratio threshold (0.25 = 25%)
COMMENT_THRESHOLD = 0.25

# Valid comment patterns (whitelisted)
VALID_PATTERNS = [
    r"^\s*//\s*@ts-",           # TypeScript directives
    r"^\s*//\s*eslint-",        # ESLint directives
    r"^\s*//\s*prettier-",      # Prettier directives
    r"^\s*//\s*TODO",           # TODOs
    r"^\s*//\s*FIXME",          # FIXMEs
    r"^\s*//\s*HACK",           # HACKs
    r"^\s*//\s*NOTE",           # NOTEs
    r"^\s*/\*\*",               # JSDoc start
    r"^\s*\*",                  # JSDoc continuation
    r"^\s*#\s*type:",           # Python type comments
    r"^\s*#\s*noqa",            # Python noqa
    r"^\s*#\s*pylint:",         # Pylint directives
    r"^\s*#\s*pragma:",         # Pragma directives
    r"^\s*#!",                  # Shebang
    r"^\s*#\s*-\*-",            # Encoding declarations
]

# File extensions to check
CODE_EXTENSIONS = {
    ".py", ".js", ".ts", ".tsx", ".jsx",
    ".go", ".rs", ".java", ".c", ".cpp", ".h",
    ".rb", ".php", ".swift", ".kt"
}

def is_valid_comment(line: str) -> bool:
    """Check if a comment line matches valid patterns."""
    for pattern in VALID_PATTERNS:
        if re.match(pattern, line, re.IGNORECASE):
            return True
    return False

def is_comment_line(line: str, ext: str) -> bool:
    """Check if a line is a comment based on file extension."""
    stripped = line.strip()
    if not stripped:
        return False

    # Python, Ruby, Shell
    if ext in {".py", ".rb", ".sh"}:
        return stripped.startswith("#")

    # C-style languages
    if ext in {".js", ".ts", ".tsx", ".jsx", ".go", ".rs", ".java", ".c", ".cpp", ".h", ".swift", ".kt", ".php"}:
        return stripped.startswith("//") or stripped.startswith("/*") or stripped.startswith("*")

    return False

def analyze_file(file_path: str) -> dict:
    """Analyze a file for comment ratio."""
    ext = os.path.splitext(file_path)[1].lower()

    if ext not in CODE_EXTENSIONS:
        return {"skip": True, "reason": "Not a code file"}

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except Exception as e:
        return {"skip": True, "reason": str(e)}

    total_lines = 0
    comment_lines = 0
    invalid_comment_lines = []

    for i, line in enumerate(lines, 1):
        if line.strip():  # Non-empty lines only
            total_lines += 1
            if is_comment_line(line, ext):
                comment_lines += 1
                if not is_valid_comment(line):
                    invalid_comment_lines.append((i, line.strip()[:50]))

    if total_lines == 0:
        return {"skip": True, "reason": "Empty file"}

    ratio = comment_lines / total_lines

    return {
        "skip": False,
        "total_lines": total_lines,
        "comment_lines": comment_lines,
        "ratio": ratio,
        "exceeds_threshold": ratio > COMMENT_THRESHOLD,
        "invalid_comments": invalid_comment_lines[:5]  # First 5 only
    }

def main():
    try:
        input_data = json.load(sys.stdin)

        # Get the tool that was used
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})

        # Only check after Write/Edit operations
        if tool_name not in ("Write", "Edit", "MultiEdit"):
            print(json.dumps({"result": "continue"}))
            return

        # Get file path from tool input
        file_path = tool_input.get("file_path") or tool_input.get("path")

        if not file_path or not os.path.exists(file_path):
            print(json.dumps({"result": "continue"}))
            return

        analysis = analyze_file(file_path)

        if analysis.get("skip"):
            print(json.dumps({"result": "continue"}))
            return

        if analysis["exceeds_threshold"]:
            warning = f"""
## Comment Ratio Warning

File: {file_path}
Comment ratio: {analysis['ratio']:.1%} (threshold: {COMMENT_THRESHOLD:.0%})
Lines: {analysis['comment_lines']}/{analysis['total_lines']} are comments

Consider:
- Code should be self-documenting where possible
- Comments should explain "why", not "what"
- Remove redundant comments that repeat the code
"""
            if analysis["invalid_comments"]:
                warning += "\nPotentially unnecessary comments:\n"
                for line_num, content in analysis["invalid_comments"]:
                    warning += f"  Line {line_num}: {content}...\n"

            result = {
                "hookSpecificOutput": {
                    "hookEventName": "PostToolUse",
                    "additionalContext": warning
                }
            }
        else:
            result = {}

        print(json.dumps(result))

    except Exception:
        print(json.dumps({}))

if __name__ == "__main__":
    main()
