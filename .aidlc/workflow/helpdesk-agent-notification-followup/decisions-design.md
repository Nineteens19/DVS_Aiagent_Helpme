# D3 Design Decisions — unit: notification-followup

## Context Summary
- **Unit**: `notification-followup` — US-010, US-011, US-012, US-013 (acknowledgment, แจ้งเปลี่ยนสถานะ, เช็คสถานะเอง, SLA reminder)
- **Settled by foundation**: flows `CreateCaseAndAck` (ack), `NotifyStatusChange`, `RemindStaleCases`, email templates, `SLAConfig`, `Cases.LastNotifiedStatus`/`SlaDueDate`
- **D3 นี้โฟกัส**: เนื้อหา/นโยบายการแจ้ง + topic เช็คสถานะ (agent-side)

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### D3-1: เนื้อหาอีเมล Acknowledgment (US-010)
**Question**: อีเมล ack ถึงผู้แจ้งควรมีอะไร?
- 1) CaseID + สรุปเรื่อง + เวลาตอบสนองโดยประมาณ (จาก SLA) + ช่องทางติดตาม **(Recommended)**
- 2) CaseID + ข้อความสั้นเท่านั้น
- 3) Other: _______

**Answer**: 1

---

### D3-2: สถานะที่จะแจ้งผู้แจ้ง (US-011)
**Question**: จะแจ้งเมื่อสถานะเปลี่ยนเป็นอะไรบ้าง?
- 1) ทุก transition (Open→In Progress→Resolved→Closed) **(Recommended)**
- 2) เฉพาะ Resolved/Closed
- 3) เฉพาะที่ไม่ใช่ Open (In Progress ขึ้นไป)
- 4) Other: _______

**Answer**: 1

---

### D3-3: Topic เช็คสถานะด้วยตนเอง (US-012)
**Question**: ให้ผู้ใช้เช็คสถานะอย่างไร?
- 1) topic ใหม่ `CaseStatus`: พิมพ์ `CaseID` → แสดงสถานะ + อัปเดตล่าสุด **(Recommended)**
- 2) รองรับทั้งพิมพ์ CaseID และ "เคสของฉัน" (แสดงรายการเคสของผู้ใช้)
- 3) Other: _______

**Answer**: 2 (รองรับทั้ง CaseID และ "เคสของฉัน" — UX ดีกว่า)

---

### D3-4: เกณฑ์ SLA และ Escalation (US-013)
**Question**: RemindStaleCases ใช้เกณฑ์อย่างไร?
- 1) อ่าน thresholds จาก `SLAConfig` ตาม Severity + escalate CC เมื่อเกิน; คำนวณแบบ business-hours อย่างง่าย **(Recommended)**
- 2) fixed threshold เดียวทุกเคส
- 3) Other: _______

**Answer**: 1

---

### D3-5: ผู้รับการเตือน SLA (US-013)
**Question**: เตือนใครบ้าง?
- 1) AssignedOwner (To) + CC `EscalateToCC` เมื่อเกินเกณฑ์ **(Recommended)**
- 2) เฉพาะ owner
- 3) Other: _______

**Answer**: 1

---

### D3-6: ความเป็นส่วนตัวของ self-service (US-012 AC3)
**Question**: การเช็คสถานะจำกัดสิทธิ์อย่างไร?
- 1) แสดงเฉพาะเคสที่ `ReporterEmail = System.User.Email` **(Recommended)**
- 2) ใครก็ดูได้ถ้ามี CaseID
- 3) Other: _______

**Answer**: 1

---

### D3-7: Correctness (Invariants) — บังคับถาม
**Question**: ยืนยันความถูกต้องอย่างไร?
- 1) Invariants checklist: "แต่ละการเปลี่ยนสถานะแจ้งครั้งเดียว (ไม่ซ้ำ)", "ack ส่งครั้งเดียวต่อเคส", "self-service เห็นเฉพาะเคสของตน", "reminder เฉพาะเคสที่ยังไม่ปิด" **(Recommended)**
- 2) ใช้ PBT (harness ภายนอก)
- 3) Other: _______

**Answer**: 1

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
- D3-1 Ack Content: CaseID + สรุปเรื่อง + เวลาตอบสนองโดยประมาณ (SLA) + ช่องทางติดตาม
- D3-2 Status Transitions: แจ้งทุก transition (Open→In Progress→Resolved→Closed)
- D3-3 Self-service Topic: `CaseStatus` รองรับทั้งพิมพ์ CaseID และ "เคสของฉัน" (list)
- D3-4 SLA Thresholds: อ่านจาก `SLAConfig` ตาม Severity + escalate CC; business-hours อย่างง่าย
- D3-5 Reminder Recipients: AssignedOwner (To) + CC EscalateToCC เมื่อเกิน
- D3-6 Privacy: แสดงเฉพาะเคสที่ ReporterEmail = System.User.Email
- D3-7 Correctness: invariants checklist (แจ้งครั้งเดียว/ไม่ซ้ำ, ack ครั้งเดียว, self-service เฉพาะเคสตน, reminder เฉพาะเคสไม่ปิด)

---

**Instructions**: Fill in your answers above and respond with "design decisions complete" (หรือ "done" / "use recommendations")
