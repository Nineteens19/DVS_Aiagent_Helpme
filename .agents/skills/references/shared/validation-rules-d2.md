# D2 Validation Rules (Units Decisions)

### Rule: Over-Decomposition for Small Project

**Trigger**: When project is small but decomposed into many units

**Conflict Type**: Architecture Complexity | **Severity**: Medium

**Detection Logic**:
- Total stories <= 10
- Number of units >= 4
- Team size <= 3

**Clarifying Questions**:
1. What's the rationale for this level of decomposition?
2. Is the added complexity worth the benefits?

**Resolution Options**:
1. Reduce to 2-3 units (simpler coordination)
2. Skip decomposition (single unit, monolithic approach)
3. Keep current decomposition (team has experience, anticipating growth)

---

### Rule: Microservices for Small Team

**Trigger**: When microservices chosen for small team

**Conflict Type**: Architecture vs Resources | **Severity**: High

**Detection Logic**:
- Architecture pattern = "Microservices"
- Team size <= 3
- Story count <= 15

**Clarifying Questions**:
1. Does the team have microservices experience?
2. Is the operational overhead manageable?
3. Are you anticipating rapid team growth?

**Resolution Options**:
1. Start with Modular Monolith (easier to manage, can split later)
2. Use Microservices (team experienced, clear rationale)
3. Hybrid approach (monolith with service boundaries defined)

---

### Rule: Circular Dependencies

**Trigger**: When units have circular dependencies

**Conflict Type**: Architecture Design | **Severity**: High

**Detection Logic**:
- Unit A depends on Unit B
- Unit B depends on Unit A (directly or transitively)

**Clarifying Questions**:
1. Can we break this circular dependency?
2. Should these be combined into one unit?

**Resolution Options**:
1. Introduce shared library/module for common functionality
2. Merge units into single unit
3. Refactor to remove circular dependency
4. Use event-driven pattern to decouple
