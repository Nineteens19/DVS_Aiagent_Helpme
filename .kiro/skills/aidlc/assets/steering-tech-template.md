# Steering: Tech Template

**Path**: `{STEERING_DIR}/tech.md`
**See**: `{SHARED_DIR}/workflow-state.md` for STEERING_DIR per tool
**Language**: Generate all content in user's language. Keep technology names and code unchanged.

**Progressive enrichment**:
- Phase 1: Detected stack (brownfield) or placeholder (greenfield)
- Phase 4: Updated with D3 technology decisions

**Front-matter**:
- Kiro: `inclusion: always`
- Other tools: No front-matter needed (files in rules/ are always included)

```markdown
---
inclusion: always    ← Include this front-matter for Kiro only. Omit for Claude Code, Cursor, Windsurf.
---
# Technology Context

## Stack

- **Languages**: [Detected or "Pending D3 decisions"]
- **Frameworks**: [Detected or "Pending D3 decisions"]
- **Build System**: [Detected or "Pending D3 decisions"]
- **Package Manager**: [Detected or "Pending D3 decisions"]
- **Testing**: [Detected or "Pending D3 decisions"]

## Architecture

- **Pattern**: [Monolith / Microservices / Serverless / "Pending D2/D3 decisions"]
- **API Style**: [REST / GraphQL / gRPC / "Pending D3 decisions"]

## Infrastructure

- **Cloud Provider**: [Detected or "Pending D3 decisions"]
- **Compute**: [Detected or "Pending D3 decisions"]
- **Database**: [Detected or "Pending D3 decisions"]
- **IaC Tool**: [Detected or "Pending D3 decisions"]

## Conventions

- **Code Style**: [Detected from config files (e.g., ESLint, Prettier) or "Not yet defined"]
- **Naming**: [Detected patterns or "Not yet defined"]
- **Testing Pattern**: [Detected framework and patterns or "Not yet defined"]
- **Branch Strategy**: [Detected or "Not yet defined"]
```
