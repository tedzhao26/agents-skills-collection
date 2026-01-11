---
name: clean-code-reviewer
description: Analyze code quality based on "Clean Code" principles. Identify naming, function size, duplication, over-engineering, and magic number issues with severity ratings and refactoring suggestions. Use when the user requests code review, quality check, refactoring advice, Clean Code analysis, code smell detection, or mentions terms like code health check, code quality, refactoring check.
---

# Clean Code Review

Based on "Clean Code" principles, focusing on 5 high-yield check dimensions.

## Review Workflow

```
Review Progress:
- [ ] 1. Scan codebase: identify files to review
- [ ] 2. Check each dimension (naming, functions, DRY, YAGNI, magic numbers)
- [ ] 3. Rate severity (High/Medium/Low) for each issue
- [ ] 4. Generate report sorted by severity
```

## Check Dimensions

### 1. Naming Issues [Meaningful Naming]

Check flags:
- Meaningless names like `data1`, `temp`, `result`, `info`, `obj`
- Multiple names for same concept (mixing `get`/`fetch`/`retrieve`)

```typescript
// ❌
const d = new Date();
const data1 = fetchUser();

// ✅
const currentDate = new Date();
const userProfile = fetchUser();
```

### 2. Function Issues [Small Functions + SRP]

Check flags:
- Function exceeds **100 lines**
- Arguments exceed **3**
- Function does multiple things

```typescript
// ❌ 7 arguments
function processOrder(user, items, address, payment, discount, coupon, notes)

// ✅ Use parameter object
interface OrderParams { user: User; items: Item[]; shipping: Address; payment: Payment }
function processOrder(params: OrderParams)
```

### 3. Duplication Issues [DRY]

Check flags:
- Similar if-else structures
- Similar data transformation/error handling logic
- Copy-paste traces

### 4. Over-Engineering [YAGNI]

Check flags:
- `if (config.legacyMode)` branch that is never true
- Interface with only one implementation
- Useless try-catch or if-else

```typescript
// ❌ YAGNI violation: Compatibility code never used
if (config.legacyMode) {
  // 100 lines of compatibility code
}
```

### 5. Magic Numbers [Avoid Hardcoding]

Check flags:
- Naked numbers without explanation
- Hardcoded strings

```typescript
// ❌
if (retryCount > 3) // What is 3?
setTimeout(fn, 86400000) // How long is this?

// ✅
const MAX_RETRY_COUNT = 3;
const ONE_DAY_MS = 24 * 60 * 60 * 1000;
```

## Severity Levels

| Level | Standard |
|------|------|
| High | Affects maintainability/readability, should be fixed immediately |
| Medium | Room for improvement, suggested fix |
| Low | Code smell, optional optimization |

## Output Format

```markdown
### [Issue Type]: [Brief Description]

- **Principle**: [Clean Code Principle]
- **Location**: `File:Line Number`
- **Level**: High/Medium/Low
- **Issue**: [Specific Description]
- **Suggestion**: [Fix Direction]
```

## References

**Detailed examples**: See [references/detailed-examples.md](references/detailed-examples.md)
- Complete examples for each dimension (Naming, Functions, DRY, YAGNI, Magic Numbers)

**Language patterns**: See [references/language-patterns.md](references/language-patterns.md)
- TypeScript/JavaScript common issues
- Python common issues
- Go common issues

## Multi-Agent Parallel

Split tasks to multiple agents by the following dimensions:

1. **By Check Dimension** - One agent for each of the 5 dimensions
2. **By Module/Directory** - One agent for each different module
3. **By Language** - One agent for each of TypeScript, Python, Go

When summarizing, deduplication and unification of severity ratings are needed.
