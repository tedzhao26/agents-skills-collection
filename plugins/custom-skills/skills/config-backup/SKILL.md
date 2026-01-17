---
name: config-backup
description: Backup and manage AI CLI tool configurations with chezmoi and local fallback. Use when modifying settings, adding MCP servers, updating instructions, or syncing configs. Triggers include "backup settings", "sync config", "save config", "config backup", "dotfiles backup", "before changing settings", "backup claude", "save claude settings", ".claude backup", "claude config".
---

# Config Backup Skill

Workflow for safely backing up AI CLI tool configurations.

## Related Skills

| Task | Skill |
|------|-------|
| Learn chezmoi basics | `/chezmoi` |
| Find config file locations | `/ai-config-admin` |
| Add/remove MCP servers | `/mcp-admin` |

## Strategy

Two-layer backup approach:
1. **Primary:** Chezmoi (git-based, versioned, synced across machines)
2. **Fallback:** Local timestamped backups (auto-cleaned)

## Config Locations Reference

See `/ai-config-admin` for full config paths. Quick reference:

### Claude Code

| File | Purpose | Chezmoi Path |
|------|---------|--------------|
| `~/.claude/settings.json` | Settings, MCP servers, hooks | `private_dot_claude/private_settings.json` |
| `~/.claude/CLAUDE.md` | Global instructions | `private_dot_claude/private_CLAUDE.md` |

### Other AI Tools

| Tool | Config | Chezmoi Path |
|------|--------|--------------|
| Codex | `~/.codex/config.toml` | `private_dot_codex/config.toml` |
| Gemini | `~/.gemini/settings.json` | `dot_gemini/settings.json` |
| Cursor | `~/.cursor/mcp.json` | `dot_cursor/mcp.json` |

### Chezmoi Source

```
~/.local/share/chezmoi/    # Source of truth
```

## Pre-Change Backup Workflow

**ALWAYS run before modifying any config file:**

```bash
# 1. Create local fallback backup
BACKUP_DIR=~/.config-backups
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Backup the file you're about to change
cp ~/.claude/settings.json $BACKUP_DIR/settings.json.$TIMESTAMP.pre

# 2. Sync current state to chezmoi (captures pre-change state)
chezmoi re-add ~/.claude/settings.json
cd ~/.local/share/chezmoi && git add -A && git stash  # Stash pre-change state
```

## Post-Change Backup Workflow

**ALWAYS run after modifying config files:**

```bash
# 1. Create post-change local backup
cp ~/.claude/settings.json $BACKUP_DIR/settings.json.$TIMESTAMP.post

# 2. Sync to chezmoi and commit
chezmoi re-add ~/.claude/settings.json ~/.claude/CLAUDE.md
cd ~/.local/share/chezmoi
git stash drop 2>/dev/null  # Drop pre-change stash
git add -A
git commit -m "Update config: <description>"
git push

# 3. Cleanup old backups (keep last 10)
ls -t $BACKUP_DIR/*.pre $BACKUP_DIR/*.post 2>/dev/null | tail -n +21 | xargs rm -f
```

## Quick Commands

### Run Backup Script

```bash
# From skill folder
~/.claude/skills/config-backup/backup.sh

# Or create alias in .zshrc
alias config-backup='~/.claude/skills/config-backup/backup.sh'
```

### Full Backup (All AI Configs)

```bash
# Backup all AI tool configs to chezmoi
chezmoi re-add \
  ~/.claude/settings.json \
  ~/.claude/CLAUDE.md \
  ~/.codex/config.toml \
  ~/.gemini/settings.json \
  ~/.cursor/mcp.json 2>/dev/null

cd ~/.local/share/chezmoi
git add -A && git commit -m "Backup all AI configs $(date +%Y-%m-%d)" && git push
```

### Local Fallback Backup

```bash
# Create timestamped backup of all configs
BACKUP_DIR=~/.config-backups
TIMESTAMP=$(date +%Y%m%d%H%M%S)
mkdir -p $BACKUP_DIR

cp ~/.claude/settings.json $BACKUP_DIR/claude-settings.$TIMESTAMP
cp ~/.claude/CLAUDE.md $BACKUP_DIR/claude-instructions.$TIMESTAMP
cp ~/.codex/config.toml $BACKUP_DIR/codex-config.$TIMESTAMP 2>/dev/null
cp ~/.gemini/settings.json $BACKUP_DIR/gemini-settings.$TIMESTAMP 2>/dev/null
```

### Cleanup Old Backups

```bash
# Keep only last 10 backups per file type
BACKUP_DIR=~/.config-backups
for prefix in claude-settings claude-instructions codex-config gemini-settings; do
  ls -t $BACKUP_DIR/$prefix.* 2>/dev/null | tail -n +11 | xargs rm -f
done

# Or delete backups older than 30 days
find $BACKUP_DIR -type f -mtime +30 -delete
```

### Restore from Backup

```bash
# Restore from local backup
cp ~/.config-backups/claude-settings.<timestamp> ~/.claude/settings.json

# Restore from chezmoi (last committed version)
chezmoi apply ~/.claude/settings.json

# Restore from chezmoi git history
cd ~/.local/share/chezmoi
git log --oneline private_dot_claude/private_settings.json  # Find commit
git show <commit>:private_dot_claude/private_settings.json > /tmp/restored.json
cp /tmp/restored.json ~/.claude/settings.json
```

## Backup Script

Located at: `~/.claude/skills/config-backup/backup.sh`

The script handles:
- Local timestamped backups to `~/.config-backups/`
- Chezmoi sync and git push
- Auto-cleanup (keeps last 10 per file type)

## Backup Strategy Summary

| Layer | Storage | Retention | Use Case |
|-------|---------|-----------|----------|
| **Chezmoi** | Git repo | Forever (git history) | Cross-machine sync, version history |
| **Local** | `~/.config-backups/` | Last 10 per file | Quick rollback, before risky changes |

## When to Backup

| Action | Backup Command |
|--------|----------------|
| Before adding MCP server | `config-backup` or pre-change workflow |
| After modifying settings | Post-change workflow |
| Before major changes | Full local backup + chezmoi stash |
| Daily (optional) | `config-backup` in cron |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Chezmoi conflict | `chezmoi merge <file>` |
| Lost local backup | Check chezmoi git history |
| Wrong restore | Use `.pre` backup from same timestamp |
| Too many backups | Run cleanup command |
