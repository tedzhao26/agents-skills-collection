# vibe-coder-skills

A Claude Code plugin with code review and analysis skills for Vibe Coders.

## Installation

```bash
# Install from local path
claude plugin add /path/to/skills-for-vibe-coder

# Or clone and install
git clone https://github.com/hylarucoder/skills-for-vibe-coder.git
claude plugin add ./skills-for-vibe-coder
```

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
