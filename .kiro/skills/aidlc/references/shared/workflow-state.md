# Workflow State Management

## Resume Detection

Execute at start of every spec session:

1. Check if `{WORKFLOW_DIR}` and `{SPECS_DIR}` exist. Neither → fresh start.
2. Scan `{WORKFLOW_DIR}` for `workflow-state.json` files.
3. 1 found → validate (Step 4). Multiple → find the one with `"type": "main"` and use it as the primary state. Read its `units[]` array to understand unit status. Only ask user if multiple `"type": "main"` files are found or none has `"type": "main"`. 0 → fallback scan (Step 5).
4. **Validate**: Check referenced files exist, verify completed phases have artifacts. Incremental: read `units[]` from main state — filter for `status: "in-progress"`. If exactly one → resume that unit at its `nextAction`. If multiple → present them and ask user which to continue. If none in-progress → go to `select-unit`.
5. **Fallback** (no state file but dirs exist): Detect from artifacts:
   - context.md → Context done
   - decisions-requirements.md filled → D1 done
   - personas.md → Personas done
   - requirements.md → Requirements done
   - decisions-units.md filled → D2 done
   - units.md → Units done
   - foundation.md → Foundation done. Next: select-unit
   - units.md but no foundation and no decisions-design → ask-design-approach
   - decisions-design.md filled → D3 done
   - design.md → Design done
   - decisions-tasks.md filled → D4 done
   - tasks.md → Tasks done
   - tasks.md has `[x]` → Implementation in progress
   - Check for `{SPECS_DIR}/{feature}-{unit}/` folders to detect incremental mode
6. Present resume prompt in user's language.

## State File Schema

Location: `{WORKFLOW_DIR}/{feature}/workflow-state.json`

```json
{
  "feature": "name",
  "language": "en",
  "platform": "claude-code",
  "type": "main",
  "currentPhase": "design",
  "completedPhases": ["context", "d1", "requirements"],
  "nextAction": "design-decisions",
  "mode": null,
  "implementationMode": null,
  "units": [
    {
      "name": "foundation",
      "status": "completed",
      "currentPhase": null,
      "nextAction": null
    },
    {
      "name": "auth",
      "status": "in-progress",
      "currentPhase": "design",
      "nextAction": "generate-design"
    },
    {
      "name": "payments",
      "status": "not-started",
      "currentPhase": null,
      "nextAction": null
    }
  ],
  "implementation": { "totalTasks": 0, "completedTasks": 0, "currentTask": null, "currentWave": null },
  "lastUpdated": "ISO-timestamp"
}
```

**Unit status values**: `"not-started"` → `"in-progress"` → `"completed"`. Each unit entry tracks its own `currentPhase` and `nextAction` so the main state serves as a summary index. The detailed state remains in `{WORKFLOW_DIR}/{feature}-{unit}/workflow-state.json`.

### Unit State Update Points

Update the matching entry in the main state's `units[]` array at these moments:

| Trigger | Update |
|---------|--------|
| User selects a unit | Set `status: "in-progress"`, `currentPhase: "design"`, `nextAction: "design-decisions"` |
| Unit completes a sub-step (D3 validated, design generated, D4 validated, tasks generated) | Update `currentPhase` and `nextAction` to match the unit's current position |
| Unit implementation finishes | Set `status: "completed"`, `currentPhase: null`, `nextAction: null` |
| User switches to a different unit mid-flow | Keep the current unit as `"in-progress"` (do not reset it), set the new unit to `"in-progress"` |

Also update the main state's top-level `nextAction` to match the active unit's `nextAction` so that the `next` command dispatches correctly.

### Implementation State Update Points

Update the `implementation` object in `workflow-state.json` at these moments. For incremental mode, update both the unit state AND the matching `units[]` entry in the main state.

| Trigger | Update |
|---------|--------|
| User chooses standard/parallel | Set `implementationMode`, `implementation.totalTasks` (count from tasks.md), `implementation.currentTask` to first task ID (standard) or `implementation.currentWave` to `1` (parallel), `nextAction` to `implementing-task-{first}` or `implementing-wave-1` |
| Task completed (standard mode) | Increment `implementation.completedTasks`, set `implementation.currentTask` to next task ID, set `nextAction` to `implementing-task-{next}` |
| Wave completed (parallel mode) | Increment `implementation.completedTasks` by wave task count, set `implementation.currentWave` to next wave number, set `nextAction` to `implementing-wave-{next}` |
| All tasks/waves finished | Set `nextAction` to `implementation-complete`, set `implementation.currentTask` and `implementation.currentWave` to `null`, add `"implementation"` to `completedPhases` |

### Unit State Schema

Unit state at `{WORKFLOW_DIR}/{feature}-{unit}/workflow-state.json`:
```json
{
  "feature": "name",
  "language": "en",
  "platform": "claude-code",
  "unit": "unit-name",
  "type": "unit",
  "parentFeature": "name",
  "mainStatePath": "{WORKFLOW_DIR}/{feature}/workflow-state.json",
  "currentPhase": "design",
  "completedPhases": ["d3"],
  "nextAction": "generate-tasks-decisions",
  "implementationMode": null,
  "implementation": { "totalTasks": 0, "completedTasks": 0, "currentTask": null, "currentWave": null },
  "lastUpdated": "ISO"
}
```

`mainStatePath` provides an explicit path back to the parent state file. After context compaction, the orchestrator can read any unit's state and reliably locate the main state without reconstructing paths from memory.

`implementationMode` and `implementation` follow the same schema as the main state. Each unit tracks its own implementation progress independently.

**Platform values:** `"kiro-ide"`, `"kiro-cli"`, `"claude-code"`, `"cursor"`, `"windsurf"`, `"generic"`

`mode` is null until user chooses incremental/comprehensive after units. `implementationMode` is null until user chooses standard/parallel after tasks. `foundation` in completedPhases when foundation.md is generated or skipped (comprehensive mode).

## Context Recovery Strategy

**Kiro:** Relies on `inclusion: always` YAML front-matter in steering files for automatic re-injection after context compaction

**Claude Code:** Relies on `CLAUDE.md` at project root + `workflow-state.json` + Claude Code's memory system

**Other platforms:** Manual resume via `workflow-state.json`

After context compaction/overflow:
1. Detect platform from workflow-state.json
2. For Claude Code: Update `CLAUDE.md` with current phase/state after each phase completion
3. For Kiro: Steering files auto-inject (no action needed)
4. Always update workflow-state.json with nextAction

## Next Action Map

| nextAction | Do |
|---|---|
| context-assessment | Run/resume Phase 1 context assessment |
| requirements-decisions | Generate D1 |
| validate-d1-decisions | Validate D1 |
| generate-requirements | Generate requirements.md |
| routing-decision | Analyze complexity → Phase 3 or 4 |
| units-decisions | Generate D2 |
| validate-d2-decisions | Validate D2 |
| generate-units | Generate units.md |
| ask-design-approach | Ask incremental/comprehensive |
| foundation-decisions | Generate DF Foundation Decisions |
| validate-df-decisions | Validate DF answers |
| generate-foundation | Generate foundation.md |
| select-unit | Present units for selection (infra units first) |
| design-decisions | Generate D3 |
| validate-d3-decisions | Validate D3 |
| generate-design | Generate design.md + design/* |
| tasks-decisions | Generate D4 |
| validate-d4-decisions | Validate D4 |
| generate-tasks | Generate tasks.md |
| complete | Offer implementation mode (standard/parallel) |
| implementing-wave-{N} | Resume wave N in parallel mode |
| implementing-task-{N} | Resume task N in standard mode |
| implementation-complete | All done |
