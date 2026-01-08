# vibe-coder-skills

A Claude Code plugin with code review and analysis skills for Vibe Coders.

## Installation

In Claude Code, run these commands separately:

1. Add the marketplace:
   ```
   /plugin marketplace add tedzhao26/skills-for-vibe-coder
   ```

2. Install the plugin:
   ```
   /plugin install vibe-coder-skills@skills-for-vibe-coder
   ```

3. Restart Claude Code to use the new skills.

## Skills

| Skill | Purpose |
|-------|---------|
| [ast-grep-rule-crafter](skills/ast-grep-rule-crafter) | AST-based code search and rewrite rules using ast-grep YAML |
| [clean-code-reviewer](skills/clean-code-reviewer) | Code quality review based on Clean Code principles |
| [doc-consistency-reviewer](skills/doc-consistency-reviewer) | Check documentation consistency with code implementation |

## Usage

Skills activate automatically when you mention relevant keywords:

```
# AST-grep rules
"Help me write an ast-grep rule to find console.log"
"Create a lint rule for unused variables"

# Code review
"Review this code for Clean Code violations"
"Do a code quality check on src/"

# Documentation review
"Check if README matches the implementation"
"Review docs for consistency with code"
```

## License

MIT
