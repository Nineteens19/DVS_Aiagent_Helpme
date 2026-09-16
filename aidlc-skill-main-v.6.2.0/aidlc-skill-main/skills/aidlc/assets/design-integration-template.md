# Integration Template

**Path**: `{SPECS_DIR}/{feature}/design/integration.md`
**See**: `{GUIDES_DIR}/distributed-patterns.md` for distributed system patterns (CQRS, Saga, Event Sourcing, etc.)

```markdown
# Integration Specifications

## Overview
[Brief overview of integration strategy]

---

## External Integrations

### [Service Name]

**Purpose**: [Why this integration is needed]
**Type**: [REST API/GraphQL/gRPC/Message Queue]
**Auth**: [API Key/OAuth/JWT] — stored in [Secrets Manager/Vault]

**Key Endpoints**:
- `[METHOD] [URL]` — [Purpose]
- `[METHOD] [URL]` — [Purpose]

**Error Handling**:
- Retry: [Strategy — e.g., "Exponential backoff, 3 attempts"]
- Timeout: [Duration]
- Fallback: [What happens when unavailable]

---

## Inter-Unit Communication

[For systems with multiple units or components that communicate asynchronously — skip if single unit with no async]

**Pattern**: [Synchronous REST / Async events / Mixed]
**Transport**: [Message broker/event bus technology — e.g., SQS, Kafka, EventBridge, RabbitMQ]

### Synchronous Contracts

[If units communicate via REST/gRPC]

#### [Unit A] → [Unit B]: [Purpose]
- **Method**: [REST/gRPC]
- **Endpoint**: `[METHOD] [path]`
- **Request**: `{field: type}`
- **Response**: `{field: type}`

---

### Domain Events

[Event catalog — each event that flows between components/units]

#### [domain].[entity].[action]

**Producer**: [Component/Unit that publishes]
**Consumers**: [Components/Units that subscribe and what they do]
**Trigger**: [When this event is emitted]

**Schema**:
```json
{
  "eventId": "uuid",
  "eventType": "domain.entity.action",
  "timestamp": "ISO-8601",
  "version": "1.0",
  "payload": {
    "field1": "type",
    "field2": "type"
  }
}
```

#### [domain].[entity].[action]

[Same structure for each event]

---

### Message Infrastructure

[If using message queues/event bus]

| Queue/Topic | Purpose | Producers | Consumers | DLQ | Retry Policy |
|-------------|---------|-----------|-----------|-----|-------------|
| [name] | [purpose] | [services] | [services] | [Yes/No] | [policy] |

**Message Format**: [JSON/Protobuf/Avro]
**Ordering**: [FIFO/Best-effort]
**Deduplication**: [Strategy — idempotency keys, message IDs]

---

## Distributed Patterns

[Only if microservices/distributed architecture — reference guide for details]

| Pattern | Used | Purpose |
|---------|------|---------|
| Saga | [Yes/No] | [Brief purpose] |
| CQRS | [Yes/No] | [Brief purpose] |
| Event Sourcing | [Yes/No] | [Brief purpose] |
| Outbox | [Yes/No] | [Brief purpose] |
| Idempotency | [Yes/No] | [Brief purpose] |

**See**: `{GUIDES_DIR}/distributed-patterns.md` for implementation details of each pattern.

---

## Integration Testing

**Strategy**: [How integrations are tested]
**Mocking**: [Which services are mocked in dev/test]
**Contract Testing**: [Tool — e.g., "Pact"] (if applicable)
```
