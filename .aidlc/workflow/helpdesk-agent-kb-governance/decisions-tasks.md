# D4 Tasks Decisions — unit: kb-governance

## Context Summary
- **Unit**: `kb-governance` — gap report views, KB approval lifecycle, gap→KB linkage
- **Design**: `.kiro/specs/helpdesk-agent-kb-governance/design.md`
- **Depends on**: foundation (`KnowledgeGaps`, `KnowledgeBase`)

> เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

### D4-1: กลยุทธ์แตกงาน
- 1) ตาม capability: gap views → KB lifecycle (สถานะ/permission) → gap→KB linkage → (option) CompileGap flow **(Recommended)**
- 2) ตาม story
- 3) Other: _______

**Answer**: 1

---

### D4-2: แนวทางการทดสอบ
- 1) Test-after (ตรวจ views + ทดสอบเปลี่ยนสถานะ/สิทธิ์) **(Recommended)**
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
- 1) UAT checklist INV-KG1~4 + ทดสอบ: gap ซ้ำเพิ่ม frequency, อนุมัติ→ agent ใช้ได้, รายการไม่อนุมัติ→ไม่ถูกใช้ **(Recommended)**
- 2) เฉพาะ smoke
- 3) Other: _______

**Answer**: 1

---

## Decisions Summary
- D4-1 Breakdown: ตาม capability (gap views → KB lifecycle → gap→KB → option CompileGap)
- D4-2 Verification Timing: Test-after
- D4-3 Granularity: ละเอียด ~0.5–1 วัน/task
- D4-4 Execution Mode: Standard
- D4-5 Testing Strategy: UAT checklist INV-KG1~4 + ทดสอบ dedup/approval/usage

---

**Instructions**: Fill in your answers above and respond with "tasks decisions complete" (หรือ "done" / "use recommendations")
