---
name: zettelkasten-note
description: Use when persisting knowledge, capturing learnings, documenting solutions, or creating reference notes. Triggers include "create note", "save this", "document", "remember", "persist knowledge", "write down", "capture learning", "obsidian", "obsidian note".
---

# Zettelkasten Note Creation

Create atomic, linkable notes following Zettelkasten principles to persist knowledge.

## Notes Directory

```
/Users/ted/workspace/notes/zettelkasten/
```

## Vault Structure

```
notes/                              # Vault root
├── _meta/
│   ├── tags.md                     # Master tag index (Dataview)
│   ├── tags/                       # Individual tag pages
│   │   └── {tag}.md
│   └── templates/                  # Templater templates
│       └── zettel.md
├── attachments/                    # Images, files
├── zettelkasten/                   # Atomic notes
│   └── {YYYYMMDDHHMM}-{title}.md
└── CLAUDE.md
```

## Note Structure

### Filename Format

```
YYYYMMDDHHMM-kebab-case-title.md
```

Example: `202601021430-serena-mcp-auto-activation.md`

### Template (Templater syntax)

The `_meta/templates/zettel.md` template:
- Prompts for title in kebab-case
- Auto-generates timestamp ID
- Auto-renames file to `{timestamp}-{title}.md`
- Auto-fills frontmatter and heading

```markdown
<%*
const title = await tp.system.prompt("Note title (kebab-case):");
const timestamp = tp.date.now("YYYYMMDDHHmm");
const filename = `${timestamp}-${title}`;
await tp.file.rename(filename);
-%>
---
id: "<% timestamp %>"
title: <% title.split("-").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ") %>
date: <% tp.date.now("YYYY-MM-DD") %>
state: permanent
tags:
  -
related:
  -
---

# <% title.split("-").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ") %>

## Problem/Context


## Solution/Insight


## Implementation


## References

```

### Related Field Format

**IMPORTANT:** The `related` field must use quoted wikilinks:

```yaml
# Correct format
related:
  - "[[202601021430-serena-mcp-auto-activation]]"
  - "[[202601051030-claude-code-skills-inventory]]"

# Empty (no related notes yet)
related:
  -
```

**DO NOT use these formats:**
```yaml
# Wrong - inline array
related: []

# Wrong - unquoted
related:
  - [[note-id]]

# Wrong - plain text
related:
  - 202601021430-serena-mcp-auto-activation
```

## Zettelkasten Principles

| Principle | Application |
|-----------|-------------|
| **Atomicity** | One idea per note |
| **Autonomy** | Note stands alone without context |
| **Linking** | Connect via `related` field and `[[wikilinks]]` |
| **Tags** | 3-5 descriptive tags for discovery |

## Note States

The `state` field tracks note maturity through the Zettelkasten workflow:

| State | Description | When to Use |
|-------|-------------|-------------|
| `fleeting` | Quick capture, rough ideas | Initial brain dumps, unprocessed thoughts |
| `literature` | Notes from external sources | Summaries from articles, books, videos |
| `permanent` | Refined, atomic, standalone | Processed knowledge ready for linking |

### State Workflow

```
fleeting → literature → permanent
   ↓           ↓            ↓
 Quick      Process      Refine &
capture    & extract      link
```

**Guidelines:**
- **Claude-created notes** default to `permanent` (already processed/refined)
- **Manual quick captures** start as `fleeting`
- **Reading notes** start as `literature`
- Periodically review `fleeting` and `literature` notes to promote to `permanent`

### Dataview Query for Unprocessed Notes

```dataview
TABLE date, state
FROM "zettelkasten"
WHERE state != "permanent"
SORT date ASC
```

## Tag Categories

- **Technology**: `python`, `terraform`, `mcp`, `claude-code`, `codex`, `cursor`, `obsidian`, `kubernetes`, `eks`, `aws`, `ecr`, `github`, `github-actions`, `langfuse`, `mlflow`
- **Domain**: `devops`, `cicd`, `security`, `architecture`, `observability`, `tracing`, `machine-learning`, `llm`, `evaluation`
- **Tools**: `cli`, `ide`, `ai-tools`
- **Source**: `heidi` (work-related knowledge)
- **Type**: `how-to`, `reference`, `troubleshooting`, `concept`

## Dynamic Tag Pages (Obsidian + Dataview)

Tag pages use aliases so `[[tag-name]]` links work directly.

### Individual Tag Page Template (`_meta/tags/{tag}.md`)

```markdown
---
tag: tag-name
aliases:
  - tag-name
---

# tag-name

Brief description of what this tag covers.

## Notes

\```dataview
TABLE date, state, tags
FROM "zettelkasten"
WHERE contains(tags, "tag-name")
SORT date DESC
\```
```

**Important:** The `FROM "zettelkasten"` targets the `zettelkasten/` folder where atomic notes live.

### When to Create Tag Pages

- Tag has 3+ notes
- You want to add context/description for the tag
- Tag represents a significant topic area

## Quick Reference

| Element | Format |
|---------|--------|
| ID | Timestamp `YYYYMMDDHHMM` |
| Filename | `{id}-{kebab-title}.md` |
| Location | `zettelkasten/` folder |
| State | `fleeting`, `literature`, or `permanent` |
| Tags | 3-5 lowercase, hyphenated |
| Links | `[[tag]]` or `[[id-title]]` wikilinks |
| Tag pages | `_meta/tags/{tag}.md` |
| Attachments | `attachments/` folder |

## Workflow

1. **Create note** - `Cmd+N` in Obsidian, enter kebab-case title when prompted
2. **Add 3-5 tags** from tag categories
3. **Link related notes** via `related:` field or inline `[[wikilinks]]`
4. **Ensure tag files exist** - Create missing tag pages in `_meta/tags/`
5. **Update master index** - Add new tags to `_meta/tags.md` under appropriate category

## REQUIRED: Ensure Tag Files Exist

**After creating any note, you MUST verify and create tag files for ALL tags used.**

### Step 1: Check Existing Tag Files

```bash
ls /Users/ted/workspace/notes/_meta/tags/
```

### Step 2: For Each Missing Tag, Create Tag File

Create `_meta/tags/{tag-name}.md`:

```markdown
---
tag: tag-name
aliases:
  - tag-name
---

# tag-name

Brief description of what this tag covers.

## Notes

\```dataview
TABLE date, state, tags
FROM "zettelkasten"
WHERE contains(tags, "tag-name")
SORT date DESC
\```
```

### Step 3: Update Master Tag Index

Add the new tag to `_meta/tags.md` under the appropriate category:

- **Technology**: Tools, languages, platforms (e.g., `python`, `kubernetes`, `aws`)
- **Domain**: Subject areas (e.g., `devops`, `security`, `machine-learning`)
- **Tools**: Specific tools (e.g., `cli`, `ide`, `ai-tools`)
- **Source**: Origin of knowledge (e.g., `heidi`, `personal`)
- **Type**: Note type (e.g., `how-to`, `reference`, `concept`)

### Example: Creating Note with New Tags

If creating a note with tags: `kubernetes`, `aws`, `new-tag`

1. Check if `_meta/tags/kubernetes.md` exists - if not, create it
2. Check if `_meta/tags/aws.md` exists - if not, create it
3. Check if `_meta/tags/new-tag.md` exists - if not, create it
4. Update `_meta/tags.md` to include any new tags in appropriate categories

## Common Mistakes

- **Too broad**: Break into multiple atomic notes
- **Missing context**: Note should be understandable standalone
- **No tags**: Always add 3-5 tags for discoverability
- **No state**: Always set `state` field (`fleeting`, `literature`, `permanent`)
- **Generic titles**: Be specific - "Serena Auto-Activation" not "MCP Setup"
- **Orphan notes**: Link to related notes for discoverability
- **Missing alias**: Tag pages need `aliases:` for `[[tag]]` linking to work
- **Wrong Dataview FROM**: Use `FROM "zettelkasten"` not `FROM ""`
- **Missing tag files**: ALWAYS create tag files for ALL tags used in notes
- **Forgetting master index**: ALWAYS add new tags to `_meta/tags.md`

## Required Obsidian Plugins

- **Templater** - Auto-generates filenames and fills templates
- **Dataview** - Powers dynamic tag pages

## Reference

- [Zettelkasten in Obsidian Video Guide](https://www.youtube.com/watch?v=E6ySG7xYgjY)
