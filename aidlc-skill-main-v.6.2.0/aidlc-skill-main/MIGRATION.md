# Migration Guide - v5.0.0 to v6.x

This guide helps you upgrade from AI-DLC Skill v5.0.0 (Kiro-only) to v6.x (cross-platform with command mode).

## Overview

Version 6.0.0 adds cross-platform support while maintaining **full backward compatibility** with v5.0.0. If you're using Kiro IDE/CLI, you can upgrade without any changes to your workflow.

## For Existing Kiro Users

### Quick Upgrade (Recommended)

1. **Backup your current setup** (optional but recommended):
   ```bash
   cp -r .kiro/skills/aidlc .kiro/skills/aidlc.backup
   ```

2. **Replace skill files**:
   ```bash
   cp -r skills/aidlc/* .kiro/skills/aidlc/
   ```

3. **Continue working** — No other changes needed!

Your existing workflows in `.aidlc/workflow/{feature}/` will continue to work. The skill will detect that you're using Kiro and use the appropriate tools automatically.

### Optional: Update Existing Workflows

If you have in-progress workflows, you can optionally add the `platform` field to workflow-state.json:

```json
{
  "feature": "my-feature",
  "language": "en",
  "platform": "kiro-ide",  // ← Add this line
  "currentPhase": "design",
  ...
}
```

This is optional — the skill will auto-detect Kiro if the field is missing.

### What Changed for Kiro Users

**Nothing Breaking!** All changes are additive:
- ✅ All existing features work exactly the same
- ✅ Same directory structure (`.kiro/`)
- ✅ Same tools (`fsWrite`, `invokeSubAgent`, etc.)
- ✅ Same steering files with `inclusion: always`
- ✅ Same parallel mode behavior

**What's New:**
- Platform detection (automatic for Kiro)
- Better error messages if running on wrong platform
- Shared codebase with Claude Code support

## For New Claude Code Users

### Fresh Installation

1. **Install the skill**:
   ```bash
   cd /path/to/your/project
   mkdir -p .claude/skills
   cp -r /path/to/aidlc-skill-v2/skills/aidlc .claude/skills/
   ```

2. **Start using the skill**:
   ```
   Use the aidlc skill to create a spec for [your feature]
   ```

3. **CLAUDE.md will be generated automatically** during Phase 1 (Context Assessment)

### What to Expect

**During Phase 1:**
- Skill detects Claude Code environment
- Generates `.claude/specs/{feature}/`, `.claude/steering/`
- Creates `CLAUDE.md` at project root for context persistence

**Throughout Workflow:**
- Uses Claude Code tools: `Write`, `Edit`, `Read`, `Agent`
- Updates `CLAUDE.md` after each phase
- Leverages Claude Code's built-in memory system

**Parallel Mode:**
- Works but may execute sequentially internally
- Still recommended for independent tasks
- No special prerequisites needed

## Migrating Between Platforms

### From Kiro to Claude Code

If you want to move a workflow from Kiro to Claude Code:

1. **Copy workflow state**:
   ```bash
   cp -r .aidlc/workflow/{feature} /path/to/claude-project/.aidlc/workflow/
   ```

2. **Copy specs** to new structure:
   ```bash
   mkdir -p /path/to/claude-project/.claude/specs
   cp -r .kiro/specs/{feature} /path/to/claude-project/.claude/specs/
   ```

3. **Copy steering files** (without front-matter):
   ```bash
   mkdir -p /path/to/claude-project/.claude/steering
   # Copy and remove 'inclusion: always' front-matter:
   sed '/^---$/,/^---$/d' .kiro/steering/product.md > /path/to/claude-project/.claude/steering/product.md
   sed '/^---$/,/^---$/d' .kiro/steering/tech.md > /path/to/claude-project/.claude/steering/tech.md
   sed '/^---$/,/^---$/d' .kiro/steering/structure.md > /path/to/claude-project/.claude/steering/structure.md
   sed '/^---$/,/^---$/d' .kiro/steering/aidlc-workflow.md > /path/to/claude-project/.claude/steering/aidlc-workflow.md
   ```

4. **Update workflow-state.json**:
   ```json
   {
     "platform": "claude-code",  // Change from "kiro-ide"
     ...
   }
   ```

5. **Generate CLAUDE.md** manually using the template:
   ```bash
   cp /path/to/aidlc-skill-v2/skills/aidlc/assets/claude-md-template.md CLAUDE.md
   # Edit CLAUDE.md to fill in {feature}, {currentPhase}, etc.
   ```

6. **Resume** in Claude Code:
   ```
   Continue my [feature] spec
   ```

### From Claude Code to Kiro

If you want to move from Claude Code to Kiro:

1. **Copy workflow state**:
   ```bash
   cp -r .aidlc/workflow/{feature} /path/to/kiro-project/.aidlc/workflow/
   ```

2. **Copy specs**:
   ```bash
   mkdir -p /path/to/kiro-project/.kiro/specs
   cp -r .claude/specs/{feature} /path/to/kiro-project/.kiro/specs/
   ```

3. **Add front-matter to steering files**:
   ```bash
   mkdir -p /path/to/kiro-project/.kiro/steering
   # Add 'inclusion: always' front-matter to each file
   echo -e "---\ninclusion: always\n---\n\n$(cat .claude/steering/product.md)" > /path/to/kiro-project/.kiro/steering/product.md
   echo -e "---\ninclusion: always\n---\n\n$(cat .claude/steering/tech.md)" > /path/to/kiro-project/.kiro/steering/tech.md
   echo -e "---\ninclusion: always\n---\n\n$(cat .claude/steering/structure.md)" > /path/to/kiro-project/.kiro/steering/structure.md
   echo -e "---\ninclusion: always\n---\n\n$(cat .claude/steering/aidlc-workflow.md)" > /path/to/kiro-project/.kiro/steering/aidlc-workflow.md
   ```

4. **Update workflow-state.json**:
   ```json
   {
     "platform": "kiro-ide",  // Change from "claude-code"
     ...
   }
   ```

5. **Resume** in Kiro:
   ```
   Continue my [feature] spec
   ```

## For Other Platforms (Cursor, Windsurf, etc.)

### Installation

1. **Install to generic directory**:
   ```bash
   mkdir -p .ai/skills
   cp -r /path/to/aidlc-skill-v2/skills/aidlc .ai/skills/
   ```

2. **Start workflow**:
   ```
   Use the aidlc skill to create a spec for [your feature]
   ```

### Limitations

- No automatic context injection (manual recovery via workflow-state.json)
- Parallel mode not recommended (use standard mode)
- May need sequential file operations

### Best Practices

- Keep `.aidlc/workflow/{feature}/workflow-state.json` bookmarked
- Check `nextAction` field to know where to resume
- Use standard implementation mode
- Manually re-read SKILL.md after context compaction

## Troubleshooting

### "Tool not found" errors after upgrade

**Symptom:** Errors like `fsWrite is not defined` on Claude Code or `Write is not defined` on Kiro

**Cause:** Platform detection may have failed

**Fix:**
1. Check directory structure matches platform (`.kiro/` for Kiro, `.claude/` for Claude Code)
2. Manually set `platform` in workflow-state.json
3. Restart the conversation

### Parallel mode not working on Claude Code

**This is expected!** Claude Code's Agent tool may execute tasks sequentially internally. This is a platform limitation, not a bug.

**Workaround:** Use standard mode if you need to review each task individually, or accept that parallel mode may be slower on Claude Code.

### CLAUDE.md not being updated

**Fix:** Update it manually after each phase:
```markdown
## Current Workflow State

- **Feature**: my-feature
- **Phase**: design
- **Language**: en
- **Next Action**: tasks-decisions
```

### Context lost after compaction

**Kiro:** Should not happen. Check that steering files have `inclusion: always` front-matter.

**Claude Code:** Read `CLAUDE.md` + `.aidlc/workflow/{feature}/workflow-state.json` to resume.

**Other:** Read `.aidlc/workflow/{feature}/workflow-state.json` and SKILL.md to resume.

## Rollback to v5.0.0

If you need to rollback (though this should not be necessary):

1. **Restore backup**:
   ```bash
   rm -rf .kiro/skills/aidlc
   cp -r .kiro/skills/aidlc.backup .kiro/skills/aidlc
   ```

2. **Remove platform field** from workflow-state.json (optional):
   ```bash
   # Edit .aidlc/workflow/{feature}/workflow-state.json
   # Remove the "platform": "..." line
   ```

3. **Continue** — v5.0.0 workflows are compatible with v6.0.0 state files

## Getting Help

- **Issue Tracker**: https://github.com/awslabs/aidlc-workflows/issues
- **Documentation**: See `skills/aidlc/references/guides/cross-platform-compatibility.md`
- **Known Issues**: See CHANGELOG.md

## Summary

| Scenario | Action Required | Effort |
|----------|----------------|--------|
| Kiro user upgrading | Copy new skill files | 1 minute |
| New Claude Code user | Install to `.claude/skills/` | 2 minutes |
| Migrate Kiro → Claude Code | Copy files, update structure | 5-10 minutes |
| Migrate Claude Code → Kiro | Copy files, add front-matter | 5-10 minutes |
| Other platform | Install to `.ai/skills/` | 2 minutes |

**Bottom Line:** For Kiro users, this is a drop-in replacement with no breaking changes. For Claude Code users, this is a first-class supported platform with full feature parity.
