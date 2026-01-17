---
name: chezmoi
description: Manage dotfiles with chezmoi for cross-machine configuration management. Use when setting up dotfiles, syncing configs across machines, managing secrets, using templates, or troubleshooting chezmoi. Triggers include "chezmoi", "dotfiles", "sync configs", "manage configurations", "dotfiles repo", "home directory management".
---

# Chezmoi Dotfiles Management

General-purpose dotfiles management across multiple machines, supporting templates, secrets, and cross-platform configuration.

## Related Skills

| Task | Skill |
|------|-------|
| Backup AI tool configs specifically | `/config-backup` |
| Find AI tool config locations | `/ai-config-admin` |

## Source Directory

```
~/.local/share/chezmoi/              # Source of truth
├── dot_zshrc                        # ~/.zshrc
├── dot_gitconfig                    # ~/.gitconfig
├── dot_config/                      # ~/.config/
│   └── zed/
│       └── private_settings.json
├── private_dot_ssh/                 # ~/.ssh/ (private)
│   └── config
└── private_dot_claude/              # ~/.claude/ (private)
    └── skills/
```

## Naming Conventions

| Prefix | Effect |
|--------|--------|
| `dot_` | Replace with `.` |
| `private_` | File permissions 0600 |
| `executable_` | File permissions 0755 |
| `exact_` | Remove files not in source |
| `modify_` | Run script to modify existing file |
| `run_` | Run script (once/always) |
| `.tmpl` suffix | Process as template |

## Core Commands

| Command | Description |
|---------|-------------|
| `chezmoi init` | Initialize chezmoi |
| `chezmoi add ~/.zshrc` | Add file to source |
| `chezmoi edit ~/.zshrc` | Edit source file |
| `chezmoi diff` | Show pending changes |
| `chezmoi apply` | Apply changes to home |
| `chezmoi update` | Pull and apply from repo |
| `chezmoi cd` | Enter source directory |
| `chezmoi data` | Show template data |
| `chezmoi doctor` | Check for problems |

## Daily Workflow

### Adding New Config

```bash
chezmoi add ~/.config/app/config.toml
chezmoi cd
git add -A && git commit -m "Add app config"
git push
```

### Syncing to New Machine

```bash
chezmoi init --apply https://github.com/user/dotfiles.git
```

### Making Changes

```bash
chezmoi edit ~/.zshrc          # Edit in source
chezmoi diff                   # Review changes
chezmoi apply                  # Apply to home
chezmoi cd && git add -A && git commit -m "Update zshrc" && git push
```

## Templates

Create `.tmpl` files with Go templates:

```bash
# dot_gitconfig.tmpl
[user]
    name = {{ .name }}
    email = {{ .email }}
{{ if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{ end }}
```

### Template Data

Configure in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    name = "Ted"
    email = "ted@example.com"
```

### Useful Template Variables

```go
{{ .chezmoi.hostname }}         # Machine hostname
{{ .chezmoi.os }}               # darwin, linux, windows
{{ .chezmoi.arch }}             # amd64, arm64
{{ .chezmoi.username }}         # Current user
{{ .chezmoi.homeDir }}          # Home directory
```

## Secrets Management

### 1Password Integration

```bash
# dot_env.tmpl
API_KEY={{ onepasswordRead "op://Vault/Item/field" }}
```

### Bitwarden Integration

```bash
SECRET={{ bitwarden "item-id" "field" }}
```

### Age Encryption

```bash
chezmoi age encrypt ~/.ssh/id_rsa
# Creates encrypted_private_dot_ssh/private_id_rsa.age
```

## Scripts

### Run Once

```bash
# run_once_install-packages.sh
#!/bin/bash
brew install ripgrep fd bat
```

### Run on Change

```bash
# run_onchange_reload-shell.sh.tmpl
#!/bin/bash
# hash: {{ include "dot_zshrc" | sha256sum }}
exec zsh
```

## External Sources

Pull from external repos or URLs:

```yaml
# .chezmoiexternal.toml
[".oh-my-zsh"]
    type = "archive"
    url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
    exact = true
    stripComponents = 1
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Permission denied | Check `private_` prefix, run `chezmoi doctor` |
| Template error | Run `chezmoi execute-template < file.tmpl` to debug |
| Merge conflicts | `chezmoi merge ~/.file` for interactive merge |
| Wrong file state | `chezmoi forget ~/.file` then `chezmoi add ~/.file` |
| See what changed | `chezmoi diff` before apply |

## Current Setup Summary

Your chezmoi source (`~/.local/share/chezmoi/`) contains:
- Shell configs: `.zshrc`, `.zprofile`, `.zshenv`
- Git config: `.gitconfig`
- SSH config: `.ssh/` (private)
- Claude Code: `.claude/` (private)
- Codex CLI: `.codex/`
- Editor configs: `.config/zed/`, `.cursor/`

## References

- [Chezmoi docs](https://www.chezmoi.io/)
- [Quick start](https://www.chezmoi.io/quick-start/)
- [Templating](https://www.chezmoi.io/user-guide/templating/)
