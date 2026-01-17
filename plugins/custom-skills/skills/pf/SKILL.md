---
name: pf
description: Shortcut for file-based planning (Manus-style). Creates task_plan.md, findings.md, and progress.md for complex multi-step tasks. Use for research projects or tasks requiring >5 tool calls. Triggers include "pf", "file planning", "manus planning".
---

# File-Based Planning (Manus-style)

Invoke the full planning skill:

```
/planning-with-files:planning-with-files
```

## Folder Structure Override

Use `.planning/` (hidden folder, gitignored) instead of project root:

```
.planning/
└── <YYYYMMDD>-<task-name>/          # timestamp + kebab-case task name
    ├── task_plan.md
    ├── findings.md
    └── progress.md
```

**Folder Naming Convention:**
1. Get current date in `YYYYMMDD` format (e.g., `20260111`)
2. Ask user for task name or derive from context
3. Convert task name to kebab-case
4. Combine: `<YYYYMMDD>-<task-name>`

**Example:** `.planning/20260111-hooks-format-fix/`

**Note:** `.planning/` should be added to `.gitignore` - these are local work-in-progress files not meant to be committed.
