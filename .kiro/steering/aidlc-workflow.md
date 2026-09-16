---
inclusion: always
---

# AI-DLC Workflow Active — helpdesk-agent

## Recovery (read this after context compaction)

If you've lost context or are unsure what to do next:
1. Read `.aidlc/workflow/helpdesk-agent/workflow-state.json` for current phase and next action
2. Activate the skill: `Use the aidlc skill to continue working on helpdesk-agent`
3. The skill will resume from the correct phase

**CRITICAL**: After context compaction, treat ALL previously-read files as lost. Re-read phase instructions, templates, guides, and artifacts from disk before generating anything. Do NOT rely on conversation history.

## Current State

- **Feature**: helpdesk-agent
- **Language**: th
- **Specs**: `.kiro/specs/helpdesk-agent/`
- **Workflow state**: `.aidlc/workflow/helpdesk-agent/workflow-state.json`
- **Skill**: `.kiro/skills/aidlc/SKILL.md`
- **Phase prompts**: `.kiro/skills/aidlc/references/phase-prompts/`
- **Templates**: `.kiro/skills/aidlc/assets/`

## How to Continue

Activate the `aidlc` skill:

    Use the aidlc skill to continue working on helpdesk-agent

The skill handles all workflow state, phase routing, and artifact management.

## Implementation Context

When implementing tasks directly (outside the full skill workflow), read the design documents first:

### Determine Context Folder

- Unit workstream: task file at `.kiro/specs/helpdesk-agent-<unit>/tasks.md` → design docs at same folder
- Main feature: task file at `.kiro/specs/helpdesk-agent/tasks.md` → design docs at same folder
- Always also read `.kiro/specs/helpdesk-agent/foundation.md` (if exists) for shared conventions

### Design Documents (follow precisely)

- `design.md` — architecture overview
- `design/components.md` — component specs
- `design/data-model.md` — entities and schemas
- `design/api-spec.md` — endpoints and contracts
- `design/integration.md` — external services and event schemas
- `design/implementation.md` — directory structure and conventions

### Key Rules

- ALWAYS read templates from `.kiro/skills/aidlc/assets/` before generating artifacts — do NOT guess formats
- Follow technology stack and patterns from design decisions — do not deviate
- Follow testing approach from D4 decisions (TDD, test-after, outside-in)
- Mark tasks complete after all tests pass: `- [ ]` → `- [x]` on task checkboxes

### Project-specific notes

- แพลตฟอร์มเป็น low-code (Microsoft Copilot Studio + Power Automate) — "implementation" หมายถึงแก้ไฟล์ `*.mcs.yml`, `workflow.json`, ปรับ SharePoint list schema แล้ว deploy ผ่าน `pac copilot push/publish`
- เนื้อหา/บทสนทนาเป็นภาษาไทย (locale 1054); เก็บชื่อ field, KB_ID, ชื่อ connector เป็นภาษาอังกฤษ
