# Quick Start - Claude Code

Get started with AI-DLC Skill on Claude Code in 5 minutes.

## Installation (1 minute)

```bash
cd /path/to/your/project
mkdir -p .claude/skills
cp -r /path/to/aidlc-skill-v2/skills/aidlc .claude/skills/
```

## Usage (30 seconds)

In Claude Code chat:

```
Use the aidlc skill to create a spec for [your feature description]
```

For example:
```
Use the aidlc skill to create a spec for a user authentication system with email/password login and JWT tokens
```

## What Happens Next

### Phase 1: Context Assessment (2-3 minutes)

Claude will:
1. Scan your project structure
2. Detect your tech stack (if existing project)
3. Generate `context.md`
4. Generate 4 steering files in `.claude/steering/`
5. **Generate `CLAUDE.md` at project root** (important for context persistence)

**You'll see:**
```
📍 Context Assessment: Complete (1 of 6 phases)

- **Project Type**: Brownfield
- **Stack**: Node.js + Express + PostgreSQL
- **Architecture**: Monolithic REST API
...

Artifact at `.claude/specs/auth-system/context.md`

---
🔲 **Your turn**:
- ✅ "proceed" — move to Requirements Decisions
- ✏️ "change [what]" — request edits
```

**Action:** Review the context, then say `proceed`

### Phase 2: Requirements (5-10 minutes)

**Step 1 - Decisions:**
Claude generates `decisions-requirements.md` with questions like:
- What user types will interact with this feature?
- What are the core capabilities?
- What's the priority?

**Action:** Open the decision file, fill in your answers, say `done`

**Step 2 - Generation:**
Claude generates `requirements.md` with user stories in EARS format

**Action:** Review, then say `proceed`

### Phase 3: Units (Optional - Complex Projects Only)

If your feature is complex (5+ stories), Claude recommends decomposing into units.

**Skip for simple features** — goes straight to Phase 4.

### Phase 4: Design (10-15 minutes)

**Step 1 - Decisions:**
Claude generates `decisions-design.md` asking:
- What's your tech stack?
- REST, GraphQL, or gRPC?
- Testing approach?
- Infrastructure choices?

**Action:** Fill answers, say `done`

**Step 2 - Generation:**
Claude generates multiple design files:
- `design.md` - Overview
- `design/components.md` - Architecture
- `design/data-model.md` - Database schema
- `design/api-spec.md` - API endpoints
- `design/implementation.md` - Setup instructions

**Action:** Review all design files, say `proceed` when ready

### Phase 5: Tasks (5 minutes)

**Step 1 - Decisions:**
Choose implementation approach (TDD, test-after, etc.)

**Step 2 - Generation:**
Claude generates `tasks.md` with:
- Task breakdown
- Dependency order
- Execution waves (for parallel mode)
- Test coverage plan

**Action:** Review, say `proceed`

### Phase 6: Implementation (Hours to Days)

Choose mode:

**Standard Mode (Recommended for Learning):**
- One task at a time
- Review and test after each
- Easy to follow

**Parallel Mode (Faster):**
- Multiple tasks per wave
- Review per wave (not per task)
- Requires more context management

**Action:** Say `standard` or `parallel`

Claude will implement each task, run tests, and report progress.

## File Structure After Phase 1

```
your-project/
├── CLAUDE.md                    ← Context persistence (NEW!)
├── .claude/
│   ├── specs/
│   │   └── auth-system/
│   │       └── context.md
│   ├── steering/
│   │   ├── product.md          ← Auto-loaded context
│   │   ├── tech.md
│   │   ├── structure.md
│   │   └── aidlc-workflow.md
│   └── skills/
│       └── aidlc/              ← The skill files
└── .aidlc/
    └── workflow/
        └── auth-system/
            ├── workflow-state.json
            └── audit.md
```

## Important: Context Persistence

**CLAUDE.md is your recovery mechanism.**

If Claude loses context (after long conversations), it will read `CLAUDE.md` to recover:
- Current phase
- Current feature
- Next action
- Key paths

The skill updates `CLAUDE.md` automatically after each phase.

## Common Commands

| You Say | Claude Does |
|---------|-------------|
| `proceed` | Move to next phase/step |
| `done` | Signal decision form filled |
| `use recommendations` | Fill decisions with suggested values |
| `change [what]` | Edit current artifact |
| `continue my [feature] spec` | Resume after break |
| `standard` / `parallel` | Choose implementation mode |
| `context` / `requirements` / `design` / `tasks` | Jump directly to a phase (command mode) |
| `status` | Show current progress |

## Quick Tips

### ✅ Do

- Review each artifact before proceeding
- Fill decision forms completely
- Test as you implement
- Keep `CLAUDE.md` updated if you make manual edits

### ❌ Don't

- Skip decision gates
- Proceed without reviewing artifacts
- Edit generated files without telling Claude
- Delete `CLAUDE.md` or `workflow-state.json`

## Example Session

```
You: Use the aidlc skill to create a spec for a blog API with posts, comments, and users

Claude: [Phase 1 Context Assessment]
        - Generates context.md
        - Creates CLAUDE.md
        - Creates steering files

You: proceed

Claude: [Phase 2 D1 Requirements Decisions]
        - Generates decisions-requirements.md

You: done

Claude: [Phase 2 Requirements Generation]
        - Generates requirements.md with 8 user stories

You: proceed

Claude: [Analysis] This is simple (≤4 stories?). Skipping to Phase 4.

Claude: [Phase 4 D3 Design Decisions]
        - Generates decisions-design.md

You: done

Claude: [Phase 4 Design Generation]
        - Generates design.md, design/components.md, etc.

You: proceed

Claude: [Phase 5 D4 Tasks Decisions]
        - Generates decisions-tasks.md

You: done

Claude: [Phase 5 Tasks Generation]
        - Generates tasks.md with 12 tasks

You: proceed

Claude: Choose implementation mode: standard or parallel?

You: standard

Claude: [Phase 6 Implementation]
        - Implements Task 1.1: Project setup
        - Creates files, runs tests
        - Reports completion

You: next

Claude: [Phase 6 Implementation]
        - Implements Task 1.2: Database schema
        ...
```

## Troubleshooting

### "I don't see CLAUDE.md"

**Check:** Did Phase 1 complete? CLAUDE.md is generated during context assessment.

**Fix:** Re-run Phase 1 or create it manually from `skills/aidlc/assets/claude-md-template.md`

### "Context was lost after long conversation"

**Recovery:**
1. Read `CLAUDE.md` for current state
2. Read `.aidlc/workflow/{feature}/workflow-state.json`
3. Say: `continue my [feature] spec`

### "Parallel mode seems slow"

**This is expected.** Claude Code's Agent tool may execute tasks sequentially internally.

**Recommendation:** Use standard mode for better visibility, or accept that parallel mode may not be much faster on Claude Code.

### "I want to change a design after Phase 4"

Say: `change [what you want to change in the design]`

Claude will re-adopt the Software Architect persona and update the design files.

## Next Steps

After completing a spec:
- Use the implementation tasks as a roadmap
- Let Claude implement in standard or parallel mode
- Or implement manually using the design docs
- Deploy using instructions in `design/implementation.md`

## Learn More

- **Full documentation:** See `README.md`
- **Platform comparison:** See `references/guides/cross-platform-compatibility.md`
- **Migration from Kiro:** See `MIGRATION.md`
- **Version history:** See `CHANGELOG.md`

## Need Help?

- Check `CLAUDE.md` for current state
- Check `workflow-state.json` for next action
- Re-read `SKILL.md` if confused about workflow
- Ask Claude to explain what it's doing

## Time Estimates

| Phase | Typical Duration |
|-------|------------------|
| Phase 1: Context | 2-3 minutes |
| Phase 2: Requirements | 5-10 minutes |
| Phase 3: Units (if needed) | 10-15 minutes |
| Phase 4: Design | 10-20 minutes |
| Phase 5: Tasks | 5 minutes |
| Phase 6: Implementation | Hours to days (depends on size) |

**Total spec time (Phases 1-5):** 20-40 minutes for simple features

**Implementation time:** Varies widely (could be 2 hours to 2 weeks)

---

**You're ready to go!** Start with a simple feature to learn the workflow, then tackle more complex projects.
