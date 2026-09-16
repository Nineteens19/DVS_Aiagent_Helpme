# Cross-Platform Compatibility Guide

This guide explains how the AI-DLC skill adapts to different AI assistant platforms.

## Supported Platforms

### Full Support

**Kiro IDE & Kiro CLI**
- ✅ All features fully supported
- ✅ Automatic context injection via `inclusion: always` front-matter
- ✅ Parallel implementation mode with `invokeSubAgent`
- ✅ Optimized with `readMultipleFiles` and `fsWrite`/`fsAppend`

**Claude Code**
- ✅ All core phases work (Phases 1-6)
- ✅ Context persistence via `CLAUDE.md` + memory system
- ✅ Parallel implementation mode via `Agent` tool (may execute sequentially internally)
- ✅ Standard toolset: `Read`, `Write`, `Edit`, `Agent`, `Bash`

### Basic Support

**Cursor, Windsurf, Other AI Assistants**
- 🟡 Core workflow works (Phases 1-6)
- ⚠️ Manual context management required after compaction
- ⚠️ Standard implementation mode only (no parallel)
- ⚠️ May require sequential file operations

## Environment Detection

The skill auto-detects the platform at initialization. See SKILL.md → ENVIRONMENT DETECTION for the full detection logic.

Detection result is stored in `workflow-state.json`:
```json
{
  "platform": "claude-code",
  "feature": "my-feature",
  "language": "en"
}
```

## Tool Mapping

See `{SHARED_DIR}/tool-rules.md` for the canonical tool rules used by all phase prompts, and `{SHARED_DIR}/workflow-rules.md` Section 4 for the full tool compatibility matrix.

### Sub-Agent Execution

| Platform | Tool | Notes |
|----------|------|-------|
| Kiro | `invokeSubAgent` | Multiple sub-agents in single turn |
| Claude Code | `Agent` with `subagent_type: "general-task-execution"` | May execute sequentially internally |
| Other | Not available | Use sequential standard mode |

### Task Tracking

| Platform | Method |
|----------|--------|
| Kiro | `taskStatus` tool |
| Claude Code | `TaskUpdate` tool OR `Edit` to change `- [ ]` → `- [x]` |
| Other | `Edit` to change `- [ ]` → `- [x]` |

## Directory Structure

The skill adapts directory paths based on platform:

### Kiro
```
.kiro/
├── specs/{feature}/
│   ├── context.md
│   ├── requirements.md
│   └── design/
├── steering/
│   ├── product.md (with inclusion: always)
│   ├── tech.md
│   ├── structure.md
│   └── aidlc-workflow.md
└── skills/
    └── aidlc/
        ├── SKILL.md
        ├── assets/
        └── references/
```

### Claude Code
```
.claude/
├── specs/{feature}/
│   ├── context.md
│   ├── requirements.md
│   └── design/
├── steering/
│   ├── product.md (no front-matter)
│   ├── tech.md
│   ├── structure.md
│   └── aidlc-workflow.md
└── skills/
    └── aidlc/
        ├── SKILL.md
        ├── assets/
        └── references/
CLAUDE.md (at project root)
```

### Other Platforms
```
.ai/
├── specs/{feature}/
├── steering/
└── skills/aidlc/
```

### Common (All Platforms)
```
.aidlc/
└── workflow/{feature}/
    ├── workflow-state.json
    ├── audit.md
    ├── decisions-*.md
    └── (incremental mode: {feature}-{unit}/)
```

## Context Management

### Kiro
- **Steering files**: Uses YAML front-matter `inclusion: always`
- **Auto-injection**: Files automatically re-inject after context compaction
- **No action needed**: Steering files are always available in context
- **Manual recovery**: Not needed

### Claude Code
- **Steering files**: Created in `.claude/steering/` but NOT auto-injected
- **Phase prompts**: Explicitly read steering files at start of each action
- **CLAUDE.md**: Project root context file for high-level recovery
- **Memory system**: Leverages Claude Code's built-in memory for patterns
- **Manual recovery**: Read `CLAUDE.md` + `workflow-state.json` if context lost

**Important:** Steering files work differently on Claude Code:
- ✅ Files are created and maintained
- ✅ Phase prompts automatically read them when needed
- ❌ NOT automatically injected like in Kiro
- ✅ Explicit reading is more context-efficient anyway

### Other Platforms
- **Steering files**: Created but require manual reading
- **Manual recovery**: Via `workflow-state.json`
- **No automation**: Check `nextAction` field to resume
- **Re-read needed**: SKILL.md and phase prompts as needed

## Implementation Modes

### Standard Mode (All Platforms)
- Execute tasks one at a time in sequential order
- Review and test after each task
- Full support on all platforms

### Parallel Mode

**Kiro:**
- ✅ Full parallel execution via `invokeSubAgent`
- Multiple tasks execute simultaneously per wave
- Requires `/tools trust-all` (CLI) or Autopilot mode (IDE)

**Claude Code:**
- ✅ Uses `Agent` tool for each task in wave
- May execute sequentially internally (platform limitation)
- No special prerequisites needed
- Still faster than standard mode for independent tasks

**Other:**
- ⚠️ Not recommended — may require frequent approvals
- Consider using standard mode instead

## Platform-Specific Prerequisites

### Kiro CLI
Before parallel mode:
```bash
/tools trust-all
# or
/tools trust read write shell
```

### Kiro IDE
Ensure Autopilot mode is enabled (no per-tool prompts)

### Claude Code
No prerequisites — tool approval handled automatically

### Other
Warn user about potential approval prompts

## Feature Availability Matrix

| Feature | Kiro | Claude Code | Other |
|---------|------|-------------|-------|
| Phase 1-6 (Core workflow) | ✅ | ✅ | ✅ |
| Decision gates | ✅ | ✅ | ✅ |
| Incremental mode | ✅ | ✅ | ✅ |
| Standard implementation | ✅ | ✅ | ✅ |
| Parallel implementation | ✅ | ✅ (may be slower) | ⚠️ |
| Auto context injection | ✅ | ❌ (uses CLAUDE.md) | ❌ |
| Resume after compaction | ✅ | ✅ | 🟡 (manual) |
| Batch file operations | ✅ | ✅ (parallel calls) | 🟡 (sequential) |

## Best Practices

### For Kiro Users
- Use parallel mode for faster implementation
- Trust tools before starting parallel waves
- Rely on automatic context injection

### For Claude Code Users
- Check `CLAUDE.md` is updated after each phase
- Use memory system for project-specific patterns
- Parallel mode works but may not be significantly faster
- Leverage built-in task tracking

### For Other Platform Users
- Use standard implementation mode
- Manually track workflow state
- Keep `workflow-state.json` bookmarked for resume
- Consider sequential file operations to avoid errors

## Troubleshooting

### Context Lost After Compaction

**Kiro:** Should not happen (auto-inject). If it does, check `inclusion: always` in steering files.

**Claude Code:** Read `CLAUDE.md` + `workflow-state.json` to resume. Update memory with key patterns.

**Other:** Read `workflow-state.json`, check `nextAction`, re-read SKILL.md.

### Tool Not Found Errors

**Symptom:** `fsWrite is not defined` or similar

**Solution:** Environment detection may have failed. Manually check:
1. Is the correct directory structure in place? (`.kiro/`, `.claude/`, `.ai/`)
2. Is `platform` field set correctly in `workflow-state.json`?
3. Force detection by creating the expected directory

### Parallel Mode Not Working

**Kiro:** Check tool trust settings (`/tools trust-all`)

**Claude Code:** This is expected — parallel waves may execute sequentially. No action needed.

**Other:** Use standard mode instead.

### Files Not Being Created

**Check:**
1. Are you using the correct tool for your platform?
2. Is the path correct for your platform's directory structure?
3. Check file permissions on the target directory

## Migration Between Platforms

To migrate a workflow from one platform to another, see `MIGRATION.md` for detailed instructions.
