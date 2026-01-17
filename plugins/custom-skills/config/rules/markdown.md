---
paths: "**/*.md"
---

## Markdown Rules

### Structure & Headings
- Single H1 (`#`) as document title only
- Limit depth to 4 levels (avoid H5/H6)
- Don't skip heading levels (H2 → H4)
- Capitalize with initial capitals (not ALL CAPS)
- Add blank lines before and after headings

### Code Blocks
- Always use fenced code blocks (triple backticks)
- Specify language identifier: ` ```python`
- Add blank lines before and after code blocks
- Use `diff` for code changes (`+` additions, `-` deletions)
- Common identifiers: `python`, `bash`, `json`, `yaml`, `javascript`, `typescript`

### Lists
- Use hyphens (`-`) for unordered lists consistently
- Use numbers (`1.`) for ordered lists
- One idea per list item
- Indent nested lists with 2 spaces

### Links & Images
- Use descriptive anchor text (not "click here")
- Format: `[descriptive text](url)`
- Include alt text for images: `![alt text](image.png)`
- Group related links in "References" section

### Tables
- Use for structured comparisons
- Include header row
- Align columns consistently
- Keep tables simple and scannable

### Readability
- Line length under 100 characters
- One paragraph = one central idea
- Use whitespace to separate sections
- Break walls of text with formatting

### README Structure
Standard sections in order:
1. Title (H1) + one-line description
2. Installation (with prerequisites)
3. Usage (with code examples)
4. Features
5. Contributing
6. License

### File Naming
- Use hyphens: `coding-guidelines.md` not `coding_guidelines.md`
- Lowercase filenames

### Consistency
- Pick one style and stick to it
- Same list marker throughout (`-` or `*`, not both)
- Same emphasis style (`*italic*` or `_italic_`, not both)
- Replace smart quotes with straight quotes

### Hard Blocks (NEVER)
- Skipping heading levels
- Multiple H1 headings
- "Click here" link text
- Walls of unformatted text
- Inconsistent list markers
