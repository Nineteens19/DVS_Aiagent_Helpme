# EARS Notation Guide

**EARS** = Easy Approach to Requirements Syntax

A structured way to write clear, testable acceptance criteria. Each pattern maps directly to a test case.

## Five EARS Patterns

### 1. Ubiquitous (Always Active)
**Format**: `The system shall [requirement]`

**Use when**: Requirement is always active, no conditions

**Examples**:
- "The system shall encrypt all data at rest"
- "The system shall log all API requests with request ID"
- "The system shall return responses in JSON format"

### 2. Event-Driven (Triggered by Event)
**Format**: `WHEN [trigger], THEN [response]`

**Use when**: Requirement is triggered by a specific event

**Examples**:
- "WHEN user clicks submit, THEN validate all form fields and display errors inline"
- "WHEN payment succeeds, THEN send confirmation email within 30 seconds"
- "WHEN a new order is placed, THEN update inventory count and notify warehouse"
- "WHEN API receives request without auth token, THEN return 401 with error message"

### 3. State-Driven (Depends on System State)
**Format**: `WHILE [state], IF [condition], THEN [response]`

**Use when**: Requirement depends on current system state

**Examples**:
- "WHILE user is logged in, IF session expires, THEN redirect to login with return URL"
- "WHILE cart is not empty, IF user clicks checkout, THEN proceed to payment"
- "WHILE system is in maintenance mode, IF user sends request, THEN return 503 with estimated recovery time"
- "WHILE order status is 'processing', IF payment fails, THEN revert to 'pending' and notify user"

### 4. Unwanted Behavior (Error Handling)
**Format**: `IF [condition], THEN [response], ELSE [alternative]`

**Use when**: Defining error handling or alternative paths

**Examples**:
- "IF payment fails, THEN show error message with retry option, ELSE confirm order and redirect to receipt"
- "IF email is invalid, THEN show validation error below field, ELSE proceed to next step"
- "IF external API returns 5xx, THEN retry 3 times with exponential backoff, ELSE log failure and return cached data"
- "IF uploaded file exceeds 10MB, THEN reject with size limit message, ELSE process and store file"

### 5. Optional Features (Conditional Functionality)
**Format**: `WHERE [feature/condition], WHEN [trigger], THEN [response]`

**Use when**: Feature is optional, role-based, or conditional

**Examples**:
- "WHERE premium subscription, WHEN user requests export, THEN allow PDF and CSV download"
- "WHERE admin role, WHEN viewing dashboard, THEN show all users and system metrics"
- "WHERE multi-language enabled, WHEN user changes locale, THEN reload UI in selected language"
- "WHERE feature flag 'dark-mode' is active, WHEN user toggles theme, THEN switch to dark color scheme"

## Combining Patterns

Complex acceptance criteria can combine patterns:

- "WHILE user is on checkout page, WHEN user clicks 'Place Order', IF payment method is valid, THEN process payment and create order, ELSE highlight invalid fields"
- "WHERE admin role, WHILE viewing user list, WHEN admin clicks 'Deactivate', IF user has active sessions, THEN terminate sessions and deactivate account"

## Mapping EARS to Tests

| EARS Pattern | Test Type | Example Test |
|-------------|-----------|-------------|
| Ubiquitous | Unit/Integration | Assert all responses have JSON content-type |
| Event-Driven | Integration/E2E | Trigger event, verify response |
| State-Driven | State machine test | Set state, apply condition, verify transition |
| Unwanted Behavior | Error path test | Trigger error, verify handling and fallback |
| Optional Features | Feature flag / role test | Enable feature, verify behavior differs |

## Best Practices

1. Use EARS for all acceptance criteria — it forces clarity
2. Be specific and measurable (include timeouts, limits, formats)
3. Include both happy path and error cases for each story
4. Make criteria directly testable — if you can't write a test for it, rewrite it
5. Avoid ambiguous language ("quickly", "user-friendly", "appropriate")
6. One behavior per criterion — don't combine multiple outcomes
