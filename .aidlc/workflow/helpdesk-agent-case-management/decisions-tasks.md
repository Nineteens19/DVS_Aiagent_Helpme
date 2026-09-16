# D4 Tasks Decisions — unit: case-management

## Context Summary
- **Unit**: `case-management` — redesign `OpenCase`/`Escalate`, CaseType inference, summary, เรียก `CreateCaseAndAck`
- **Design**: `.kiro/specs/helpdesk-agent-case-management/design.md`
- **Depends on**: foundation (flow/lists/templates) — ต้อง implement foundation ก่อนหรือคู่ขนานใน UAT

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### D4-1: กลยุทธ์แตกงาน
**Question**: จัดลำดับงานอย่างไร?
- 1) ตามลำดับบทสนทนา: consolidate topic → CaseType inference → dynamic questions → summary → flow call → confirm CaseID **(Recommended)**
- 2) ตาม story (US-005..009 ทีละตัว)
- 3) Other: _______

**Answer**: 1

---

### D4-2: แนวทางการทดสอบระหว่างทำ
**Question**: ทดสอบตอนไหน?
- 1) Test-after — Copilot Studio Test pane + ตรวจ item ใน `Cases` **(Recommended)**
- 2) Test-first (เขียนสถานการณ์ก่อน)
- 3) Other: _______

**Answer**: 1

---

### D4-3: ความละเอียดของงาน
**Question**: ขนาดงานต่อ task?
- 1) ละเอียด (~0.5–1 วัน/task) **(Recommended)**
- 2) หยาบ (~2–3 วัน/task)
- 3) Other: _______

**Answer**: 1

---

### D4-4: โหมดการลงมือ
**Question**: implement แบบไหน?
- 1) Standard (ตามลำดับ) **(Recommended)**
- 2) Parallel
- 3) Other: _______

**Answer**: 1

---

### D4-5: ขอบเขตการทดสอบ
**Question**: ทดสอบแค่ไหน?
- 1) UAT checklist ต่อ INV-CM1~5 + smoke (แชทเปิดเคสจริง → ได้ CaseID → เห็น item ใน `Cases` + ได้ ack) **(Recommended)**
- 2) เฉพาะ smoke
- 3) Other: _______

**Answer**: 1

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
- D4-1 Breakdown: ตามลำดับบทสนทนา (consolidate → classify → questions → summary → flow call → confirm)
- D4-2 Verification Timing: Test-after (Test pane + ตรวจ `Cases`)
- D4-3 Granularity: ละเอียด ~0.5–1 วัน/task
- D4-4 Execution Mode: Standard
- D4-5 Testing Strategy: UAT checklist ต่อ INV-CM1~5 + smoke end-to-end (แชท → CaseID → item + ack)

---

**Instructions**: Fill in your answers above and respond with "tasks decisions complete" (หรือ "done" / "use recommendations")
