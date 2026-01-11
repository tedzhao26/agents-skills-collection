---
name: notion
description: Comprehensive Notion workspace skills for Claude. Includes meeting intelligence, research and documentation, knowledge capture, and spec-to-implementation workflows. Use when working with Notion pages, databases, wikis, or task management.
---

# Notion Skills

A comprehensive collection of skills for working with Notion workspaces. These skills help you complete entire workflows - from meeting prep to research documentation to implementation tracking.

## Capabilities

| Capability | Description |
|------------|-------------|
| [Meeting Intelligence](#meeting-intelligence) | Prepare meeting materials with context from Notion |
| [Research & Documentation](#research--documentation) | Search, synthesize, and create structured reports |
| [Knowledge Capture](#knowledge-capture) | Turn conversations into wiki pages and decision records |
| [Spec to Implementation](#spec-to-implementation) | Transform specs into tasks with progress tracking |

## Quick Reference

### Notion Tools

| Tool | Purpose |
|------|---------|
| `Notion:notion-search` | Find pages and databases |
| `Notion:notion-fetch` | Read page/database content |
| `Notion:notion-create-pages` | Create new pages |
| `Notion:notion-update-page` | Update existing pages |

---

## Meeting Intelligence

Prepares you for meetings by gathering context from Notion, enriching it with Claude research, and creating comprehensive meeting materials.

### Workflow

1. **Gather Notion context**: Use `Notion:notion-search` to find related pages
2. **Fetch details**: Use `Notion:notion-fetch` to read relevant content
3. **Enrich with research**: Add context, industry insights, or best practices
4. **Create internal pre-read**: Background document for attendees
5. **Create external agenda**: Meeting agenda for all participants
6. **Link resources**: Connect docs to related projects

### Output Documents

**Internal Pre-Read** (for team):
- Meeting Overview, Background Context, Current Status
- Context & Insights, Key Discussion Points
- What We Need from This Meeting

**External Agenda** (for all participants):
- Meeting Details, Objective
- Agenda Items (with time allocations)
- Discussion Topics, Decisions Needed, Action Items

See [references/meeting-intelligence/](references/meeting-intelligence/) for templates.

---

## Research & Documentation

Enables comprehensive research workflows: search across your Notion workspace, synthesize findings, and create well-structured documentation.

### Workflow

1. **Search for relevant content**: Use `Notion:notion-search` to find pages
2. **Fetch detailed information**: Use `Notion:notion-fetch` to read full content
3. **Synthesize findings**: Analyze and combine from multiple sources
4. **Create structured output**: Use `Notion:notion-create-pages` to write documentation

### Output Formats

| Format | Use Case |
|--------|----------|
| Quick Brief | Fast turnaround, key points only |
| Research Summary | Balanced depth and brevity |
| Comprehensive Report | Deep analysis with full citations |

See [references/research-documentation/](references/research-documentation/) for format guides.

---

## Knowledge Capture

Transforms conversations and discussions into structured documentation. Captures insights, decisions, and knowledge from chat context.

### Workflow

1. **Extract content**: Identify key information from conversation
2. **Structure information**: Organize into appropriate documentation format
3. **Determine location**: Find appropriate wiki page/database
4. **Create page**: Save content with proper formatting
5. **Make discoverable**: Link from hub pages, add to databases

### Content Types

| Type | Structure |
|------|-----------|
| Concept | Definition, Characteristics, Examples, Use Cases |
| How-To | Prerequisites, Steps, Verification, Troubleshooting |
| Decision | Context, Decision, Rationale, Options, Consequences |
| FAQ | Short Answer, Detailed Explanation, Examples |
| Learning | What Happened, What Went Well/Didn't, Root Causes, Actions |

See [references/knowledge-capture/](references/knowledge-capture/) for database schemas.

---

## Spec to Implementation

Transforms specifications into actionable implementation plans with progress tracking. Creates tasks and manages implementation workflow.

### Workflow

1. **Find spec**: Use `Notion:notion-search` to locate specification
2. **Fetch spec**: Read specification content
3. **Extract requirements**: Parse and structure requirements
4. **Create plan**: Implementation plan with phases
5. **Find task database**: Locate task tracking system
6. **Create tasks**: Individual tasks with acceptance criteria
7. **Track progress**: Log progress and update status

### Task Breakdown Patterns

- **By Component**: Database, API, frontend, integration, testing
- **By Feature Slice**: Vertical slices (auth flow, data entry, etc.)
- **By Priority**: P0 (must have), P1 (important), P2 (nice to have)

See [references/spec-to-implementation/](references/spec-to-implementation/) for planning templates.

---

## Best Practices

1. **Cast a wide net first**: Start with broad searches, then narrow
2. **Cite sources**: Always link back to source pages
3. **Verify recency**: Check page last-edited dates
4. **Cross-reference**: Validate findings across multiple sources
5. **Structure clearly**: Use headings, bullets, and formatting
6. **Link bidirectionally**: Maintain forward and backward links

## Common Issues

| Issue | Solution |
|-------|----------|
| "No results found" | Try broader search terms or different teamspaces |
| "Too many results" | Add filters or search within specific pages |
| "Can't access page" | User may lack permissions, ask to verify |
| "Content too large" | Break into sections, summarize key points |

## Examples

See [examples/](examples/) for complete workflow demonstrations.
