# Steering: Product Template

**Path**: `{STEERING_DIR}/product.md`
**See**: `{SHARED_DIR}/workflow-state.md` for STEERING_DIR per tool
**Language**: Generate all content in user's language. Keep technical terms unchanged.

**Progressive enrichment**:
- Phase 1: Initial generation from user's request and workspace scan
- Phase 2: Update with user types and feature areas from requirements

**Front-matter**:
- Kiro: `inclusion: always`
- Other tools: No front-matter needed (files in rules/ are always included)

```markdown
---
inclusion: always    ← Include this front-matter for Kiro only. Omit for Claude Code, Cursor, Windsurf.
---
# Product Context

## Overview

[One paragraph describing the product/feature being built — derived from user's initial request]

## Problem Statement

[What problem this product/feature solves — why it's being built]

## Target Users

[User types identified during context assessment]
- [User type 1]: [Brief description]
- [User type 2]: [Brief description]

## Key Features

[High-level feature areas — from user's request, refined after requirements phase]
- [Feature area 1]: [Brief description]
- [Feature area 2]: [Brief description]

## Project Type

- **Type**: [Greenfield / Brownfield]
- **Scope**: [New product / New feature in existing product / Enhancement]
```
