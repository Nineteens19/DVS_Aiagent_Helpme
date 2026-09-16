# Command Dispatcher

## Command Registry

11 user-facing commands. Each phase command bundles the full two-step pattern (decisions → validate → generate) internally.

| Command | Description | Phase Prompt(s) | Bundled Actions |
|---------|------------|-----------------|-----------------|
| `start` | Initialize new feature | — (SKILL.md init) | env detection, paths, folders |
| `resume` | Resume existing workflow | — (workflow-state.md) | state recovery, resume prompt |
| `status` | Show current progress | — | read state, present phase + next |
| `next` | Execute whatever comes next | (varies) | read nextAction → dispatch |
| `context` | Context assessment | business-analyst.md | context-assessment |
| `requirements` | Requirements phase | product-owner.md + decision-validator.md | D1 decisions → validate → generate |
| `units` | Decomposition phase | solution-architect.md + decision-validator.md | D2 decisions → validate → generate |
| `foundation` | Foundation phase | solution-architect.md + decision-validator.md | DF decisions → validate → generate |
| `design` | Design phase | software-architect.md + decision-validator.md | D3 decisions → validate → generate |
| `tasks` | Tasks phase | tech-lead.md + decision-validator.md | D4 decisions → validate → generate |
| `implement` | Implementation | software-engineer.md | implement tasks (standard/parallel) |

Edit actions are NOT commands — they trigger naturally when user requests changes during any phase's approval step.

Cross-cutting personas (architecture-reviewer, decision-validator) are invoked internally by phase commands, never directly by users.

## Dispatch Process

1. Match user input to command (accept variations: "run requirements", "do design", "jump to tasks", etc.)
2. Read `{WORKFLOW_DIR}/{feature}/workflow-state.json`
3. Check prerequisites (see table below)
4. If prerequisite fails → report what's missing, suggest correct command
5. Determine sub-step entry point (see State-Aware Resumption)
6. Execute using the standard Phase Execution Pattern from SKILL.md
7. Update workflow-state.json after each sub-step
8. Present results with 🔲 **Your turn** block

## Prerequisites

| Command | Required artifacts | Required state |
|---------|-------------------|----------------|
| `start` | — | — |
| `resume` | workflow-state.json | — |
| `status` | workflow-state.json | — |
| `next` | workflow-state.json | — |
| `context` | — | initialized |
| `requirements` | context.md | context ∈ completedPhases |
| `units` | requirements.md | requirements ∈ completedPhases |
| `foundation` | units.md | units ∈ completedPhases, mode = incremental |
| `design` | requirements.md, (units.md + foundation.md if incremental) | requirements ∈ completedPhases, (incremental: a unit must be `"in-progress"` in `units[]`) |
| `tasks` | design.md, design/* | design ∈ completedPhases |
| `implement` | tasks.md | tasks ∈ completedPhases |

## State-Aware Resumption

Each phase command checks what already exists and picks up from the right sub-step. This prevents re-doing work when a user re-invokes a command.

### Phase commands (requirements, units, foundation, design, tasks):

1. Does the decisions file exist AND have filled answers?
   - No → start from decisions action
   - Yes, but not validated → run validation
   - Yes, validated → check next

2. Does the artifact exist (requirements.md, units.md, etc.)?
   - No → run generation action
   - Yes → ask: "Already exists. Re-generate from decisions, or edit?"

### Context command:
- context.md exists? → ask: "Re-run assessment or edit existing?"
- No → run context-assessment

### Implement command:
- Check `implementation.currentTask` or `implementation.currentWave` in state first — if set, resume from that point
- If not set: read tasks.md, find first incomplete task as fallback
- Check implementationMode in state (standard/parallel)
  - Not set → ask user to choose
  - Set → resume from current task/wave

## The `next` Command

Reads nextAction from workflow-state.json and maps to the appropriate phase command. See `{SHARED_DIR}/workflow-state.md` → Next Action Map for the full mapping.

General pattern:
- `*-decisions` → dispatches to the corresponding phase command
- `validate-*-decisions` → dispatches to same phase (picks up at validation)
- `generate-*` → dispatches to same phase (picks up at generation)
- `routing-decision`, `ask-design-approach`, `select-unit`, `complete` → inline routing actions (see below)
- `implementing-wave-{N}` / `implementing-task-{N}` → `implement` (resumes at that point)

Note: `next` is the current guided flow expressed as state dispatch. Users who say "proceed" / "continue" / "ok" trigger `next`.

## Inline Routing Actions

Some transitions aren't phase commands — they're routing decisions handled inline by the orchestrator:

- **routing-decision**: Analyze requirements complexity → set nextAction to `units-decisions` or `design-decisions`. Present recommendation, let user override.
- **ask-design-approach**: Ask incremental/comprehensive → set mode in state.
- **select-unit**: Present unit list → set selected unit's entry in main state `units[]` to `status: "in-progress"`, `currentPhase: "design"`, `nextAction: "design-decisions"` → set main state top-level `nextAction` to `design-decisions`.
- **complete**: Ask standard/parallel → set `implementationMode`, `implementation.totalTasks` (count from tasks.md), `implementation.currentTask` to first task ID (standard) or `implementation.currentWave` to `1` (parallel) → set `nextAction` to `implementing-task-{first}` or `implementing-wave-1` (see `{SHARED_DIR}/workflow-state.md` → Implementation State Update Points).

These stay in SKILL.md's Phase Routing Logic section.
