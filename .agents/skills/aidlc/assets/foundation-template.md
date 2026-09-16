# Foundation Specification Template

**Path**: `{SPECS_DIR}/{feature}/foundation.md`
**Condition**: Generated in incremental mode after units approved.
**Language**: Write ALL content in user's language. Keep technical terms, file paths, code unchanged.

## When to Generate

Generate when incremental mode is chosen and 2+ units defined.
Covers both team/process alignment AND technical architecture foundation.

## Template

````markdown
# Foundation Specification

## Summary
<!-- Compact digest for downstream agents. Read ONLY this section. -->
- **Team**: [Solo / Small team / Multiple teams]
- **Repo**: [Monorepo / Multi-repo / Hybrid]
- **Architecture**: [Modular Monolith / Microservices / Distributed]
- **Gateway**: [API Gateway / BFF / Direct / Hybrid / N/A]
- **Auth**: [JWT / Session / OAuth2 / API keys]
- **Error Format**: [RFC 7807 / Custom envelope / Framework default]
- **Inter-Unit Comms**: [REST / Events / gRPC / Mixed]
- **Database**: [Shared DB separate schemas / DB per unit / Mixed]
- **Shared Types**: [Shared package / Code generation / Manual sync]
- **Frontend**: [In monorepo / Separate repo / N/A] — [Shared UI: Yes/No]
- **Infrastructure Units**: [List or "None"]

---

## Team Assignments

| Unit | Owner/Team | Priority | Sequence |
|------|-----------|----------|----------|
| [Unit 1] | [Team/Person] | [High/Med/Low] | [1st - rationale] |
| [Unit 2] | [Team/Person] | [Priority] | [2nd - rationale] |

**Parallel Work**: [Which units can be developed in parallel and why]

[Skip this section for solo developers]

---

## Repository Structure

**Strategy**: [Monorepo / Multi-repo / Hybrid]
**Rationale**: [Why this fits]

[If Monorepo]:
```
project-root/
├── apps/
│   ├── web/                    # Frontend web app (if frontend unit exists)
│   ├── admin/                  # Admin dashboard (if separate frontend unit)
│   ├── gateway/                # API Gateway (if infra unit)
│   ├── [backend-unit-1]/       # Backend domain unit
│   └── [backend-unit-2]/       # Backend domain unit
├── packages/
│   ├── shared-types/           # Shared DTOs, interfaces, event schemas
│   ├── shared-ui/              # Shared UI components (if multiple frontends)
│   ├── shared-auth/            # Auth middleware, token validation
│   ├── shared-errors/          # Error handling utilities
│   ├── shared-logging/         # Logging configuration
│   └── shared-config/          # Linting, formatting, build config
├── infrastructure/             # IaC templates
├── docker-compose.yml          # Local dev orchestration
└── [monorepo-config]           # turbo.json / nx.json / pnpm-workspace.yaml
```

**NOTE**: Include ALL units from units.md in the directory structure — both frontend and backend. Check units.md for frontend units (web app, admin dashboard, mobile app) and list them under `apps/` alongside backend services.

[If Multi-repo]:
```
Repositories:
- [feature]-web/               # Frontend web app (if frontend unit)
- [feature]-gateway/            # API Gateway
- [feature]-[unit-1]/           # Backend domain unit
- [feature]-shared-libs/        # Published shared packages
```

**Ownership Rules**:
- [Shared packages] — [Who reviews, approval process]
- [Unit-specific code] — [Owned by assigned team]
- [Infrastructure] — [Who owns]

---

## API Architecture

[Only for microservices/distributed — skip for modular monolith]

**Pattern**: [API Gateway / BFF / Direct / Hybrid]
**Rationale**: [Why this pattern fits]

[If API Gateway]: Gateway handles routing, auth, rate limiting. Services are internal-only.
[If BFF]: List BFF per frontend type. Backend APIs are service-to-service.
[If Direct]: Each service handles auth, CORS, rate limiting. Service discovery via [method].
[If Hybrid]: External through gateway, service-to-service direct.

**Ownership**: [Team/person responsible for gateway/BFF]

---

## Authentication & Authorization

**Approach**: [JWT / Session / OAuth2 / API keys]

**Shared Auth Contract**:
```typescript
interface AuthContext {
  userId: string;
  roles: string[];
  permissions: string[];
}
type AuthMiddleware = (req: Request) => AuthContext | UnauthorizedError;
```

**Authorization**: [RBAC / ABAC / Simple role check]
**Enforced at**: [Gateway / Unit level / Both]

---

## Error Handling

**Format**: [RFC 7807 / Custom envelope / Framework default]

**Standard Error Shape**:
```typescript
interface AppError {
  code: string;       // "AUTH_001", "ORDER_NOT_FOUND"
  message: string;
  status: number;
  details?: unknown;
  requestId: string;
}
```

**Code Convention**: `[DOMAIN]_[NUMBER]`

**Shared Codes**:
| Code | Status | Meaning |
|------|--------|---------|
| VALIDATION_001 | 400 | Invalid request body |
| AUTH_001 | 401 | Missing/invalid token |
| AUTH_002 | 403 | Insufficient permissions |
| NOT_FOUND | 404 | Resource not found |
| INTERNAL | 500 | Unexpected error |

---

## Inter-Unit Communication

**Pattern**: [REST / Events / gRPC / Mixed]

[If REST]: Base URL `/api/v1/[unit]/[resource]`, timeout, retry policy
[If Events]: Broker [type], topic convention `[unit].[entity].[action]`
[If gRPC]: Proto location, service convention `[Unit]Service`
[If Mixed]: Sync for queries, async for state changes

**Event Schema** (if event-driven):
```typescript
interface DomainEvent<T> {
  eventId: string;
  eventType: string;
  timestamp: string;
  source: string;
  data: T;
}
```

---

## Database Strategy

**Approach**: [Shared DB separate schemas / DB per unit / Mixed]

[If shared DB]: Schema convention `[unit]_schema`, cross-schema access rules
[If DB per unit]: Naming `[feature]-[unit]-db`, cross-unit data via API/events

---

## Shared Types & Contracts

**Strategy**: [Shared package / Code generation / Manual sync]

[If shared package]: Location `packages/shared-types/`, versioning approach
[If code generation]: Source of truth (OpenAPI/GraphQL/Proto), generation tool

---

## Code & Data Conventions

### Code
- **Language**: [Shared language and version]
- **Naming**: [File, class, function naming patterns]
- **Testing**: [Shared framework and approach]
- **Linting/Formatting**: [Shared config and tools]

### Data
- **IDs**: [UUID v4 / ULID / auto-increment]
- **Timestamps**: [ISO 8601 UTC / Unix epoch]
- **Soft deletes**: [Yes with deletedAt / No]

---

## Integration Contracts

High-level interface sketches. Full API specs defined during each unit's design phase.

### [Unit A] → [Unit B]

**Endpoints** (sketch):
```
[METHOD] /api/v1/[resource]     → [Purpose]
[METHOD] /api/v1/[resource]/:id → [Purpose]
```

**Key data shape**:
```typescript
interface [EntityName] {
  id: string;
  [key fields]
}
```

**Events** (if event-driven): `[domain].[entity].[action]` — [When triggered]

---

## Infrastructure Units

[If identified — these get added to units.md]

### [Infrastructure Unit Name]

**Type**: Infrastructure (not domain)
**Purpose**: [What it does]
**Priority**: Design and implement BEFORE domain units
**Responsibilities**: [List]
**Stories**: None (cross-cutting)
**Depended on by**: [Domain units]

---

## Logging & Observability

**Log Format**: [Structured JSON / Plain text]
**Correlation**: Request ID via `X-Request-Id` header
**Log Levels**: error, warn, info, debug

---

## Sync Schedule

[Skip for solo developers]

| Activity | Frequency | Participants | Purpose |
|----------|-----------|-------------|---------|
| Integration check | [Weekly] | [Teams] | Contract changes, conflicts |
| Design review | Per unit | [Teams] | Validate against foundation |
| Shared code changes | As needed | [PR review] | Shared package updates |

---

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Contract drift | Integration failures | Spec as source of truth |
| Shared code conflicts | Blocked dev | Versioning, review process |

[Skip for solo developers]
````

## Content Adaptation Rules

**Solo developer**: Skip Team Assignments, Sync Schedule, Risks. Generate minimal: Repo Structure, Auth, Errors, Comms, DB, Shared Types, Conventions.

**Small team**: Full version, lighter Sync Schedule.

**Multiple teams**: Full version with all sections.

**Simple monolith (comprehensive mode)**: Do NOT generate foundation.md. Single design phase handles everything.
