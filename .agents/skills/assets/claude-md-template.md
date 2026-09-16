# AI-DLC Workflow Context

This project uses the AI-DLC (AI Development Lifecycle) skill for structured software specification and implementation.

## Current Workflow State

- **Feature**: {feature}
- **Phase**: {currentPhase}
- **Language**: {language}
- **Next Action**: {nextAction}

## Workflow Instructions

**CRITICAL**: This is a custom specification workflow. Follow these rules:

1. **Phase execution**: Load phase instructions from `.claude/skills/aidlc/references/phase-prompts/`
2. **Decision gates**: WAIT for user approval after each phase
3. **State file**: Check `.aidlc/workflow/{feature}/workflow-state.json` for resume state
4. **Steering files**: Read `.claude/steering/*.md` for persistent project context

## Key Paths

- **Specs**: `.claude/specs/{feature}/`
- **Workflow**: `.aidlc/workflow/{feature}/`
- **Skill**: `.claude/skills/aidlc/SKILL.md`
- **Phase Prompts**: `.claude/skills/aidlc/references/phase-prompts/`
- **Templates**: `.claude/skills/aidlc/assets/`
- **Guides**: `.claude/skills/aidlc/references/guides/`

## After Context Compaction

If you lose context:
1. Read `CLAUDE.md` (this file) for current state
2. Read `.aidlc/workflow/{feature}/workflow-state.json` for detailed state
3. Read `.claude/skills/aidlc/SKILL.md` for orchestration logic
4. Read steering files: `.claude/steering/product.md`, `tech.md`, `structure.md`, `aidlc-workflow.md`
5. Continue from `nextAction` in state file

## Tool Usage (Claude Code)

- **File operations**: Use `Write` (new files), `Edit` (modifications), `Read` (read files)
- **Batch reading**: Call `Read` multiple times in parallel (same invocation block)
- **Sub-agents**: Use `Agent` tool with `subagent_type: "general-task-execution"`
- **Task tracking**: Use `TaskUpdate` or `Edit` tool to update task checkboxes

## Phase Overview

1. **Context** (Business Analyst) → context.md, steering files
2. **Requirements** (Product Owner) → D1 decisions → personas.md?, requirements.md
3. **Units** (Solution Architect) → D2 decisions → units.md (if complex)
4. **Design** (Software Architect) → D3 decisions → design.md, design/*
5. **Tasks** (Tech Lead) → D4 decisions → tasks.md
6. **Implementation** (Software Engineer) → code, tests

## Resume Instructions

When resuming after a break:
1. Check `nextAction` in workflow-state.json
2. Load the appropriate phase prompt file
3. Continue from that action
4. Present resume summary to user

## Important Notes

- Generate ALL content in `{language}` (except code, paths, tech names)
- WAIT for user approval after each phase before proceeding
- Update `CLAUDE.md` and `workflow-state.json` after each phase completion
- Each decision gate is independent — "use recommendations" applies only to current gate
