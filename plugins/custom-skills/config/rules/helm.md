---
paths: "**/Chart.yaml, **/values.yaml, **/templates/**/*.yaml, **/templates/**/*.tpl"
---

## Helm Chart Rules

### Chart Structure
- Chart names: lowercase letters, numbers, start with letter, hyphens allowed
- Template files: `.yaml` for YAML output, `.tpl` for helpers
- Template names: dashed notation (`my-configmap.yaml` not `myConfigmap.yaml`)
- One resource per template file
- Helpers in `_helpers.tpl` (files starting with `_` don't output manifests)

### values.yaml
- Variable names: start lowercase, use camelCase
- Never hardcode values in templates—use values.yaml
- Include comments for documentation
- Separate RBAC and ServiceAccount under different keys
- Expose resource limits/requests as configurable with sensible defaults

### Template Helpers (_helpers.tpl)
- Namespace all defined template names to avoid subchart collisions
- Add documentation blocks (`{{/* ... */}}`) for each helper
- Common helpers: names, labels, selectors, annotations

### Labels (REQUIRED)
Always include standard `app.kubernetes.io` labels:
- `app.kubernetes.io/name` — application name
- `app.kubernetes.io/instance` — `{{ .Release.Name }}`
- `app.kubernetes.io/version` — `{{ .Chart.AppVersion }}`
- `app.kubernetes.io/managed-by` — `Helm`
- `helm.sh/chart` — `{{ .Chart.Name }}-{{ .Chart.Version }}`

### Security Context (REQUIRED)
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
```

### Resource Limits (REQUIRED)
Always define both requests and limits:
```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Reliability Features
- Include `livenessProbe` and `readinessProbe` for all deployments
- Define `PodDisruptionBudget` for critical workloads
- Configure `HorizontalPodAutoscaler` when applicable
- Set `topologySpreadConstraints` for multi-zone deployments

### Validation
- Run `helm lint` before deployment
- Use `helm template` for dry-run validation
- Use JSON Schema validation (Helm Schema plugin)
- Scan with Trivy or similar security tools
- Include tests in `templates/tests/`

### Hard Blocks (NEVER)
- Running containers as root
- Missing resource limits
- Hardcoded values in templates
- Using cluster-admin role unnecessarily
- Over-parameterization making templates unreadable
