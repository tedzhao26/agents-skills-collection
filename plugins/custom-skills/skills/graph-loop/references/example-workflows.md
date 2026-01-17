# Graph-Loop Example Workflows

Ready-to-use workflow templates for common patterns.

---

## 0. Hook-Driven Simple Loop (Fastest Start)

The simplest way to use graph-loop with automatic iteration via the stop hook.

**No YAML needed!** The setup script creates the workflow:

```bash
# Start a hook-driven loop
# Use full path or CLAUDE_SKILL_ROOT env var
~/.claude/skills/graph-loop/scripts/setup-graph-loop.sh \
  --simple "Build a REST API with CRUD operations for todos" \
  --mode hook-driven \
  --completion-promise "TASK COMPLETE" \
  --max-iterations 10
```

This creates a simple implement→review workflow:

```yaml
# Auto-generated workflow
workflow: loop-20260117-123456
nodes:
  implement:
    type: task
    agent: self
    prompt: |
      Build a REST API with CRUD operations for todos

      Work on the task. When done, indicate completion status.
      Use [OUTPUT:done] when complete, [OUTPUT:needs_work] if more needed.
    outputs: [done, needs_work]

  review:
    type: task
    agent: self
    prompt: |
      Review the implementation critically.
      Output ONE of: P0, P1, P2, or clean.
    outputs: [P0, P1, P2, clean]

edges:
  - from: START
    to: implement
  - from: implement
    to: review
    condition: "done"
  - from: review
    to: implement
    condition: "any(P0, P1)"
  - from: review
    to: END
    condition: "any(P2, clean)"
```

**How it works:**

1. You work on the implement task
2. Try to exit → hook intercepts
3. Hook detects your output (done/P0/P1/P2/clean)
4. Hook feeds next node's prompt back
5. Loop continues until clean/P2 or max iterations

**To complete the loop:** Output `<promise>TASK COMPLETE</promise>` when the statement is genuinely true.

---

## 1. Simple Sequential: Implement → Review → Done

Basic iterative refinement with quality gate.

```yaml
workflow: simple-implement-review
description: Implement feature with review loop until clean

nodes:
  implement:
    type: task
    agent: self
    prompt: |
      Implement the feature based on requirements.
      
      Requirements: (user provides via state.requirements)
    outputs: [done]
  
  review:
    type: task
    agent: codex
    prompt: |
      Review the implementation and output ONE of:
      - P0: Critical issues (security, correctness, major bugs)
      - P1: Should fix (bugs, violations, missing tests)
      - P2: Nice to have (optimizations, style tweaks)
      - clean: No issues, ready to ship
      
      For P0/P1/P2, list specific issues found.
    outputs: [P0, P1, P2, clean]

edges:
  - from: START
    to: implement
  
  - from: implement
    to: review
    condition: "done"
  
  # Critical or should-fix → loop back
  - from: review
    to: implement
    condition: "any(P0, P1)"
  
  # Nice-to-have → done (user can decide)
  - from: review
    to: END
    condition: "any(P2, clean)"

limits:
  max_iterations: 5
  max_time_minutes: 30

completion:
  - review.clean
  - review.P2
```

**Usage:**

```bash
# Save workflow
cat > /tmp/simple-workflow.yaml << 'YAML'
[paste above]
YAML

# Execute with initial state
/graph-loop /tmp/simple-workflow.yaml
state:
  initial:
    requirements: "Add user authentication with JWT tokens"
```

---

## 2. Iterative Self-Improvement (Ralph-Style)

Autonomous refinement with quality scoring and automatic retry.

```yaml
workflow: ralph-style-iteration
description: Iterative self-improvement with quality scoring

state:
  variables:
    best_score: 0
    attempt_count: 0
    target_score: 9
    last_feedback: ""

nodes:
  implement:
    type: task
    agent: self
    prompt: |
      Implement the feature.
      
      Target: (user provides via state.target)
      Previous attempt score: (reference state.best_score)/10
      Previous feedback: (reference state.last_feedback)
      
      Improve based on feedback.
    outputs: [done]
    on_output:
      done:
        set:
          attempt_count: output
  
  self_review:
    type: task
    agent: self
    prompt: |
      Review your own implementation critically.
      
      Score from 1-10 on:
      - Correctness (does it work?)
      - Completeness (handles edge cases?)
      - Code quality (readable, maintainable?)
      - Test coverage (adequate tests?)
      
      Output format:
      SCORE: X/10
      FEEDBACK: [specific improvements needed]
      
      Be honest and critical.
    outputs: [scored]
    on_output:
      scored:
        set:
          # Parse score from agent output
          current_score: output
          last_feedback: output
  
  check_quality:
    type: decision
    condition: "state.current_score >= state.target_score"
    outputs: [pass, fail]
    on_output:
      pass:
        set:
          best_score: output
  
  check_attempts:
    type: decision
    condition: "state.attempt_count >= 5"
    outputs: [max_reached, continue]

edges:
  - from: START
    to: implement
  
  - from: implement
    to: self_review
    condition: "done"
  
  - from: self_review
    to: check_quality
    condition: "scored"
  
  # Quality target met → done
  - from: check_quality
    to: END
    condition: "pass"
  
  # Quality not met → check attempts
  - from: check_quality
    to: check_attempts
    condition: "fail"
  
  # Under limit → retry
  - from: check_attempts
    to: implement
    condition: "continue"
  
  # Max attempts → done (best effort)
  - from: check_attempts
    to: END
    condition: "max_reached"

limits:
  max_iterations: 20
  max_time_minutes: 60

completion:
  - check_quality.pass
  - check_attempts.max_reached
```

**Usage:**

```bash
# Execute with initial state
/graph-loop /tmp/ralph-workflow.yaml
state:
  initial:
    target: "Implement rate limiting middleware"
```

---

## 3. Parallel Research with Quality Gate

Fan-out research → aggregate → implement → review loop.

```yaml
workflow: parallel-research-implement
description: Research multiple approaches in parallel, then implement best option

state:
  variables:
    approaches_evaluated: []
    recommended_approach: ""
    implementation_attempts: 0

nodes:
  # Fan-out to parallel research
  research:
    type: parallel
    branches:
      - research_approach_a
      - research_approach_b
      - research_approach_c
    outputs: [all_done]
  
  research_approach_a:
    type: task
    agent: gemini
    prompt: |
      Research Approach A: (user provides via state.approach_a_description)
      
      Evaluate:
      - Feasibility
      - Performance implications
      - Maintenance burden
      - Security considerations
      
      Output structured findings.
    outputs: [done]
    timeout_minutes: 5
    on_output:
      done:
        append:
          approaches_evaluated: "approach_a"
  
  research_approach_b:
    type: task
    agent: gemini
    prompt: |
      Research Approach B: (user provides via state.approach_b_description)
      
      [same evaluation criteria]
    outputs: [done]
    timeout_minutes: 5
    on_output:
      done:
        append:
          approaches_evaluated: "approach_b"
  
  research_approach_c:
    type: task
    agent: gemini
    prompt: |
      Research Approach C: (user provides via state.approach_c_description)
      
      [same evaluation criteria]
    outputs: [done]
    timeout_minutes: 5
    on_output:
      done:
        append:
          approaches_evaluated: "approach_c"
  
  # Aggregate findings
  aggregate:
    type: join
    wait_for:
      - research_approach_a
      - research_approach_b
      - research_approach_c
    agent: self
    prompt: |
      Compare all research findings.
      
      Recommend the best approach based on:
      1. Security
      2. Performance
      3. Maintainability
      4. Implementation complexity
      
      Output: RECOMMEND: [approach_a|approach_b|approach_c]
    outputs: [recommendation_ready]
    on_output:
      recommendation_ready:
        set:
          # Parse recommendation from agent output
          recommended_approach: output
  
  # Checkpoint after research
  save_research:
    type: checkpoint
    outputs: [done]
  
  # Implement chosen approach
  implement:
    type: task
    agent: self
    prompt: |
      Implement using recommended approach: (reference state.recommended_approach)
      
      Include:
      - Core implementation
      - Error handling
      - Tests
      - Documentation
    outputs: [done]
    on_output:
      done:
        set:
          implementation_attempts: output
  
  # Quality review
  review:
    type: task
    agent: codex
    prompt: |
      Review implementation of (reference state.recommended_approach).
      
      Check:
      - Correctness
      - Test coverage
      - Error handling
      - Code quality
      
      Output severity: P0/P1/P2/clean
    outputs: [P0, P1, P2, clean]

edges:
  - from: START
    to: research
  
  - from: research
    to: aggregate
    condition: "all_done"
  
  - from: aggregate
    to: save_research
    condition: "recommendation_ready"
  
  - from: save_research
    to: implement
  
  - from: implement
    to: review
    condition: "done"
  
  # Issues found → loop back (max 3 attempts)
  - from: review
    to: implement
    condition: "any(P0, P1) && state.implementation_attempts < 3"
  
  # Clean or max attempts → done
  - from: review
    to: END
    condition: "any(P2, clean)"

limits:
  max_iterations: 25
  max_time_minutes: 90

interrupts:
  - after: aggregate
    prompt: |
      Research complete. Recommended: (reference state.recommended_approach)
      
      Review findings before implementing?
    required: false

completion:
  - review.clean
  - review.P2
```

**Usage:**

```bash
# Execute with approach descriptions
/graph-loop /tmp/parallel-research.yaml
state:
  initial:
    approach_a_description: "Use third-party OAuth library"
    approach_b_description: "Implement custom JWT solution"
    approach_c_description: "Use session-based authentication"
```

---

## 4. TDD with Spec Compliance (Two-Stage Review)

Test-driven development with separate spec and quality reviews.

```yaml
workflow: tdd-with-spec-compliance
description: Implement with TDD, verify spec compliance and code quality separately

state:
  variables:
    spec_compliance_score: 0
    code_quality_score: 0
    test_pass_count: 0
    iteration_count: 0
    last_spec_issues: ""
    last_quality_issues: ""

nodes:
  # Write tests first
  write_tests:
    type: task
    agent: self
    prompt: |
      Write tests for the requirements.
      
      Requirements: (user provides via state.requirements)
      
      Follow TDD: write tests that define expected behavior.
    outputs: [done]
  
  # Implement to pass tests
  implement:
    type: task
    agent: self
    prompt: |
      Implement to pass the tests.
      
      Previous spec issues: (reference state.last_spec_issues)
      Previous quality issues: (reference state.last_quality_issues)
    outputs: [done]
    on_output:
      done:
        set:
          iteration_count: output
  
  # Run tests
  run_tests:
    type: task
    agent: bash
    command: "npm test -- --coverage --json > /tmp/test-results.json && cat /tmp/test-results.json"
    outputs: [pass, fail]
    on_output:
      pass:
        set:
          # Parse pass count from test output
          test_pass_count: output
  
  # Stage 1: Spec compliance review
  spec_review:
    type: task
    agent: codex
    prompt: |
      Review ONLY for spec compliance.
      
      Does the implementation meet ALL requirements?
      - Missing features?
      - Incorrect behavior?
      - Edge cases not handled?
      
      Ignore code quality issues (separate review).
      
      Output severity: P0/P1/P2/clean
    outputs: [P0, P1, P2, clean]
    on_output:
      clean:
        set:
          spec_compliance_score: 10
      P2:
        set:
          spec_compliance_score: 8
          last_spec_issues: output
      P1:
        set:
          spec_compliance_score: 5
          last_spec_issues: output
      P0:
        set:
          spec_compliance_score: 0
          last_spec_issues: output
  
  # Stage 2: Code quality review
  quality_review:
    type: task
    agent: codex
    prompt: |
      Review ONLY for code quality.
      
      Check:
      - Code structure and organization
      - Error handling
      - Test quality and coverage
      - Documentation
      - Performance considerations
      
      Assume spec compliance is already verified.
      
      Output severity: P0/P1/P2/clean
    outputs: [P0, P1, P2, clean]
    on_output:
      clean:
        set:
          code_quality_score: 10
      P2:
        set:
          code_quality_score: 8
          last_quality_issues: output
      P1:
        set:
          code_quality_score: 5
          last_quality_issues: output
      P0:
        set:
          code_quality_score: 0
          last_quality_issues: output
  
  # Decision: both reviews pass?
  check_reviews:
    type: decision
    condition: "state.spec_compliance_score >= 8 && state.code_quality_score >= 8"
    outputs: [pass, fail]

edges:
  - from: START
    to: write_tests
  
  - from: write_tests
    to: implement
    condition: "done"
  
  - from: implement
    to: run_tests
    condition: "done"
  
  # Tests fail → fix implementation
  - from: run_tests
    to: implement
    condition: "fail"
  
  # Tests pass → spec review
  - from: run_tests
    to: spec_review
    condition: "pass"
  
  # Spec issues → fix implementation
  - from: spec_review
    to: implement
    condition: "any(P0, P1)"
  
  # Spec OK → quality review
  - from: spec_review
    to: quality_review
    condition: "any(P2, clean)"
  
  # Quality issues → fix implementation
  - from: quality_review
    to: implement
    condition: "any(P0, P1)"
  
  # Quality OK → check both reviews
  - from: quality_review
    to: check_reviews
    condition: "any(P2, clean)"
  
  # Both pass → done
  - from: check_reviews
    to: END
    condition: "pass"
  
  # Either review has minor issues → implement again
  - from: check_reviews
    to: implement
    condition: "fail"

limits:
  max_iterations: 15
  max_time_minutes: 60

interrupts:
  - after: spec_review
    condition: "state.spec_compliance_score < 8 && state.iteration_count >= 3"
    prompt: |
      Spec compliance issues after 3 iterations.
      
      Issues: (reference state.last_spec_issues)
      
      Continue refining?
    required: false

completion:
  - check_reviews.pass
```

**Usage:**

```bash
# Execute with requirements
/graph-loop /tmp/tdd-workflow.yaml
state:
  initial:
    requirements: "$(cat docs/requirements.md)"
```

---

## 5. Multi-Environment Deployment Pipeline

Deploy through dev → staging → production with approval gates.

```yaml
workflow: deployment-pipeline
description: Deploy through multiple environments with approval gates

state:
  variables:
    current_environment: ""
    deployment_version: ""
    rollback_required: false

nodes:
  # Build
  build:
    type: task
    agent: bash
    command: "npm run build && npm run test"
    outputs: [success, failure]
    on_output:
      success:
        set:
          # Parse version from build output
          deployment_version: output
  
  # Deploy to dev
  deploy_dev:
    type: task
    agent: bash
    command: "deploy.sh dev (reference state.deployment_version)"
    outputs: [success, failure]
    on_output:
      success:
        set:
          current_environment: "dev"
  
  # Smoke test dev
  test_dev:
    type: task
    agent: bash
    command: "smoke-test.sh dev"
    outputs: [pass, fail]
  
  # Approve staging
  approve_staging:
    type: human
    prompt: |
      Dev deployment successful.
      Version: (reference state.deployment_version)
      
      Proceed to staging? (yes/no)
    outputs: [yes, no]
    timeout_minutes: 60
  
  # Deploy to staging
  deploy_staging:
    type: task
    agent: bash
    command: "deploy.sh staging (reference state.deployment_version)"
    outputs: [success, failure]
    on_output:
      success:
        set:
          current_environment: "staging"
  
  # Integration tests staging
  test_staging:
    type: task
    agent: bash
    command: "integration-test.sh staging"
    outputs: [pass, fail]
  
  # Approve production
  approve_production:
    type: human
    prompt: |
      Staging deployment successful.
      Version: (reference state.deployment_version)
      Environment: (reference state.current_environment)
      
      DEPLOY TO PRODUCTION? (yes/no)
    outputs: [yes, no]
    timeout_minutes: 1440  # 24 hours
  
  # Checkpoint before production
  checkpoint_production:
    type: checkpoint
    outputs: [done]
  
  # Deploy to production
  deploy_production:
    type: task
    agent: bash
    command: "deploy.sh production (reference state.deployment_version)"
    outputs: [success, failure]
    on_output:
      success:
        set:
          current_environment: "production"
  
  # Smoke test production
  test_production:
    type: task
    agent: bash
    command: "smoke-test.sh production"
    outputs: [pass, fail]
  
  # Rollback if needed
  rollback:
    type: task
    agent: bash
    command: "rollback.sh (reference state.current_environment)"
    outputs: [done]
    on_output:
      done:
        set:
          rollback_required: true

edges:
  - from: START
    to: build
  
  # Build failure → end
  - from: build
    to: END
    condition: "failure"
  
  # Build success → deploy dev
  - from: build
    to: deploy_dev
    condition: "success"
  
  # Dev deploy failure → end
  - from: deploy_dev
    to: END
    condition: "failure"
  
  # Dev deploy success → test
  - from: deploy_dev
    to: test_dev
    condition: "success"
  
  # Dev test fail → end
  - from: test_dev
    to: END
    condition: "fail"
  
  # Dev test pass → approve staging
  - from: test_dev
    to: approve_staging
    condition: "pass"
  
  # Staging denied → end
  - from: approve_staging
    to: END
    condition: "no"
  
  # Staging approved → deploy
  - from: approve_staging
    to: deploy_staging
    condition: "yes"
  
  # Staging deploy failure → end
  - from: deploy_staging
    to: END
    condition: "failure"
  
  # Staging deploy success → test
  - from: deploy_staging
    to: test_staging
    condition: "success"
  
  # Staging test fail → end
  - from: test_staging
    to: END
    condition: "fail"
  
  # Staging test pass → approve production
  - from: test_staging
    to: approve_production
    condition: "pass"
  
  # Production denied → end
  - from: approve_production
    to: END
    condition: "no"
  
  # Production approved → checkpoint
  - from: approve_production
    to: checkpoint_production
    condition: "yes"
  
  # Checkpoint → deploy production
  - from: checkpoint_production
    to: deploy_production
  
  # Production deploy failure → rollback
  - from: deploy_production
    to: rollback
    condition: "failure"
  
  # Production deploy success → test
  - from: deploy_production
    to: test_production
    condition: "success"
  
  # Production test fail → rollback
  - from: test_production
    to: rollback
    condition: "fail"
  
  # Production test pass → done
  - from: test_production
    to: END
    condition: "pass"
  
  # Rollback complete → end
  - from: rollback
    to: END

limits:
  max_iterations: 30
  max_time_minutes: 1500  # 25 hours

interrupts:
  - before: deploy_production
    prompt: "FINAL CHECK: Deploy to production now?"
    required: true

completion:
  - test_production.pass
```

**Usage:**

```bash
# Execute deployment pipeline
/graph-loop /tmp/deploy-pipeline.yaml
```

---

## Tips for Creating Custom Workflows

### 1. Start Simple

Begin with a linear workflow, then add loops and branches:

```yaml
# Linear first
START → implement → review → END

# Then add loop
START → implement → review → (if issues) → implement → ...
```

### 2. Use Quality Gates

Standard severity routing makes reviews predictable:

```yaml
review:
  outputs: [P0, P1, P2, clean]

edges:
  - from: review
    to: fix
    condition: "any(P0, P1)"  # Fix critical/should-fix
  
  - from: review
    to: END
    condition: "any(P2, clean)"  # Done
```

### 3. Limit Iterations

Always set iteration limits to prevent runaway loops:

```yaml
limits:
  max_iterations: 10  # Reasonable for most tasks
```

### 4. Add Checkpoints

Save state before expensive or risky operations:

```yaml
nodes:
  save_before_deploy:
    type: checkpoint
    outputs: [done]

edges:
  - from: approval
    to: save_before_deploy
  - from: save_before_deploy
    to: deploy
```

### 5. Use Interrupts Wisely

Add interrupts for:
- User approval (deployment, expensive operations)
- Progress check (after N iterations)
- Cost control (before expensive AI operations)

```yaml
interrupts:
  - before: expensive_analysis
    condition: "state.estimated_cost > 1.00"
    prompt: "Analysis will cost (reference state.estimated_cost). Proceed?"
    required: true
```

### 6. Track State

Use state variables to make decisions:

```yaml
state:
  variables:
    attempt_count: 0
    best_score: 0

nodes:
  track_progress:
    on_output:
      done:
        set:
          attempt_count: output

edges:
  - from: check
    to: retry
    condition: "state.attempt_count < 5"
```

### 7. Parallel for Speed

Use parallel nodes for independent work:

```yaml
research:
  type: parallel
  branches: [research_a, research_b, research_c]

aggregate:
  type: join
  wait_for: [research_a, research_b, research_c]
```

### 8. Test Incrementally

Build and test workflows in stages:

1. Test linear path first
2. Add one loop, test
3. Add parallel branches, test
4. Add interrupts last

---

## See Also

- `SKILL.md` - Main skill documentation
- `workflow-schema.md` - Complete schema reference
