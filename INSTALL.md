# Installation Guide

This guide helps you set up Claude Code with the complete skill/plugin configuration from this repo.

## Quick Start (Fresh Install)

```bash
# 1. Add this marketplace
claude plugins add-marketplace https://github.com/tedzhao26/agents-skills-collection

# 2. Install custom-skills plugin (your skills + agents)
claude plugins install custom-skills

# 3. Run the full setup script below
```

## Full Setup Script

Copy and run this to install all plugins:

```bash
#!/bin/bash
# Claude Code Full Plugin Setup

# Add all marketplaces
claude plugins add-marketplace https://github.com/anthropics/claude-plugins-official
claude plugins add-marketplace https://github.com/LexiestLeszek/superpowers
claude plugins add-marketplace https://github.com/anthropics/claude-code-workflows
claude plugins add-marketplace https://github.com/jlowin/obsidian-skills
claude plugins add-marketplace https://github.com/mettamatt/planning-with-files
claude plugins add-marketplace https://github.com/AshKelly/claude-hud
claude plugins add-marketplace https://github.com/daymade/daymade-skills
claude plugins add-marketplace https://github.com/tedzhao26/agents-skills-collection

# Install official Anthropic plugins
claude plugins install code-review
claude plugins install commit-commands
claude plugins install pr-review-toolkit
claude plugins install agent-sdk-dev
claude plugins install pyright-lsp
claude plugins install explanatory-output-style
claude plugins install greptile
claude plugins install code-simplifier
claude plugins install huggingface-skills

# Install third-party plugins
claude plugins install superpowers
claude plugins install planning-with-files
claude plugins install claude-hud
claude plugins install python-development
claude plugins install unit-testing
claude plugins install tdd-workflows
claude plugins install obsidian

# Install selected daymade-skills
claude plugins install skill-creator
claude plugins install prompt-optimizer
claude plugins install markdown-tools
claude plugins install mermaid-tools

# Install from this repo
claude plugins install vibe-coder-skills
claude plugins install custom-skills

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
