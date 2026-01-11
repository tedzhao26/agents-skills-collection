# Output Format Template

## Report File Structure

```markdown
# Documentation Consistency Review Report

> Review Date: YYYY-MM-DD
> Project: [Project Name]
> Review Scope: README.md, docs/**/*.md

## Issues List

[Issue Item 1-N...]

## Review Conclusion

[Conclusion Summary...]
```

---

## Single Issue Item Template

```markdown
### [Index]. [One-sentence summary of the problem]

- **Severity**: P0 / P1 / P2 / P3 / Evidence Pending
- **Location**:
  - Document: `<File Path>:<Line Number>`
  - Code: `<File Path>:<Line Number>`
- **Evidence**:
  - Document Snippet:
    ```
    [Brief citation of relevant description]
    ```
  - Code Snippet:
    ```typescript
    [Brief citation of key implementation/configuration]
    ```
- **Impact**:
  - [How might it mislead users/callers/developers? What could be the consequences?]
- **Suggestion (Minimal Fix)**:
  - [Suggest modifying 'Document' or 'Code'? Provide the minimal viable fix direction]
- **Related Principle**:
  - [Code as Truth / Contract First / User Promise First / Secure Defaults / Terminology Consistency / Runnable & Reproducible]
```

---

## Review Conclusion Template

```markdown
## Review Conclusion

### Conclusion

- [ ] **Pass** - No P0/P1 issues
- [ ] **Conditional Pass** - Must fix the following prerequisites first:
  1. [Mandatory fix issue]
  2. ...
- [ ] **Fail** - Exists the following blocking items:
  1. [Blocking issue]
  2. ...

### Summary Statistics

| Level | Count |
|------|------|
| P0 Blocker | x |
| P1 Major | x |
| P2 Minor | x |
| P3 Nit | x |
| Evidence Pending | x |
| **Total** | **x** |

### Suggested Fix Priority

1. **Immediate Fix (P0)**:
   - #[Issue Index]: [Brief Description]
2. **Priority Fix (P1)**:
   - #[Issue Index]: [Brief Description]
3. **Planned Fix (P2)**:
   - #[Issue Index]: [Brief Description]
4. **Low Priority (P3)**:
   - Handle based on schedule

### Change Impact

| Impact Scope | Required | Explanation |
|----------|----------|------|
| Demo Update | Yes/No | [Specific Explanation] |
| Screenshot Update | Yes/No | [Specific Explanation] |
| Script Update | Yes/No | [Specific Explanation] |
| Changelog | Yes/No | [Specific Explanation] |
| External Notification | Yes/No | [Specific Explanation] |
```

---

## Example Issue Items

### 1. contextIsolation security configuration inconsistent with documentation description

- **Severity**: P0
- **Location**:
  - Document: `docs/security.md:45`
  - Code: `src/main/window.ts:23`
- **Evidence**:
  - Document Snippet:
    ```
    All renderer processes have contextIsolation enabled, ensuring preload scripts are isolated from page scripts
    ```
  - Code Snippet:
    ```typescript
    webPreferences: {
      contextIsolation: false, // Actually not enabled
      nodeIntegration: true
    }
    ```
- **Impact**:
  - Users/Auditors will mistakenly believe the application has security isolation enabled, while actually risking XSS attacks
- **Suggestion (Minimal Fix)**:
  - Modify code to set `contextIsolation` to `true`, and expose necessary APIs through preload scripts
- **Related Principle**:
  - Secure Defaults, Code as Truth

---

### 2. API endpoint /api/users return fields inconsistent with documentation

- **Severity**: P1
- **Location**:
  - Document: `docs/api.md:120`
  - Code: `src/routes/users.ts:45`
- **Evidence**:
  - Document Snippet:
    ```
    Return fields: id, name, email, createdAt, updatedAt
    ```
  - Code Snippet:
    ```typescript
    return { id, name, email, created_at, updated_at }; // snake_case
    ```
- **Impact**:
  - Frontend using camelCase according to documentation will fail to get values
- **Suggestion (Minimal Fix)**:
  - Update documentation to mark actual field names as snake_case
- **Related Principle**:
  - Code as Truth, Terminology Consistency
