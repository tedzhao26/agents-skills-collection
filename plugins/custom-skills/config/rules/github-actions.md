---
paths: ".github/workflows/**/*.yml, .github/workflows/**/*.yaml, .github/actions/**/*.yml"
---

## GitHub Actions Rules

### Security
- **Use OIDC over static credentials** for cloud providers (AWS, Azure, GCP)
- **Pin actions to commit SHA**: `actions/checkout@a81bbbf...` not `@v4`
- Apply least privilege with `permissions:` block per workflow
- Use environment-specific secrets with required reviewers for production
- Never pass secrets via command-line arguments—use env vars or STDIN
- Never store secrets in workflow files

### Secret Management
- Repository secrets: project-specific credentials
- Environment secrets: require approval for production access
- Organization secrets: shared across repos with access policies
- Rotate secrets regularly, remove unused ones
- Consider external managers (Vault, Doppler) for enterprise

### Workflow Structure
```yaml
name: Descriptive Name
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read  # Minimal permissions

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15  # Always set timeout
    steps:
      - uses: actions/checkout@<SHA>
```

### Reusable Workflows
- Store in `.github/workflows/` as pipeline templates
- Composite actions for shared task templates
- Don't mix job orchestration into composite actions
- Supports 10 levels of nesting, 50 workflow calls per run

### Performance
- Set explicit `timeout-minutes` (default 6 hours is too long)
- Run independent jobs in parallel
- Use `needs:` for dependencies
- Cache dependencies aggressively
- Use `hashFiles()` in cache keys

### Caching
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Matrix Builds
- Use for testing across versions/platforms
- Apply `include`/`exclude` to avoid irrelevant combinations
- Cache dependencies within matrix runs
- Limit concurrent jobs for resource-heavy builds

### Best Practices
- Single-task focus: each action does one thing
- Test new actions in fork first
- Use relative paths (`./`) during development
- Specific trigger events to avoid unnecessary runs

### Hard Blocks (NEVER)
- Hardcoded secrets in workflow files
- Actions pinned to branches/tags (use SHA)
- `pull_request_target` with untrusted PR checkout
- Missing `permissions:` block
- Default 6-hour timeout for simple jobs
