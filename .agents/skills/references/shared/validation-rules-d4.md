# D4 Validation Rules (Tasks Decisions)

### Rule: TDD Without Team Experience

**Trigger**: When TDD approach without team experience

**Conflict Type**: Workflow Risk | **Severity**: Low

**Detection Logic**:
- Testing approach = "TDD (Test-Driven Development)"
- Context indicates team new to TDD

**Clarifying Questions**:
1. Does the team have TDD experience?
2. Is there time for the learning curve?

**Resolution Options**:
1. Start with test-after approach (easier learning curve)
2. Use TDD for critical components only
3. Keep TDD (team committed to learning)

---

### Rule: No Testing Strategy

**Trigger**: When no testing strategy defined

**Conflict Type**: Quality Risk | **Severity**: High

**Detection Logic**:
- Testing approach = "None" OR "Manual only"
- Production deployment planned

**Clarifying Questions**:
1. How will you ensure code quality?
2. Is this a prototype or production system?

**Resolution Options**:
1. Add unit tests at minimum (Jest, Pytest, JUnit)
2. Add integration tests for critical paths
3. Keep no automated tests (prototype only, will add later)

---

### Rule: Parallel Development Without Coordination

**Trigger**: When parallel development without coordination plan

**Conflict Type**: Workflow Risk | **Severity**: Medium

**Detection Logic**:
- Task breakdown = "Parallel" OR "By unit"
- Multiple developers indicated
- No mention of integration points or sync schedule

**Clarifying Questions**:
1. How will developers coordinate on shared interfaces?
2. When will integration happen?

**Resolution Options**:
1. Define integration milestones and sync points
2. Assign interface contracts upfront
3. Use sequential development (less coordination needed)

---

### Rule: Outside-In Testing Without E2E Framework

**Trigger**: When outside-in testing chosen but no E2E framework selected

**Conflict Type**: Tooling Gap | **Severity**: Medium

**Detection Logic**:
- Testing approach = "Outside-in"
- D3 E2E framework = "None" or not specified

**Clarifying Questions**:
1. Which E2E framework will drive the outer tests?
2. Can you start with integration tests instead?

**Resolution Options**:
1. Select an E2E framework (Playwright, Cypress, Supertest)
2. Use integration tests as the "outer" layer instead
3. Keep outside-in without E2E (unit tests as outer layer)

---

### Rule: No CI/CD With Production Deployment

**Trigger**: When production deployment planned but no CI/CD

**Conflict Type**: Deployment Risk | **Severity**: Medium

**Detection Logic**:
- Deployment target includes production
- CI/CD = "None" or "Manual"

**Clarifying Questions**:
1. How will you ensure consistent deployments?
2. Is manual deployment acceptable for this project?

**Resolution Options**:
1. Add basic CI/CD pipeline (GitHub Actions, GitLab CI)
2. Use manual deployment with documented runbook
3. Defer CI/CD to post-MVP

---

## Context-Based Severity Adjustments

- **Team Size**: Small (1-3) → complexity conflicts HIGH; Large (9+) → LOW
- **Scope**: MVP → over-engineering HIGH; Enterprise → under-engineering HIGH
- **Timeline**: Urgent (<3mo) → complexity HIGH; Long-term (>6mo) → LOW
