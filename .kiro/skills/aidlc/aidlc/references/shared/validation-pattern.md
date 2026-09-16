# Decision Validation Pattern (Compact)

## Process

1. Parse all answers from the decision file
2. Load context from previous phases (team size, story count, architecture from D2)
3. Load ONLY the relevant gate rules file: `validation-rules-{gate}.md`
4. Check each rule's trigger conditions against answers
5. Collect conflicts, adjust severity by context factors
6. If conflicts found → present grouped by severity (High → Medium → Low), ask clarifying questions, wait for resolution
7. If no conflicts or all resolved → summarize choices, wait for confirmation, proceed

## Conflict Severity

- 🔴 High: Blocks implementation. MUST resolve before proceeding. Override requires justification.
- 🟡 Medium: Should resolve, can proceed with acknowledgment.
- 🟢 Low: Informational. Always allowed to override.

## Presentation Format

```
⚠️ Decision Validation - Conflicts Detected

## 🔴 Conflict 1: [Name] (High)
**Issue**: [Description]
**Your choices**: [Decision A]: [answer], [Decision B]: [answer]
**Options**: 1. [option] 2. [option] 3. Keep current (requires justification)
**Question**: How would you like to resolve this?
```

## After Resolution

Append to decision file:
```markdown
## Validation Notes
**Conflicts Detected**: [X] | **Resolved**: [Y]
### Resolved: [conflict name] → [resolution chosen]
### Acknowledged: [trade-off] → [user rationale]
```

## State Tracking

Update `workflow-state.json` with `validation.inProgress`, `conflictsDetected`, `conflictsResolved`, `iteration`.

## Bypass

User can say "Skip validation and proceed" → log in audit, add warning to decision file, proceed.
