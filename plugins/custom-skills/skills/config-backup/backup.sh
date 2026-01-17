#!/bin/bash
# Two-layer config backup script
# Layer 1: Local timestamped backups (quick rollback)
# Layer 2: Chezmoi git repo (versioned, cross-machine)

BACKUP_DIR=~/.config-backups
TIMESTAMP=$(date +%Y%m%d%H%M%S)
KEEP_COUNT=10  # Number of backups to keep per file type

mkdir -p "$BACKUP_DIR"

echo "=== Config Backup $(date) ==="

# Layer 1: Local fallback backups
echo ""
echo "[Layer 1] Creating local backups..."

backup_file() {
  local src="$1"
  local dest="$2"
  if [[ -f "$src" ]]; then
    cp "$src" "$BACKUP_DIR/$dest.$TIMESTAMP"
    echo "  ✓ $dest"
  fi
}

backup_file "$HOME/.claude/settings.json" "claude-settings"
backup_file "$HOME/.claude/CLAUDE.md" "claude-instructions"
backup_file "$HOME/.codex/config.toml" "codex-config"
backup_file "$HOME/.gemini/settings.json" "gemini-settings"
backup_file "$HOME/.cursor/mcp.json" "cursor-mcp"

# Layer 2: Chezmoi (git)
echo ""
echo "[Layer 2] Syncing to chezmoi..."
chezmoi re-add \
  ~/.claude/settings.json \
  ~/.claude/CLAUDE.md \
  2>/dev/null || true

cd ~/.local/share/chezmoi
if [[ -n $(git status --porcelain) ]]; then
  git add -A
  git commit -m "Auto-backup $(date +%Y-%m-%d\ %H:%M)"
  if git push 2>/dev/null; then
    echo "  ✓ Pushed to remote"
  else
    echo "  ⚠ Committed locally (push failed)"
  fi
else
  echo "  • No changes to commit"
fi

# Cleanup: keep last N backups per file type
echo ""
echo "[Cleanup] Keeping last $KEEP_COUNT backups per type..."
for prefix in claude-settings claude-instructions codex-config gemini-settings cursor-mcp; do
  count=$(ls -1 "$BACKUP_DIR/$prefix."* 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt "$KEEP_COUNT" ]]; then
    deleted=$((count - KEEP_COUNT))
    ls -t "$BACKUP_DIR/$prefix."* 2>/dev/null | tail -n +$((KEEP_COUNT + 1)) | xargs rm -f
    echo "  ✓ $prefix: removed $deleted old backup(s)"
  fi
done

echo ""
echo "=== Backup complete ==="
echo "Local backups: $BACKUP_DIR"
echo "Chezmoi repo: ~/.local/share/chezmoi"
