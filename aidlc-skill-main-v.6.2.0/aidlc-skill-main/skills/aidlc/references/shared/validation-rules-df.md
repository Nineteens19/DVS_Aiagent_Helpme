# DF Validation Rules (Foundation Decisions)

### Rule: Microservices with Shared Schema

**Trigger**: Microservices architecture + shared database shared schema

**Conflict Type**: Architecture Anti-Pattern | **Severity**: High

**Detection**: Architecture = "Microservices" AND Database = "Shared database, shared schema"

**Questions**: Shared schema violates microservices data isolation. Intentional?

**Options**: 1. Separate schemas per unit 2. DB per unit 3. Switch to Modular Monolith 4. Keep (acknowledge trade-off)

---

### Rule: Event-Driven Without Broker Choice

**Trigger**: Event-driven comms selected but no broker infrastructure

**Conflict Type**: Missing Infrastructure | **Severity**: High

**Detection**: Inter-Unit Comms = "Event-driven" or "Mixed" AND Infrastructure Units does not include Event Bus/Broker

**Questions**: Event-driven needs a broker. Add as infrastructure unit?

**Options**: 1. Add Event Bus infra unit 2. Use cloud-managed broker (no dedicated unit) 3. Switch to REST

---

### Rule: API Gateway Without Gateway Unit

**Trigger**: API Gateway pattern selected but no gateway infrastructure unit

**Conflict Type**: Missing Infrastructure | **Severity**: Medium

**Detection**: API Architecture = "API Gateway" or "Hybrid" AND Infrastructure Units does not include API Gateway

**Questions**: Gateway pattern needs a gateway service. Add as infrastructure unit?

**Options**: 1. Add API Gateway infra unit 2. Use cloud-managed gateway (no dedicated unit) 3. Switch to Direct

---

### Rule: BFF Without Frontend Diversity

**Trigger**: BFF pattern selected but only one frontend type

**Conflict Type**: Over-Engineering | **Severity**: Medium

**Detection**: API Architecture = "BFF" AND requirements show single frontend type

**Questions**: BFF is most useful with multiple client types. Is this needed?

**Options**: 1. Switch to API Gateway (simpler) 2. Keep BFF (anticipating mobile/admin later) 3. Switch to Direct

---

### Rule: Multi-Repo with Heavy Shared Types

**Trigger**: Multi-repo + shared package strategy

**Conflict Type**: Workflow Complexity | **Severity**: Medium

**Detection**: Repo = "Multi-repo" AND Shared Types = "Shared package"

**Questions**: Shared packages across repos need publishing/versioning. Manageable?

**Options**: 1. Switch to monorepo (easier sharing) 2. Use code generation instead 3. Keep multi-repo + published packages

---

### Rule: Solo Dev with Complex Infrastructure

**Trigger**: Solo developer with multiple infrastructure units

**Conflict Type**: Resource Mismatch | **Severity**: Medium

**Detection**: Team = "Solo" AND Infrastructure Units count >= 2

**Questions**: Multiple infra units add operational overhead for a solo dev.

**Options**: 1. Reduce to essential infra only 2. Use managed services instead 3. Keep (experienced with ops)

---

### Rule: Manual Sync for Shared Types with Multiple Teams

**Trigger**: Manual sync strategy with multiple teams

**Conflict Type**: Coordination Risk | **Severity**: High

**Detection**: Team = "Multiple teams" AND Shared Types = "Manual sync"

**Questions**: Manual sync across teams leads to drift. Use automated approach?

**Options**: 1. Shared package 2. Code generation 3. Keep manual (strong sync discipline)

---

## Context-Based Severity Adjustments

- **Team Size**: Solo → infra complexity HIGH; Multiple teams → coordination risks HIGH
- **Architecture**: Microservices → data isolation rules HIGH; Monolith → relaxed
