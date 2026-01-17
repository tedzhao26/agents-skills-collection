---
paths: "**/*.tf, **/*.tfvars"
---

## Terraform Rules

### Naming Conventions
- Use `snake_case` everywhere (resources, variables, outputs, data sources)
- Use `_` (underscore) not `-` (dash) in Terraform identifiers
- Resource name = `this` if single resource of type, otherwise descriptive noun
- Don't repeat resource type in name: `aws_instance.web` not `aws_instance.web_instance`
- Output format: `{name}_{type}_{attribute}` (e.g., `vpc_id_primary`)
- Boolean variables: use positive names (`enable_encryption` not `disable_encryption`)
- Module repos: `terraform-<PROVIDER>-<NAME>` (e.g., `terraform-aws-vpc`)

### File Organization
- Keep resources in `main.tf` unless exceeding 150 lines
- Standard files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`
- Use `locals.tf` for complex local expressions
- Split into `iam.tf`, `networking.tf` etc. only when file exceeds 150 lines
- Nested modules in `modules/` subdirectory

### Variables & Outputs
- Always include `type` and `description` for every variable
- Always include `description` for every output
- Provide defaults for environment-independent values (disk size)
- Omit defaults for environment-specific values (project_id) to force explicit input
- Mark sensitive data with `sensitive = true`

### Version Constraints
- Pin Terraform version in `required_version`
- Pin provider versions with `~>` constraints (e.g., `~> 4.0`)
- Commit `.terraform.lock.hcl` to version control

### State Management
- Always use remote backend (S3, GCS, Azure Storage, Terraform Cloud)
- Enable state locking
- Encrypt at rest and in transit
- Separate state per environment (dev/staging/prod)
- Never store state in git
- Never manually edit `.tfstate` files
- Use `moved` blocks for refactors, not `terraform state mv`

### Security
- Never hardcode secrets in `.tf` files
- Use secret managers (Vault, AWS Secrets Manager)
- Mark sensitive outputs: `sensitive = true`
- Use `checkov` or `tfsec` for security scanning
- Pin and verify provider versions

### Validation
- Run `terraform fmt` before commit
- Run `terraform validate` in CI/CD
- Use TFLint for style enforcement
- Write tests with Terratest

### Hard Blocks (NEVER)
- Hardcoded credentials or secrets
- Local state for team projects
- Manual state file edits
- Unpinned provider versions
