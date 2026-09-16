# D4 Tasks Decisions — unit: knowledge-answering

## Context Summary
- **Unit**: `knowledge-answering` — Search/answer, disambiguation, required-info, guardrails, no-answer handoff
- **Design**: `.kiro/specs/helpdesk-agent-knowledge-answering/design.md`
- **Depends on**: foundation (guardrail baseline, KnowledgeGaps, handoff OpenCase)

> เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

### D4-1: กลยุทธ์แตกงาน
- 1) ตาม behavior: guardrails/instructions → grounded answer + KB_ID → required-info → disambiguation → no-answer handoff **(Recommended)**
- 2) ตาม story
- 3) Other: _______

**Answer**: 1

---

### D4-2: แนวทางการทดสอบ
- 1) Test-after (Copilot Studio Test pane + ชุดคำถามตัวอย่างจาก KB) **(Recommended)**
- 2) Test-first
- 3) Other: _______

**Answer**: 1

---

### D4-3: ความละเอียดของงาน
- 1) ละเอียด (~0.5–1 วัน/task) **(Recommended)**
- 2) หยาบ
- 3) Other: _______

**Answer**: 1

---

### D4-4: โหมดการลงมือ
- 1) Standard **(Recommended)**
- 2) Parallel
- 3) Other: _______

**Answer**: 1

---

### D4-5: ขอบเขตการทดสอบ
- 1) UAT checklist INV-KA1~6 + ชุดคำถามตัวอย่าง (ตอบได้/หลายรายการ/ตอบไม่ได้/รายการไม่ Active) **(Recommended)**
- 2) เฉพาะ smoke
- 3) Other: _______

**Answer**: 1

---

## Decisions Summary
- D4-1 Breakdown: ตาม behavior (guardrails → answer+KB_ID → required-info → disambiguation → no-answer handoff)
- D4-2 Verification Timing: Test-after (Test pane + ชุดคำถามตัวอย่าง)
- D4-3 Granularity: ละเอียด ~0.5–1 วัน/task
- D4-4 Execution Mode: Standard
- D4-5 Testing Strategy: UAT checklist INV-KA1~6 + ชุดคำถามตัวอย่าง (4 กรณี)

---

**Instructions**: Fill in your answers above and respond with "tasks decisions complete" (หรือ "done" / "use recommendations")
