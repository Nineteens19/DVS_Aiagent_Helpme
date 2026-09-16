# D1 Validation Rules (Requirements Decisions)

### Rule: Scope vs Timeline Mismatch

**Trigger**: When scope is large AND timeline is short

**Conflict Type**: Planning | **Severity**: Medium

**Detection Logic**:
- Feature scope = "Full product" OR "Enterprise"
- Timeline = "< 3 months" OR "Urgent"
- Story count > 15

**Clarifying Questions**:
1. Is this timeline realistic given the scope?
2. Can we prioritize features for phased delivery?

**Resolution Options**:
1. Reduce scope to MVP for initial release
2. Extend timeline to match scope
3. Increase team size (if feasible)
4. Keep current plan (requires justification)

---

### Rule: Complex Features Without Personas

**Trigger**: When multiple user types exist but personas not generated

**Conflict Type**: Requirements Quality | **Severity**: Low

**Detection Logic**:
- User types count >= 3
- Personas generation = "No"
- Requirements include varied user workflows

**Clarifying Questions**:
1. Do different user types have significantly different needs?
2. Would personas help clarify requirements?

**Resolution Options**:
1. Generate personas to clarify user needs
2. Skip personas (requirements are clear enough)

---

### Rule: Many Integrations Without Clear Priority

**Trigger**: When 3+ external integrations with no priority ordering

**Conflict Type**: Scope Risk | **Severity**: Medium

**Detection Logic**:
- External integrations count >= 3
- No priority or phasing indicated for integrations

**Clarifying Questions**:
1. Which integrations are required for MVP?
2. Can some integrations be deferred to later phases?

**Resolution Options**:
1. Prioritize integrations — mark MVP-required vs deferred
2. Reduce to core integrations only for initial release
3. Keep all (team has capacity)

---

### Rule: Broad Scope Without Clear Boundaries

**Trigger**: When feature scope covers multiple domains without clear boundaries

**Conflict Type**: Requirements Quality | **Severity**: Medium

**Detection Logic**:
- Feature scope = "Full product" or covers 3+ functional areas
- No explicit out-of-scope items defined

**Clarifying Questions**:
1. What is explicitly out of scope?
2. Are there natural phase boundaries?

**Resolution Options**:
1. Define explicit out-of-scope items
2. Split into phased delivery with clear boundaries
3. Keep broad scope (small project, manageable)
