# Changelog

## Version 6.2.0 - Project-Wide Cleanup (2026-03-23)

### Improvements

**Stale reference cleanup**
- Removed 7 references to deleted files (`path-resolution.md`, `decision-gate-pattern.md`) across 6 templates and workflow-rules.md

**Cross-platform fix**
- `steering-workflow-template.md`: Replaced hardcoded `.kiro/` paths with `{SKILL_DIR}` variables

**Extracted shared tool rules**
- New `tool-rules.md`: Consolidated duplicated file operations and batch reading rules from 7 phase prompts (~72 lines removed)
- Phase prompts now reference `{SHARED_DIR}/tool-rules.md` instead of repeating rules inline
- `workflow-rules.md` Section 4 now references `tool-rules.md` for file/batch rules
- `cross-platform-compatibility.md` now references `tool-rules.md` and `workflow-rules.md` instead of duplicating tool mapping tables

**Richer validation rules**
- `validation-rules-d1.md`: Added 2 rules (Many Integrations Without Priority, Broad Scope Without Boundaries) — now 4 total
- `validation-rules-d4.md`: Added 2 rules (Outside-In Without E2E Framework, No CI/CD With Production) — now 5 total

**Reduced duplication**
- `command-dispatcher.md`: Replaced duplicated nextAction mapping table with reference to `workflow-state.md`
- `cross-platform-compatibility.md`: Removed duplicated environment detection logic and migration steps (reference SKILL.md and MIGRATION.md)
- `skills/aidlc/README.md`: Replaced duplicated installation section with reference to root README

**Condensed technology catalog**
- `technology-questions-catalog.md`: Condensed verbose "When to ask" / "Skip when" blocks from 5-8 lines to 2 lines each (~40 lines saved)

**Documentation cleanup**
- Deleted `IMPLEMENTATION_SUMMARY.md` (internal dev journal, duplicated CHANGELOG/MIGRATION content)
- Updated `QUICK_START_CLAUDE_CODE.md`: Removed stale version reference, added command mode to common commands
- Updated `MIGRATION.md`: Title now covers v6.x instead of just v6.0.0

### New Files

- `references/shared/tool-rules.md`

### Deleted Files

- `IMPLEMENTATION_SUMMARY.md`

---

## Version 6.1.0 - Command Mode (2026-03-23)

### New Features

**Command Dispatcher**
- 11 user-facing commands for direct phase invocation: `start`, `resume`, `status`, `next`, `context`, `requirements`, `units`, `foundation`, `design`, `tasks`, `implement`
- Each phase command bundles the full two-step pattern (decisions → validate → generate) internally
- State-aware resumption: commands check what already exists and pick up from the right sub-step
- Prerequisite validation: commands report missing artifacts and suggest the correct command to run first
- `next` command maps workflow-state.json nextAction to the appropriate phase command

### Updated Files

- `SKILL.md`: Added Command Mode section referencing the dispatcher
- `README.md`: Updated architecture diagram with command mode, added command reference table
- `CHANGELOG.md`: This entry

### New Files

- `references/shared/command-dispatcher.md`: Command registry, dispatch process, prerequisites, state-aware resumption, nextAction mapping

### Notes

- Guided flow remains the default for new workflows
- Command mode is optional — for users who want to jump to specific phases, re-run steps, or resume after a break
- No changes to phase prompts, templates, or workflow-state.json schema
- Fully backward compatible with v6.0.0

---

## Version 6.0.0 - Cross-Platform Support (2026-03-18)

### Major Changes

**Cross-Platform Compatibility**
- Added support for Claude Code with full feature parity
- Added basic support for Cursor, Windsurf, and other AI assistants
- Automatic environment detection and tool adaptation
- Platform-specific optimizations for each environment

### New Features

**Environment Detection System**
- Auto-detects Kiro IDE, Claude Code, and generic platforms
- Stores platform information in workflow-state.json
- Adapts tool usage automatically based on detected platform

**Claude Code Integration**
- CLAUDE.md template for context persistence
- Updated Business Analyst phase to generate CLAUDE.md
- Leverages Claude Code's memory system
- Full support for Agent tool and task tracking

**Adaptive Tool Mapping**
- Kiro: fsWrite, fsAppend, readMultipleFiles, invokeSubAgent
- Claude Code: Write, Edit, Read (parallel), Agent
- Other: Write, Edit, Read (sequential)

**Platform-Specific Directory Structures**
- Kiro: .kiro/specs, .kiro/steering, .kiro/skills
- Claude Code: .claude/specs, .claude/steering, .claude/skills
- Other: .ai/specs, .ai/steering, .ai/skills
- Common: .aidlc/workflow (all platforms)

### Updated Files

**Core Files**
- `SKILL.md`: Environment detection, path configuration, parallel mode updates
- `README.md`: Cross-platform installation instructions, compatibility matrix

**Phase Prompts** (Tool compatibility updates)
- `business-analyst.md`: CLAUDE.md generation, environment-aware file ops
- `product-owner.md`: Tool compatibility rules
- `solution-architect.md`: Tool compatibility rules
- `software-architect.md`: Tool compatibility rules
- `tech-lead.md`: Tool compatibility rules
- `software-engineer.md`: Task tracking compatibility, file operations

**Shared References**
- `workflow-state.md`: Platform field, context recovery strategies
- `workflow-rules.md`: Tool compatibility section

**New Files**
- `assets/claude-md-template.md`: Context persistence for Claude Code
- `references/guides/cross-platform-compatibility.md`: Comprehensive platform guide

### Compatibility

**Fully Supported (All Features)**
- Kiro IDE
- Kiro CLI
- Claude Code

**Basic Support (Core Features)**
- Cursor
- Windsurf
- Other AI assistants with file system access

### Migration from v5.0.0

**For Existing Kiro Users**
- No changes required — v6.0.0 is fully backward compatible
- Existing workflows will continue to work without modification
- Optional: Add platform field to existing workflow-state.json files

**For New Claude Code Users**
1. Install skill to `.claude/skills/aidlc/`
2. CLAUDE.md will be generated automatically during Phase 1
3. Use standard Claude Code tools (Write, Edit, Read, Agent)

**For Other Platform Users**
1. Install skill to `.ai/skills/aidlc/`
2. Expect manual context management
3. Use standard implementation mode

### Breaking Changes

None — v6.0.0 is fully backward compatible with v5.0.0

### Known Limitations

**Claude Code**
- Parallel mode may execute tasks sequentially internally (platform limitation)
- Manual CLAUDE.md updates recommended after context compaction

**Other Platforms**
- No automatic context injection
- Standard implementation mode only
- Manual workflow state management

### Contributors

- AI-DLC Maintainers
- Cross-platform compatibility analysis and implementation

---

## Version 5.0.0 - Skill-Based Architecture (Previous Release)

Major refactoring to skill-based architecture for Kiro IDE.

**Key Features:**
- Skill-based entry point (SKILL.md)
- Direct phase execution (no sub-agent delegation)
- Persona-driven phases
- Decision gates with validation
- Incremental mode
- Parallel implementation
- Context-efficient loading

---

For detailed upgrade instructions, see MIGRATION.md
