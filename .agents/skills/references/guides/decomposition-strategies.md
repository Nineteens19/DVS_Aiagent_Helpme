# Unit Decomposition Strategies

Reference guide for decomposing systems into units of work.

## Strategies

### Domain-Driven (Recommended)
Group by business domain or bounded context.

**Pros**: Aligns with business, clear ownership, independent evolution
**Cons**: May have data duplication, requires domain expertise
**Example**: User Management, Product Catalog, Order Processing, Payment

**How to identify domains**:
1. Look for clusters of related user stories
2. Identify nouns that appear together (Order + OrderItem + Shipping = Order domain)
3. Find natural boundaries where data ownership changes
4. Ask: "If this changed, what else would need to change?"

### Layer-Based
Group by technical layer.

**Pros**: Clear technical separation, reusable components
**Cons**: Changes often span multiple units, tight coupling between layers
**Example**: API Layer, Business Logic, Data Access, Infrastructure

**When it works**: Small teams where one person owns a full layer, or when layers have very different deployment needs.

### User Journey-Based
Group by user workflow or end-to-end experience.

**Pros**: Delivers complete features, user-centric, easy to demo
**Cons**: May duplicate technical components, harder to reuse across journeys
**Example**: Onboarding Flow, Core Experience, Checkout Process, Admin Dashboard

**When it works**: Product-focused teams, consumer apps, when time-to-first-feature matters.

### Hybrid
Combine strategies — e.g., domain-driven for backend, user-journey for frontend.

**When it works**: Large systems where different parts have different decomposition needs.

## When to Decompose

Decompose into units if project has:
- 5+ user stories
- 2+ distinct domains/functional areas
- 3+ different user types
- 3+ external integrations
- High technical complexity

Otherwise, keep as single unit.

## Sizing Units

**Too small** (merge them):
- 1-2 user stories
- No independent value
- Can't be developed without constant coordination with another unit

**Right size**:
- 3-8 user stories
- Clear boundary and purpose
- Can be designed and implemented somewhat independently
- Has a meaningful deliverable

**Too large** (split them):
- 15+ user stories
- Multiple distinct domains mixed together
- Would take more than 2-3 sprints to complete

## DDD Concepts

### Commands
Actions that change state. Name them as imperative verbs:
- CreateUser, UpdateOrder, DeleteProduct, ProcessPayment, ApproveRequest

### Domain Model
- **Aggregates**: Cluster of entities treated as a unit for data changes. Has a root entity.
  - Example: Order (root) + OrderItems + ShippingAddress
- **Entities**: Objects with identity that persists across time (User, Product, Order)
- **Value Objects**: Objects without identity, defined by their attributes (Money, Address, DateRange)

### Domain Events
Things that happened in the past tense. Published by one unit, consumed by others:
- UserCreated, OrderPlaced, PaymentProcessed, InventoryReserved

### Context Map Patterns

| Pattern | Description | When to use |
|---------|-------------|-------------|
| Customer/Supplier | Upstream provides what downstream needs | Clear provider/consumer relationship |
| Conformist | Downstream adapts to upstream's model | Can't influence upstream (external API) |
| Publisher/Subscriber | Loose coupling via events | Units need to react to each other's changes |
| Anti-Corruption Layer (ACL) | Translation layer between models | Protecting your model from external complexity |
| Shared Kernel | Shared code/types between units | Small, stable shared concepts |

## Common Pitfalls

1. **Over-decomposition**: Creating too many tiny units that need constant coordination
2. **Circular dependencies**: Unit A depends on B, B depends on A — merge them or introduce events
3. **Shared database**: Multiple units writing to the same tables — define clear data ownership
4. **Anemic units**: Units that are just CRUD wrappers with no real business logic — consider merging
5. **Big ball of mud**: One unit that does everything — look for natural seams to split
