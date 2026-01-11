# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code **marketplace** containing multiple plugins with code review and productivity skills.

See [README.md](README.md) for installation and usage instructions.

## Marketplace Structure

```
.claude-plugin/
└── marketplace.json      # Marketplace manifest (lists all plugins)
plugins/
├── vibe-coder-skills/    # Code review and analysis
│   ├── .claude-plugin/plugin.json
│   └── skills/
└── notion-skills/        # Notion workspace automation
    ├── .claude-plugin/plugin.json
    └── skills/
```

## Plugin Structure

Each plugin follows:
```
plugin-name/
├── .claude-plugin/
│   └── plugin.json       # Plugin manifest
└── skills/
    └── skill-name/
        ├── SKILL.md      # Main skill (frontmatter + instructions)
        └── references/   # Detailed documentation
```

## Skill Frontmatter

```yaml
---
name: skill-name
description: Third-person description with trigger keywords
---
```

## Adding New Skills

1. Create `plugins/<plugin-name>/skills/<skill-name>/SKILL.md` with frontmatter
2. Add `references/` for detailed content (progressive disclosure)
3. Keep SKILL.md under 2,000 words; move details to references
4. Include trigger keywords in description for auto-activation

## Adding New Plugins

1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json`
2. Add plugin entry to `.claude-plugin/marketplace.json`
3. Create skills in `plugins/<plugin-name>/skills/`
