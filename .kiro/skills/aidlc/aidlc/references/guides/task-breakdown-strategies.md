# Task Breakdown Strategies

Reference guide for breaking down work into implementation tasks.

## Strategies

### Vertical Slice (Recommended)
Each task delivers a complete user-facing feature.

**Pros**: Delivers value incrementally, easier to demo, clear progress
**Cons**: May touch multiple layers, harder to parallelize
**Example**: "Implement user login" (UI + API + database)

### Layer-by-Layer
Tasks organized by technical layer.

**Pros**: Clear technical separation, easier to parallelize
**Cons**: No user value until all layers complete, integration risk
**Example**: "Implement all database models", then "Implement all APIs"

### Feature-by-Feature
Tasks organized by functional area.

**Pros**: Clear feature boundaries, easier to prioritize
**Cons**: May have dependencies between features
**Example**: "Implement product catalog", "Implement shopping cart"

### Component-First
Build shared components before features.

**Pros**: Reusable components, consistent patterns
**Cons**: Risk of over-engineering, delayed user value
**Example**: "Build authentication library", then "Build features using it"

## Task Sizing

**Rule**: Break down tasks so they can be completed in 1-2 days or less.

**Good sizes**:
- Single CRUD operation
- One UI component
- Specific API endpoint
- Unit tests for a module

**Too large** (needs breakdown):
- "Implement entire authentication system"
- "Build complete user management"
- "Create all API endpoints"

## Task Format

```markdown
- [ ] 1. Main task title
  - **Description**: What needs to be done
  - **Dependencies**: Other tasks or "None"
  - **Estimated Effort**: S/M/L
  - [ ] 1.1 Sub-task title
    - Implementation detail
    - Testing requirement
```

## Parallel Work

Identify tasks that can be done in parallel:
- Tasks with no dependencies
- Tasks in different layers/components
- Tasks for different features

Document parallel opportunities in tasks.md.
