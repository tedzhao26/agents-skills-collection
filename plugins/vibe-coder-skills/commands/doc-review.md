---
description: Check consistency between documentation and code implementation
---

# Documentation Consistency Review

Systematically identify documentation that is outdated or inconsistent with the actual implementation.

## Usage

- `/doc-review` - Review README.md and docs/ against codebase
- `/doc-review src/api/` - Focus on API documentation consistency
- `/doc-review --contracts` - Prioritize OpenAPI/proto/schema files

## Core Principles

1. **Code as Truth** - Source code prevails over documentation
2. **Contract First** - OpenAPI/proto/GraphQL schemas are SSOT
3. **Evidence Required** - Each issue cites specific code location
4. **Security Priority** - Security-related inconsistencies are high severity

## What It Checks

| Category | Examples |
|----------|----------|
| **API Docs** | Endpoints, parameters, response schemas |
| **Config Docs** | Environment variables, settings |
| **Usage Examples** | Code snippets that no longer work |
| **Feature Claims** | Documented features vs actual implementation |

## Output

Issues categorized by severity with:
- Document location (file:line)
- Related code location (evidence)
- Specific inconsistency description
- Suggested fix

Now scanning documentation for consistency issues...
