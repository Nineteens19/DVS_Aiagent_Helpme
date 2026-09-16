# Requirements Template

**Path**: `{SPECS_DIR}/{feature}/requirements.md`

User stories with acceptance criteria using EARS notation.

```markdown
# Requirements

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Total Stories**: [X] across [Y] functional areas
- **Priority**: [X] High, [Y] Medium, [Z] Low
- **User Types**: [list]
- **Key Entities**: [list top 3-5 data entities mentioned]
- **Integrations**: [list external systems]
- **Core Flows**: [1-line per major user flow, max 5]

## Overview
User stories organized by functional area with EARS notation acceptance criteria.

---

## Functional Area 1: [Name]

### US-001: [Story Title]
**As a** [persona/user type]  
**I want** [action/capability]  
**So that** [benefit/value]

**Priority**: [High/Medium/Low]

**Acceptance Criteria**:
1. **WHEN** [trigger], **THEN** [expected behavior]
2. **IF** [condition], **THEN** [behavior], **ELSE** [alternative]
3. **WHILE** [state], **IF** [condition], **THEN** [behavior]

**Dependencies**: [Other stories or "None"]

---

### US-002: [Story Title]

[Same structure as US-001]

---

## Functional Area 2: [Name]

### US-003: [Story Title]

[Same structure]

---

## Story Summary

| ID | Title | Area | Priority | Dependencies |
|----|-------|------|----------|--------------|
| US-001 | [Title] | [Area] | High | None |
| US-002 | [Title] | [Area] | High | US-001 |

---

## Story-Persona Matrix

[If personas exist]

| Story | [Persona 1] | [Persona 2] | [Persona 3] |
|-------|-------------|-------------|-------------|
| US-001 | ✓ Primary | - | ✓ Secondary |
| US-002 | - | ✓ Primary | - |

---

## Non-Functional Considerations

[Brief notes on cross-cutting concerns - will be detailed in NFR phase]
- Performance expectations
- Security requirements
- Scalability needs
```

**EARS Notation**: See `{GUIDES_DIR}/ears-notation.md` for detailed EARS patterns and examples.
