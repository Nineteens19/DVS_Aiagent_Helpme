# Steering: Structure Template

**Path**: `{STEERING_DIR}/structure.md`
**See**: `{SHARED_DIR}/workflow-state.md` for STEERING_DIR per tool
**Language**: Generate all content in user's language. Keep file paths and directory names unchanged.

**Progressive enrichment**:
- Phase 1: Detected structure (brownfield) or placeholder (greenfield)
- Phase 4: Updated with design structure decisions

**Front-matter**:
- Kiro: `inclusion: always`
- Other tools: No front-matter needed (files in rules/ are always included)

```markdown
---
inclusion: always    ← Include this front-matter for Kiro only. Omit for Claude Code, Cursor, Windsurf.
---
# Project Structure

## Repository

- **Type**: [Monorepo / Multi-repo / Single repo / "Pending D3 decisions"]
- **Root**: [Brief description of workspace root]

## Key Directories

| Directory | Purpose |
|-----------|---------|
| [src/ or detected] | [Source code] |
| [tests/ or detected] | [Test files] |
| [docs/ or detected] | [Documentation] |
| [.kiro/specs/] | [AI-DLC spec artifacts] |
| [.aidlc/workflow/] | [AI-DLC workflow state] |

[For greenfield: "Directory structure will be defined during design phase (Phase 4)."]

## Key Files

| File | Purpose |
|------|---------|
| [package.json or detected] | [Dependencies and scripts] |
| [tsconfig.json or detected] | [TypeScript configuration] |
| [Detected config files] | [Purpose] |

[For greenfield: "Key files will be defined during design phase (Phase 4)."]

## Entry Points

[For brownfield: List detected entry points — API handlers, main functions, etc.]
[For greenfield: "Entry points will be defined during design phase (Phase 4)."]
```
