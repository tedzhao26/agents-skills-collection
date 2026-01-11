# agents-skills-collection

A collection of Claude Code plugins with skills for code review, analysis, and Notion workflows.

## Plugins

This repository contains two separate plugins:

| Plugin | Description |
|--------|-------------|
| [vibe-coder-skills](#vibe-coder-skills) | Code review and analysis skills |
| [notion-skills](#notion-skills) | Notion workspace workflows |

---

## vibe-coder-skills

Code review and analysis skills - AST-based search, Clean Code review, and documentation consistency checking.

### Installation

```
/plugin marketplace add tedzhao26/agents-skills-collection
/plugin install vibe-coder-skills@agents-skills-collection
```

### Skills

| Skill | Purpose |
|-------|---------|
| [ast-grep-rule-crafter](skills/ast-grep-rule-crafter) | AST-based code search and rewrite rules using ast-grep YAML |
| [clean-code-reviewer](skills/clean-code-reviewer) | Code quality review based on Clean Code principles |
| [doc-consistency-reviewer](skills/doc-consistency-reviewer) | Check documentation consistency with code implementation |

### Usage

```
"Help me write an ast-grep rule to find console.log"
"Review this code for Clean Code violations"
"Check if README matches the implementation"
```

---

## notion-skills

Notion workspace skills - meeting intelligence, research & documentation, knowledge capture, and spec-to-implementation workflows.

### Installation

```
/plugin marketplace add tedzhao26/agents-skills-collection
/plugin install notion-skills@agents-skills-collection
```

### Skills

| Skill | Purpose |
|-------|---------|
| [notion](notion-skills/skills/notion) | Comprehensive Notion workflows |

The notion skill includes 4 capabilities:

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

## License

MIT
