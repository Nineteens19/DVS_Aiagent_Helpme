# D4 Tasks Decisions — unit: notification-followup

## Context Summary
- **Unit**: `notification-followup` — ack content, NotifyStatusChange, RemindStaleCases, CaseStatus topic
- **Design**: `.kiro/specs/helpdesk-agent-notification-followup/design.md`
- **Depends on**: foundation (flow shells, Cases/SLAConfig, templates)

> เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

### D4-1: กลยุทธ์แตกงาน
- 1) ตาม component: ack content → NotifyStatusChange → RemindStaleCases → CaseStatus topic **(Recommended)**
- 2) ตาม story
- 3) Other: _______

**Answer**: 1

---

### D4-2: แนวทางการทดสอบ
- 1) Test-after (run history + ตรวจอีเมล/สถานะ) **(Recommended)**
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
- 1) UAT checklist INV-NF1~4 + smoke (เปลี่ยนสถานะ→อีเมล; พิมพ์ CaseID/"เคสของฉัน"→เห็นสถานะ; รัน SLA reminder) **(Recommended)**
- 2) เฉพาะ smoke
- 3) Other: _______

**Answer**: 1

---

## Decisions Summary
- D4-1 Breakdown: ตาม component (ack → NotifyStatusChange → RemindStaleCases → CaseStatus)
- D4-2 Verification Timing: Test-after (run history + ตรวจอีเมล/สถานะ)
- D4-3 Granularity: ละเอียด ~0.5–1 วัน/task
- D4-4 Execution Mode: Standard
- D4-5 Testing Strategy: UAT checklist INV-NF1~4 + smoke end-to-end

---

**Instructions**: Fill in your answers above and respond with "tasks decisions complete" (หรือ "done" / "use recommendations")
