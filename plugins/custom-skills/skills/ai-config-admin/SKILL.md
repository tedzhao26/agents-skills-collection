---
name: ai-config-admin
description: Reference guide for AI CLI tool config locations (Claude, Codex, Gemini, Cursor). Use when you need to FIND where configs live, understand config structure, or create new skills. For MCP operations use `/mcp-admin`. For backup workflows use `/config-backup`. Triggers include "where is config", "config location", "claude path", "codex path", "find settings", "skill structure", "create skill".
---

# AI Config Administration

Reference guide for Claude Code, Codex CLI, Gemini CLI, and Cursor config locations.

## Related Skills

| Task | Skill |
|------|-------|
| Add/remove/debug MCP servers | `/mcp-admin` |
| Backup before/after changes | `/config-backup` |
| General dotfiles management | `/chezmoi` |

## Config Locations

### Claude Code

| Path | Purpose |
|------|---------|
| `~/.claude/` | Main config directory |
| `~/.claude/CLAUDE.md` | Global instructions (all projects) |
| `~/.claude/settings.json` | Global settings, permissions, hooks |
| `~/.claude.json` | **User-scope MCP servers** (in HOME, not ~/.claude/) |
| `~/.claude/skills/` | Custom skills |
| `~/.claude/plugins/` | Installed plugins |
| `~/.claude/agents/` | Custom agents (subagent definitions) |
| `~/.claude/projects/` | Project-specific data |
| `<project>/.mcp.json` | **Project-scope MCP servers** (shareable) |
| `<project>/.claude/settings.local.json` | Project-specific settings |
| `<project>/CLAUDE.md` | Project-specific instructions |

**IMPORTANT:** MCP servers go in `~/.claude.json`, NOT `~/.claude/settings.json` or `~/.claude/claude.json`.

### Codex CLI

| Path | Purpose |
|------|---------|
| `~/.codex/` | Main config directory |
| `~/.codex/config.toml` | Global config (model, approval mode) |
| `~/.codex/AGENTS.md` | Global instructions |
| `~/.codex/modes/` | Mode-specific instructions (orchestrator/subagent) |
| `~/.codex/skills/` | Custom skills |
| `~/.codex/prompts/` | Custom prompts |
| `~/.codex/rules/` | Custom rules |
| `~/.codex/sessions/` | Session data |
| `<project>/AGENTS.md` | Project-specific instructions |

### Gemini CLI

| Path | Purpose |
|------|---------|
| `~/.gemini/` | Main config directory |
| `~/.gemini/settings.json` | Global settings (model, sandbox) |
| `~/.gemini/GEMINI.md` | Global instructions |
| `<project>/GEMINI.md` | Project-specific instructions |

### Cursor (IDE)

| Path | Purpose |
|------|---------|
| `~/.cursor/` | Main config directory |
| `~/.cursor/mcp.json` | MCP server configurations |
| `~/.cursor/extensions/` | Installed extensions |

## MCP Server Locations

| Tool | MCP Config Location | Scope |
|------|---------------------|-------|
| Claude Code | `~/.claude.json` | User (all projects) |
| Claude Code | `<project>/.mcp.json` | Project (shareable) |
| Cursor | `~/.cursor/mcp.json` | User |

### MCP Scope Priority (Claude Code)

1. **Local** - current project only
2. **Project** - `.mcp.json` (team-shared)
3. **User** - `~/.claude.json` (all your projects)

**For MCP operations (add/remove/debug):** See `/mcp-admin` skill.

## Skill Management

### Claude Skills

```bash
# List skills
ls ~/.claude/skills/

# Create new skill
mkdir ~/.claude/skills/my-skill
# Create SKILL.md with frontmatter (name, description) + instructions

# Skill format
~/.claude/skills/my-skill/
├── SKILL.md          # Required: frontmatter + instructions
├── references/       # Optional: loaded on demand
└── scripts/          # Optional: executable helpers
```

### Codex Skills

```bash
# List skills
ls ~/.codex/skills/

# Create new skill
mkdir ~/.codex/skills/my-skill
# Create SKILL.md with frontmatter + instructions

# Install from curated list
codex  # then use /skill-installer
```

### Skill Frontmatter Format

```yaml
---
name: skill-name
description: When to use this skill. Include trigger words.
metadata:
  short-description: Brief label (Codex only)
---
```

## Codex Dual-Mode System

Codex operates in two modes based on `$CODEX_MODE`:

| Mode | Trigger | Behavior |
|------|---------|----------|
| Orchestrator | `codex` (direct) | Interactive, can dispatch agents |
| Subagent | `CODEX_MODE=subagent codex exec` | Focused, structured output |

Mode-specific instructions:
- `~/.codex/modes/orchestrator.md`
- `~/.codex/modes/subagent.md`

## Quick Commands

```bash
# Edit Claude MCP config (USER scope)
$EDITOR ~/.claude.json

# Edit Codex config
$EDITOR ~/.codex/config.toml

# Edit Claude global instructions
$EDITOR ~/.claude/CLAUDE.md

# Edit Codex global instructions
$EDITOR ~/.codex/AGENTS.md

# Find all MCP configs
grep -l "mcpServers" ~/.claude.json ~/.cursor/mcp.json 2>/dev/null
find . -name ".mcp.json" 2>/dev/null

# Find all project instructions
find ~/Projects -name "CLAUDE.md" -o -name "AGENTS.md" -o -name "GEMINI.md" 2>/dev/null

# Check what's managed by chezmoi (see /chezmoi skill)
chezmoi managed | grep -E "claude|codex|gemini|cursor"

# Backup config changes (see /config-backup skill)
dotfiles sync && dotfiles commit m="Update AI configs"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| MCP issues | See `/mcp-admin` for debugging |
| Skill not triggering | Check description has trigger words |
| Codex wrong mode | Verify `$CODEX_MODE` env var |
| Config not syncing | Run `dotfiles sync` (see `/config-backup`) |

## Current Skill Sets

### Claude-Specific Skills
- `team` - Multi-agent orchestration
- `agent-creator` - Create Claude agents
- `config-backup` - Backup AI configs
- `pf` - Planning shortcut
- `ai-config-admin` - This skill

### Codex-Specific Skills
- `gh-fix-ci` - Fix GitHub Actions
- `gh-address-comments` - Address PR comments
- `create-plan` - Quick planning
- `claude-to-agents` - Convert CLAUDE.md to AGENTS.md

### Shared (Tool-Agnostic)
- `ast-grep` - Structural code refactoring
- `tldr` - Semantic code search
- `browser-automation` - Headless browser
- `planning-with-files` - File-based planning
