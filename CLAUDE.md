# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin (`vibe-coder-skills`) providing code review and analysis skills. Install with:

```bash
claude plugin add /path/to/skills-for-vibe-coder
```

## Plugin Structure

```
.claude-plugin/
└── plugin.json           # Plugin manifest
skills/
├── ast-grep-rule-crafter/    # AST-based code search/rewrite
├── clean-code-reviewer/      # Clean Code principles review
└── doc-consistency-reviewer/ # Documentation consistency
```

Each skill follows:
```
skill-name/
├── SKILL.md              # Main skill (frontmatter + instructions)
└── references/           # Detailed documentation
```

## Skill Frontmatter

```yaml
---
name: skill-name
description: Third-person description with trigger keywords
---
```

## Adding New Skills

1. Create `skills/<skill-name>/SKILL.md` with frontmatter
2. Add `references/` for detailed content (progressive disclosure)
3. Keep SKILL.md under 2,000 words; move details to references
4. Include trigger keywords in description for auto-activation
