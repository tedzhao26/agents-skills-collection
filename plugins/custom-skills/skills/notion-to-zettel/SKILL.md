---
name: notion-to-zettel
description: Use when syncing notes from Notion to local Zettelkasten vault. Triggers include "sync notion", "extract from notion", "import notes from notion", "pull from notion", "notion to obsidian".
---

# Notion to Zettelkasten Sync

Extract knowledge from Notion databases and create local Zettelkasten notes with proper tagging.

## When to Use

- Syncing Zettelkasten notes from company or personal Notion
- Extracting knowledge from Notion pages to local vault
- Batch importing notes with consistent formatting

## Prerequisites

- Notion MCP server configured (company or personal)
- Access to target Notion workspace

## Workflow

### Step 1: Search Notion for Content

```
Use mcp__Notion-company__notion-search or mcp__Notion-personal__notion-search
```

Search queries:
- For Zettelkasten database: `"Zettelkasten"`
- For specific topics: `"topic name"`
- With data source filter for database content

### Step 2: Identify the Database

Fetch the Zettelkasten page to find the database data source URL:

```
mcp__Notion-*__notion-fetch with the page ID
```

Look for `<data-source url="collection://...">` in the response.

### Step 3: Search Within Database

Search with the `data_source_url` parameter to get notes from the specific database:

```
query: "notes" or "*"
data_source_url: "collection://..."
```

### Step 4: Fetch Individual Notes

For each note of interest, fetch the full content:

```
mcp__Notion-*__notion-fetch with note ID
```

### Step 5: Filter Notes

**Include** (permanent knowledge):
- Technical how-tos
- Concepts and explanations
- Reference documentation
- Solutions to problems

**Exclude** (transient):
- Weekly TODOs
- Meeting notes (unless significant decisions)
- Interview notes (move to separate category)
- Empty or stub notes

### Step 6: Create Local Notes

For each note, create in `/Users/ted/workspace/notes/zettelkasten/`:

**Filename format:**
```
YYYYMMDDHHMM-kebab-case-title.md
```

**Template:**
```markdown
---
id: "YYYYMMDDHHMM"
title: Title Case Title
date: YYYY-MM-DD
tags:
  - source-tag (e.g., heidi, personal)
  - topic-tags
related:
  -
---

# Title Case Title

## Problem/Context

[Extract from Notion content]

## Solution/Insight

[Extract from Notion content]

## Implementation

[Extract code blocks, steps, etc.]

## References

[Extract links from Notion]
```

### Step 7: Ensure Tag Files Exist

**CRITICAL: After creating notes, verify all tags have corresponding files.**

1. List existing tags:
```bash
ls /Users/ted/workspace/notes/_meta/tags/
```

2. For each new tag, create `_meta/tags/{tag}.md`:
```markdown
---
tag: tag-name
aliases:
  - tag-name
---

# tag-name

Brief description.

## Notes

\```dataview
TABLE date, tags
FROM "zettelkasten"
WHERE contains(tags, "tag-name")
SORT date DESC
\```
```

3. Update `_meta/tags.md` master index with new tags under appropriate category.

## Source Tags

Always include a source tag to identify origin:

| Source | Tag | Description |
|--------|-----|-------------|
| Heidi Health Notion | `heidi` | Work-related knowledge |
| Personal Notion | `personal` | Personal knowledge base |
| External | `imported` | From other sources |

## Tag Categories

- **Technology**: `python`, `kubernetes`, `aws`, `langfuse`, etc.
- **Domain**: `devops`, `machine-learning`, `observability`, etc.
- **Tools**: `cli`, `ide`, `ai-tools`
- **Source**: `heidi`, `personal`, `imported`
- **Type**: `how-to`, `reference`, `concept`

## Example Usage

**User:** "Sync my Zettelkasten from company Notion with heidi tag"

**Actions:**
1. Search Notion for "Zettelkasten"
2. Fetch database to get data source URL
3. Search within database for all notes
4. Fetch each technical note
5. Create local notes with `heidi` tag + topic tags
6. Create missing tag files
7. Update master tag index

## Common Issues

| Issue | Solution |
|-------|----------|
| Can't find database | Search for "Zettelkasten" and fetch the page to find inline databases |
| Limited search results | Try different queries, search within data_source_url |
| Missing content | Some Notion blocks (buttons, embeds) don't extract - note these as TODOs |
| Duplicate notes | Check existing notes before creating |

## Notion MCP Servers

- **Company**: `mcp__Notion-company__*`
- **Personal**: `mcp__Notion-personal__*`

Available tools:
- `notion-search` - Search workspace
- `notion-fetch` - Get page/database content
