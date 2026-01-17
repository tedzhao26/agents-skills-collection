---
name: mcp-admin
description: Use when managing MCP servers, debugging MCP connection failures, adding/removing MCPs, or troubleshooting AI CLI configs (Claude, Cursor). Triggers include "mcp", "server failed", "add server", "remove server", "config".
---

# MCP Administration

Operations guide for Model Context Protocol servers (Claude Code, Cursor).

## Related Skills

| Task | Skill |
|------|-------|
| Find config file locations | `/ai-config-admin` |
| Backup before MCP changes | `/config-backup` |

## Quick Commands

| Task | Command |
|------|---------|
| List all MCPs | `claude mcp list` |
| Add MCP (user) | `claude mcp add NAME -s user -- COMMAND ARGS` |
| Add MCP (project) | `claude mcp add NAME -s project -- COMMAND ARGS` |
| Remove MCP | `claude mcp remove NAME -s user` |
| Get MCP details | `claude mcp get NAME` |

## Config Locations

| Tool | Config File | Scope |
|------|-------------|-------|
| Claude Code (user) | `~/.claude.json` | All projects |
| Claude Code (project) | `.claude/settings.local.json` | Current project |
| Claude Desktop | `~/Library/Application Support/Claude/claude_desktop_config.json` | Desktop app |
| Cursor | `~/.cursor/mcp.json` | IDE |

## Adding MCP Servers

### Stdio (npm/uvx packages)
```bash
# npm package
claude mcp add server-name -s user -- npx -y @package/mcp-server

# Python package (uvx)
claude mcp add server-name -s user -- uvx package-name

# With environment variables
claude mcp add server-name -s user \
  -e API_KEY=xxx \
  -e OTHER_VAR=yyy \
  -- npx -y @package/mcp-server
```

### Remote (HTTP)
```bash
claude mcp add server-name -s user -- npx -y mcp-remote https://api.example.com/mcp
```

## Debugging Failed MCPs

1. **Check status**: `claude mcp list` - shows ✓/✗ for each server
2. **Get details**: `claude mcp get SERVER_NAME` - shows command, args, env
3. **Test manually**: Run the command directly in terminal to see errors
4. **Check port conflicts**: `lsof -i :PORT` - common with OAuth callbacks
5. **Kill stale processes**: Find PID from lsof, then `kill PID`

### Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `EADDRINUSE` | Port conflict | Kill process using port or use different package |
| `Failed to connect` | Bad credentials | Check env vars in `claude mcp get NAME` |
| `Command not found` | Missing dependency | Install package (`npm i -g` or `pip install`) |
| Tools not showing | Need restart | Restart Claude Code after adding MCP |

## Multi-Account Pattern

Some MCPs (like Gmail) don't support multiple instances. Use MCPs with proper multi-account support:

| Service | Single-Account Package | Multi-Account Package |
|---------|----------------------|----------------------|
| Gmail | `@shinzolabs/gmail-mcp` | `workspace-mcp` (uvx) |
| Google Drive | `@isaacphi/mcp-gdrive` | `workspace-mcp` (uvx) |
| Notion | - | `mcp-remote https://mcp.notion.com/mcp` |

## Backup Config

Before major changes:
```bash
cp ~/.claude.json ~/.claude.json.bak
```

Or use chezmoi if configured:
```bash
dotfiles sync && dotfiles commit m="Backup MCP config"
```
