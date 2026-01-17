# Installation Guide

This guide helps you set up Claude Code with the complete skill/plugin configuration from this repo.

## Quick Start (Fresh Install)

```bash
# 1. Add this marketplace
claude plugin marketplace add https://github.com/tedzhao26/agents-skills-collection

# 2. Install custom-skills plugin (your skills + agents)
claude plugin install custom-skills

# 3. Run the full setup script below
```

## Full Setup Script

Copy and run this to install all plugins:

```bash
#!/bin/bash
# Claude Code Full Plugin Setup

# Add all marketplaces
claude plugin marketplace add https://github.com/anthropics/claude-plugins-official
claude plugin marketplace add https://github.com/LexiestLeszek/superpowers
claude plugin marketplace add https://github.com/anthropics/claude-code-workflows
claude plugin marketplace add https://github.com/jlowin/obsidian-skills
claude plugin marketplace add https://github.com/mettamatt/planning-with-files
claude plugin marketplace add https://github.com/AshKelly/claude-hud
claude plugin marketplace add https://github.com/daymade/daymade-skills
claude plugin marketplace add https://github.com/tedzhao26/agents-skills-collection

# Install official Anthropic plugins
claude plugin install code-review
claude plugin install commit-commands
claude plugin install pr-review-toolkit
claude plugin install agent-sdk-dev
claude plugin install pyright-lsp
claude plugin install explanatory-output-style
claude plugin install greptile
claude plugin install code-simplifier
claude plugin install huggingface-skills

# Install third-party plugins
claude plugin install superpowers
claude plugin install planning-with-files
claude plugin install claude-hud
claude plugin install python-development
claude plugin install unit-testing
claude plugin install tdd-workflows
claude plugin install obsidian

# Install selected daymade-skills
claude plugin install skill-creator
claude plugin install prompt-optimizer
claude plugin install markdown-tools
claude plugin install mermaid-tools

# Install from this repo
claude plugin install vibe-coder-skills
claude plugin install custom-skills

echo "Done! Restart Claude Code to load all plugins."
```

## Reset and Reinstall

To completely reset Claude Code and reinstall:

```bash
# 1. Backup current config (optional)
cp -r ~/.claude ~/.claude-backup-$(date +%Y%m%d)

# 2. Reset Claude Code
rm -rf ~/.claude/plugins
rm -rf ~/.claude/skills
rm -rf ~/.claude/agents
rm ~/.claude/settings.json
rm ~/.claude/settings.local.json

# Note: Keep these if you want:
# - ~/.claude/CLAUDE.md (global instructions)
# - ~/.claude/hooks/ (custom hooks)
# - ~/.claude/rules/ (custom rules)

# 3. Run the full setup script above
```

## CLI Tool Dependencies

Some skills require external CLI tools:

| Tool | Install Command | Used By |
|------|-----------------|---------|
| ast-grep | `brew install ast-grep` | `/ast-grep` skill |
| agent-browser | `npm install -g agent-browser` | `/browser-automation` skill |
| chezmoi | `brew install chezmoi` | `/chezmoi`, `/config-backup` skills |
| ripgrep | `brew install ripgrep` | General search |
| codex | See OpenAI docs | `codex` agent |
| gemini | See Google AI docs | `gemini` agent |

Install all at once:

```bash
brew install ast-grep chezmoi ripgrep fd bat
npm install -g agent-browser
```

## MCP Server Setup

These skills require MCP servers configured in `~/.claude.json`:

| Skill | MCP Server | Setup |
|-------|------------|-------|
| `/google-workspace` | workspace-ted, workspace-zp4work | Google Workspace MCP |
| `/browser-automation` | chrome-devtools | Chrome DevTools MCP |
| `/notion-to-zettel` | Notion-* | Notion MCP |

## Restoring Config Files

The `custom-skills` plugin includes backup configs in `plugins/custom-skills/config/`:

- `CLAUDE.md` - Global instructions
- `hooks/` - Custom hooks
- `rules/` - Custom rules
- `settings.json` - Settings template

To restore:

```bash
# Copy CLAUDE.md (customize as needed)
cp plugins/custom-skills/config/CLAUDE.md ~/.claude/

# Copy hooks
cp -r plugins/custom-skills/config/hooks ~/.claude/

# Copy rules
cp -r plugins/custom-skills/config/rules ~/.claude/
```

## What's Included

### custom-skills Plugin (20 skills, 2 agents)

**Workflow & Orchestration:**
- `team` - Multi-agent orchestration
- `team-loop` - Iterative team workflows
- `graph-loop` - Graph-based workflow execution
- `pf` - File-based planning (Manus-style)

**Visualization:**
- `mermaid-visualizer` - Mermaid diagram generation
- `excalidraw-diagram` - Excalidraw for Obsidian
- `obsidian-canvas-creator` - Obsidian Canvas files

**DevOps & Config:**
- `senior-devops` - CI/CD, infrastructure, cloud
- `chezmoi` - Dotfiles management
- `config-backup` - AI CLI config backup
- `ai-config-admin` - Config locations reference
- `mcp-admin` - MCP server management

**Code Tools:**
- `ast-grep` - AST-based code search/rewrite
- `tldr` - Semantic code analysis
- `browser-automation` - Web automation

**Productivity:**
- `google-workspace` - Gmail, Drive, Calendar
- `notion-to-zettel` - Notion to Zettelkasten sync
- `zettelkasten-note` - Knowledge capture
- `agent-creator` - Create custom agents
- `agent-file-pattern` - Agent communication patterns

**Agents:**
- `codex` - Code review, diff generation (depth)
- `gemini` - Large codebase analysis (breadth)

### vibe-coder-skills Plugin

- `clean-code-reviewer` - Clean Code analysis
- `ast-grep-rule-crafter` - AST-grep rule creation
- `doc-consistency-reviewer` - Documentation review
