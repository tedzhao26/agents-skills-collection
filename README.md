# agents-skills-collection

A Claude Code plugin marketplace with skills for code review, analysis, and Notion workflows.

## Installation

Add the marketplace to Claude Code:

```
/plugin marketplace add tedzhao26/agents-skills-collection
```

Then install the plugins you want:

```
/plugin install vibe-coder-skills
/plugin install notion-skills
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [vibe-coder-skills](#vibe-coder-skills) | Code review and analysis skills |
| [notion-skills](#notion-skills) | Notion workspace workflows |

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

## notion-skills

Notion workspace skills - meeting intelligence, research & documentation, knowledge capture, and spec-to-implementation workflows.

### Capabilities

| Capability | Description |
|------------|-------------|
| Meeting Intelligence | Prepare meeting materials with context from Notion |
| Research & Documentation | Search, synthesize, and create structured reports |
| Knowledge Capture | Turn conversations into wiki pages and decision records |
| Spec to Implementation | Transform specs into tasks with progress tracking |

### Usage

```
"Prep me for tomorrow's design review meeting"
"Research our authentication approach and create a summary"
"Save this decision to the team wiki"
"Turn this spec into implementation tasks"
```

---

## Repository Structure

```
agents-skills-collection/
├── marketplace.json
├── plugins/
│   ├── vibe-coder-skills/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   └── notion-skills/
│       ├── .claude-plugin/plugin.json
│       └── skills/
└── README.md
```

## License

MIT
