---
name: doc-consistency-reviewer
description: Documentation consistency reviewer, checking consistency between code implementation and documentation. Use this skill when the user requests to review documentation and code consistency, check if README/docs are outdated, or verify API documentation accuracy. Applicable for (1) Reviewing consistency between README and implementation (2) Checking if docs/ directory documents are outdated (3) Verifying API/configuration documentation accuracy (4) Generating documentation consistency reports. Trigger words include doc review, documentation consistency, check outdated docs, verify docs.
---

# Documentation Consistency Reviewer

## Goal

Systematically identify all descriptions in README + docs/ that are "outdated" or "inconsistent with implementation", outputting ≥30 issue items.

## Core Principles

1. **Code as Truth** - When documentation conflicts with code, source code/configuration/contract files prevail
2. **Conclusion with Evidence** - Each issue must cite code/configuration location as evidence
3. **Contract First** - OpenAPI/proto/schema/TS types are considered SSOT
4. **Secure Defaults** - Security-related inconsistencies are prioritized as high severity

## Review Workflow

### 1. Document Enumeration

```bash
# Scan Scope
- README.md (Root directory)
- docs/**/*.md (All documents)
- Contract files: OpenAPI/proto/GraphQL schema/TS types
```

### 2. Document-by-Document Review

For each document:
1. List key declarations/promises/configurations/interface items
2. Search for corresponding implementation in code
3. Compare differences: Missing/Renamed/Behavior Inconsistent/Default Value Inconsistent
4. Record issue items according to template

### 3. Horizontal Cross-Check

- Check documentation reversely from contract files
- Check documentation reversely from configuration files

Detailed checklist see [references/checklist.md](references/checklist.md)

## Severity Levels

| Level | Definition | Example |
|------|------|------|
| P0 | Security Issue/Severe Misleading | Doc says sandbox enabled but code not enabled |
| P1 | Core Function Inconsistency | Following doc leads to failure |
| P2 | Incomplete Example/Naming Inconsistency | Does not directly block usage |
| P3 | Wording/Format/Link Minor Issues | Does not affect functionality |
| Evidence Pending | Suspected but insufficient evidence | Requires further investigation |

## Output Format

Detailed template see [references/output-format.md](references/output-format.md)

### Single Issue Item

```markdown
### [Title]
- **Severity**: P0/P1/P2/P3/Evidence Pending
- **Location**: `<File Path>:<Line Number>`
- **Evidence**:
  - Document: [Citation]
  - Code: [Citation]
- **Impact**: [Misleading Consequence]
- **Suggestion**: [Minimal Fix]
- **Related Principle**: Code as Truth/Contract First/Secure Defaults/...
```

### Review Conclusion

```markdown
## Review Conclusion
- **Conclusion**: Pass/Conditional Pass/Fail
- **Summary**: P0:x P1:x P2:x P3:x Pending:x
- **Fix Priority**: P0 → P1 → P2 → P3
```

## Multi-Agent Parallel

If acceleration is needed, split tasks to multiple agents by the following dimensions:

1. **Split by Document Type** - README, API docs, Developer guides each one agent
2. **Split by Module** - Different function modules docs each one agent
3. **Split by Check Direction** - One checks code from doc, one checks doc from code

When summarizing, deduplication and unification of severity levels are needed.

## Execution

After review completion, output `doc-consistency.md` report file.
