#!/usr/bin/env python3
"""
Stop hook: Block session exit if todos are incomplete.

Features:
- Checks for incomplete todos before allowing exit
- Safety valve: 10 consecutive blocks = force allow (prevents infinite loops)
- Session-aware counter reset

Source: Adapted from jarrodwatts/claude-code-config
"""
import json
import sys
import os

CONFIG_PATH = os.path.expanduser("~/.claude/hooks/todo-enforcer.state.json")

def load_state():
    """Load persistent state from JSON file."""
    try:
        with open(CONFIG_PATH) as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {"consecutive_blocks": 0, "session_id": None}

def save_state(state):
    """Save state to JSON file."""
    os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
    with open(CONFIG_PATH, "w") as f:
        json.dump(state, f, indent=2)

def main():
    try:
        input_data = json.load(sys.stdin)

        # Get todos from input (Claude Code passes this in Stop hook)
        todos = input_data.get("todos", [])
        session_id = input_data.get("session_id", "unknown")

        # Find incomplete todos
        incomplete = [
            t for t in todos
            if t.get("status") not in ("completed", "done")
        ]

        state = load_state()

        # Reset counter on new session
        if state.get("session_id") != session_id:
            state = {"consecutive_blocks": 0, "session_id": session_id}

        if incomplete:
            state["consecutive_blocks"] += 1
            save_state(state)

            # Safety valve: 10 consecutive blocks = allow exit
            if state["consecutive_blocks"] >= 10:
                state["consecutive_blocks"] = 0
                save_state(state)
                print(json.dumps({
                    "decision": "approve",
                    "reason": "Safety valve activated: allowing exit after 10 consecutive blocks. Consider completing todos next session."
                }))
            else:
                incomplete_list = "\n".join([f"  - {t.get('content', 'Unknown task')}" for t in incomplete[:5]])
                if len(incomplete) > 5:
                    incomplete_list += f"\n  ... and {len(incomplete) - 5} more"

                print(json.dumps({
                    "decision": "block",
                    "reason": f"Incomplete todos detected ({len(incomplete)} remaining):\n{incomplete_list}\n\nComplete todos before exiting. (Block {state['consecutive_blocks']}/10)"
                }))
        else:
            # All todos complete - allow exit and reset counter
            state["consecutive_blocks"] = 0
            save_state(state)
            print(json.dumps({
                "decision": "approve",
                "reason": "All todos completed. Good work!"
            }))

    except Exception as e:
        # On error, allow exit (fail-open for safety)
        print(json.dumps({
            "decision": "approve",
            "reason": f"Hook error (allowing exit): {str(e)}"
        }))

if __name__ == "__main__":
    main()
