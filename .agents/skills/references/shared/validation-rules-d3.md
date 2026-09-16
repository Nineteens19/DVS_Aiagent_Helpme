# D3 Validation Rules (Design Decisions)

## Technology Compatibility Rules

### Rule: Prisma + MongoDB Limited Support

**Trigger**: When Prisma ORM selected with MongoDB

**Conflict Type**: Technology Compatibility | **Severity**: Medium

**Detection**: ORM contains "Prisma" AND Database contains "MongoDB"

**Questions**: Prisma's MongoDB support is limited (no migrations). Need full ORM features?

**Options**: 1. Switch to Mongoose 2. Keep Prisma+MongoDB (accept limitations) 3. Switch to PostgreSQL

---

### Rule: GraphQL Without Proper Client

**Trigger**: When GraphQL API with incompatible frontend client

**Conflict Type**: Technology Compatibility | **Severity**: Medium

**Detection**: API pattern = "GraphQL" AND HTTP Client = "Axios"/"Fetch API"

**Questions**: How will frontend consume GraphQL? Need subscriptions/caching?

**Options**: 1. Apollo Client/urql 2. Fetch with manual queries 3. Switch to REST

---

### Rule: AWS CDK with Non-AWS Cloud

**Trigger**: When AWS CDK selected with non-AWS cloud provider

**Conflict Type**: Technology Compatibility | **Severity**: High

**Detection**: IaC = "AWS CDK" AND Cloud = "Azure"/"GCP"

**Options**: 1. Switch to AWS 2. Switch to Terraform/Pulumi 3. Use cloud-specific IaC

---

### Rule: Serverless with Long-Running Tasks

**Trigger**: When serverless compute with long-running requirements

**Conflict Type**: Architecture Limitation | **Severity**: High

**Detection**: Compute contains "Lambda"/"Serverless" AND requirements mention batch/long-running

**Options**: 1. ECS/Fargate for long tasks 2. Step Functions 3. Async with queues 4. Hybrid Lambda+ECS

---

## Architecture Pattern Rules

### Rule: Event Sourcing for Simple CRUD

**Conflict Type**: Over-Engineering | **Severity**: Medium

**Detection**: Event Sourcing = "Yes" AND mostly CRUD AND story count <= 10

**Options**: 1. Traditional state storage 2. Audit logging instead 3. Keep Event Sourcing

---

### Rule: CQRS Without Justification

**Conflict Type**: Over-Engineering | **Severity**: Medium

**Detection**: CQRS = "Yes" AND no different read/write patterns AND Architecture = Monolith

**Options**: 1. Unified model 2. Keep CQRS 3. Start simple, add later

---

### Rule: Microservices with Shared Database

**Conflict Type**: Architecture Anti-Pattern | **Severity**: High

**Detection**: Architecture = "Microservices" (from D2) AND database = "shared"/"single"

**Options**: 1. Database per service 2. Shared DB with schema separation 3. Switch to Modular Monolith 4. Keep shared DB

---

## Scale & Performance Rules

### Rule: High Availability Without Redundancy

**Conflict Type**: Architecture Inadequacy | **Severity**: High

**Detection**: Availability >= 99.9% AND single instance AND no load balancer AND no replication

**Options**: 1. Multi-AZ + load balancer 2. DB replication 3. Lower availability target 4. Managed services with HA

---

### Rule: High Throughput Without Caching

**Conflict Type**: Performance Inadequacy | **Severity**: Medium

**Detection**: Performance > 1000 req/s AND Caching = "None" AND read-heavy

**Options**: 1. Redis/Memcached 2. CDN for static 3. DB query caching 4. Keep no caching

---

### Rule: Global Users with Single Region

**Conflict Type**: Performance Inadequacy | **Severity**: Medium

**Detection**: Requirements mention "global"/"international" AND single region AND no CDN

**Options**: 1. CDN for static 2. Multi-region 3. Start single, expand later 4. Keep single region

---

## Security & Compliance Rules

### Rule: PII Data Without Encryption

**Conflict Type**: Security Risk | **Severity**: High

**Detection**: Requirements mention PII AND encryption = "None"/"In transit only"

**Options**: 1. Encryption at rest 2. Field-level encryption 3. Justify (non-production only)

---

### Rule: Public API Without Rate Limiting

**Conflict Type**: Security Risk | **Severity**: Medium

**Detection**: API is public AND rate limiting = "None"

**Options**: 1. Rate limiting 2. API gateway 3. Keep none (internal only)

---

### Rule: Enterprise Security Without Secret Management

**Conflict Type**: Security Risk | **Severity**: High

**Detection**: Security = "Enterprise" AND secrets = "Environment variables"/"Config files"

**Options**: 1. Secrets Manager/Vault 2. Cloud secret service 3. Justify (dev only)

---

## Development Workflow Rules

### Rule: Monorepo Without Monorepo Tool

**Conflict Type**: Workflow Inadequacy | **Severity**: Medium

**Detection**: Repo = "Monorepo" AND monorepo tool = "None" AND multiple packages

**Options**: 1. Nx/Turborepo/pnpm workspaces 2. Native workspaces 3. Keep manual

---

### Rule: Trunk-Based with Long-Lived Branches

**Conflict Type**: Workflow Conflict | **Severity**: Medium

**Detection**: Branch = "Trunk-based" AND mentions "feature branches"/"long-lived"

**Options**: 1. True trunk-based 2. GitHub Flow 3. Git Flow

---

## Cost & Complexity Rules

### Rule: MVP with Enterprise Observability

**Conflict Type**: Over-Engineering | **Severity**: Low

**Detection**: Scope = "MVP"/"Prototype" AND observability includes tracing/APM/full metrics

**Options**: 1. Basic logging+metrics 2. Keep full observability 3. Phased approach

---

### Rule: Small Team with Complex Architecture

**Conflict Type**: Resource Mismatch | **Severity**: Medium

**Detection**: Team <= 3 AND Architecture = "Microservices" AND multiple DBs/queues/caches

**Options**: 1. Simplify architecture 2. Managed services 3. Keep complex

---

## Context-Based Severity Adjustments

- **Team Size**: Small (1-3) → complexity conflicts HIGH; Large (9+) → LOW
- **Scope**: MVP → over-engineering HIGH; Enterprise → under-engineering HIGH
- **Timeline**: Urgent (<3mo) → complexity HIGH; Long-term (>6mo) → LOW
