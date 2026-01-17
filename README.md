# agents-skills-collection

A Claude Code plugin marketplace with skills for code review and analysis.

## Installation

Add the marketplace to Claude Code:

```bash
/plugin marketplace add tedzhao26/agents-skills-collection
```

Then install the plugin:

```bash
/plugin install vibe-coder-skills
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [vibe-coder-skills](#vibe-coder-skills) | Code review and analysis skills |

---

## vibe-coder-skills

Code review and analysis skills - AST-based search, Clean Code review, and documentation consistency checking.

### Skills

| Skill | Purpose |
|-------|---------|
| ast-grep-rule-crafter | AST-based code search and rewrite rules using ast-grep YAML |
| clean-code-reviewer | Code quality review based on Clean Code principles |
| doc-consistency-reviewer | Check documentation consistency with code implementation |

### Usage

```
"Help me write an ast-grep rule to find console.log"
"Review this code for Clean Code violations"
"Check if README matches the implementation"
```

---

## Repository Structure

```
agents-skills-collection/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── vibe-coder-skills/
│       ├── .claude-plugin/plugin.json
│       └── skills/
└── README.md
```

## License

MIT
