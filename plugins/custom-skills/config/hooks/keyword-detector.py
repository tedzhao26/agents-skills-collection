#!/usr/bin/env python3
"""
UserPromptSubmit hook: Inject modes based on keywords in prompts.

Modes:
- ultrawork/ulw: Maximum parallelism, exhaustive planning
- search/find/locate: Thorough search with multiple angles
- analyze/investigate/debug: Evidence-based debugging
- think deeply/hard/carefully: Extended reasoning

Source: Adapted from jarrodwatts/claude-code-config
"""
import json
import sys
import re

MODES = {
    r"\b(ultrawork|ulw)\b": {
        "name": "ULTRAWORK",
        "injection": """
## ULTRAWORK MODE ACTIVATED

You are now in maximum performance mode:
- Use MAXIMUM parallelism (4-6 concurrent tool calls)
- Exhaustive planning required - create detailed todos
- Run ALL validations before marking complete
- No shortcuts - be thorough and comprehensive
- Fire explore + librarian agents in background immediately
- Evidence required for every claim
"""
    },
    r"\b(search|find|locate)\b(?!.*\bfile\b)": {
        "name": "SEARCH",
        "injection": """
## SEARCH MODE

Exhaustive search activated:
- Use parallel search tools (grep, glob, LSP)
- Try multiple query variations and synonyms
- Check ALL relevant directories and file types
- Don't stop at first match - find ALL occurrences
- Cross-reference results from different tools
"""
    },
    r"\b(analyze|investigate|debug)\b": {
        "name": "DEBUG",
        "injection": """
## DEBUG MODE

Systematic investigation activated:
1. Gather ALL evidence first (logs, stack traces, state)
2. Form hypothesis based on evidence
3. Test hypothesis with minimal changes
4. Verify fix works with actual test/build
5. Document root cause and solution

Do NOT shotgun debug (random changes hoping something works).
"""
    },
    r"\bthink\s+(deeply|hard|carefully|through)\b": {
        "name": "THINK",
        "injection": """
## EXTENDED REASONING MODE

Deep thinking activated:
- Take time to analyze implications
- Consider edge cases and failure modes
- Evaluate multiple alternatives before deciding
- Think through second-order effects
- Document your reasoning process
"""
    },
    r"\b(ship|deploy|release)\b": {
        "name": "SHIP",
        "injection": """
## SHIP MODE

Production readiness check:
- Verify all tests pass
- Check for security vulnerabilities
- Ensure error handling is complete
- Validate documentation is current
- Confirm no debug code or TODOs remain
"""
    }
}

def main():
    try:
        input_data = json.load(sys.stdin)
        prompt = input_data.get("prompt", "")

        injections = []
        activated_modes = []

        for pattern, mode in MODES.items():
            if re.search(pattern, prompt, re.IGNORECASE):
                injections.append(mode["injection"])
                activated_modes.append(mode["name"])

        if injections:
            # Use hookSpecificOutput.additionalContext per Claude Code docs
            result = {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": "\n".join(injections),
                    "activatedModes": activated_modes
                }
            }
        else:
            result = {}

        print(json.dumps(result))

    except Exception:
        # On error, allow prompt to continue without injection
        print(json.dumps({}))

if __name__ == "__main__":
    main()
