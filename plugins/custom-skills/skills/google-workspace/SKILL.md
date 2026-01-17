---
name: google-workspace
description: Google Workspace MCP usage guide for two accounts. Use when working with Gmail, Google Drive, Docs, Sheets, Calendar, or Tasks. Triggers include "workspace", "gmail", "google drive", "google docs", "google sheets", "calendar", "ted.zhao.au", "zp4work", "work email", "personal email", "drive files".
---

# Google Workspace MCP

Two accounts configured with different purposes.

## Account Routing

| Account | MCP Server | Purpose |
|---------|------------|---------|
| ted.zhao.au@gmail.com | `workspace-ted` | Work email, main file stash (Drive) |
| zp4work@gmail.com | `workspace-zp4work` | Personal email for product registrations |

## When to Use Which

| Task | Use |
|------|-----|
| Work documents & files | `workspace-ted` |
| Work calendar & tasks | `workspace-ted` |
| Job-related email | `workspace-ted` |
| Personal account registrations | `workspace-zp4work` |
| Non-work email | `workspace-zp4work` |

## Tool Naming Pattern

Tools follow `mcp__workspace-{account}__action`:

**Work (ted.zhao.au):**
- `mcp__workspace-ted__search_drive_files` - search work files
- `mcp__workspace-ted__get_drive_file_content` - read work files
- `mcp__workspace-ted__search_gmail_messages` - search work email
- `mcp__workspace-ted__get_events` - work calendar
- `mcp__workspace-ted__list_tasks` - work tasks

**Personal (zp4work):**
- `mcp__workspace-zp4work__search_gmail_messages` - search personal email
- `mcp__workspace-zp4work__send_gmail_message` - send personal email

## Available Operations

Both accounts support:
- **Calendar**: list_calendars, get_events, create_event, modify_event
- **Gmail**: search_gmail_messages, get_gmail_message_content, send_gmail_message
- **Drive**: search_drive_files, get_drive_file_content, create_drive_file
- **Docs**: get_doc_content, create_doc, modify_doc_text
- **Sheets**: read_sheet_values, modify_sheet_values, create_spreadsheet
- **Tasks**: list_tasks, get_task, create_task, update_task

## Quick Examples

```
# Find work documents about "project X"
→ Use mcp__workspace-ted__search_drive_files

# Check personal email for order confirmations
→ Use mcp__workspace-zp4work__search_gmail_messages

# Schedule work meeting
→ Use mcp__workspace-ted__create_event
```
