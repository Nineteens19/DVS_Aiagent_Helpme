# D4 Tasks Decisions — unit: foundation

## Context Summary
- **Unit**: `foundation` — 6 SharePoint lists, 3 flows, email templates, error handling, migration
- **Design**: `.kiro/specs/helpdesk-agent-foundation/design.md`
- **จาก D3**: parallel-run migration, UAT→PROD cutover, invariants checklist, ทดสอบ manual (Test pane + run history)

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### D4-1: กลยุทธ์แตกงาน (Task Breakdown)
**Question**: จะจัดลำดับงานอย่างไร?
- 1) ตาม dependency: lists → config data → flows → email templates → error handling → migration/cutover **(Recommended)**
- 2) ตาม flow (แต่ละ flow ทำครบเครื่องทีละตัว)
- 3) Other: _______

**Answer**: 1 (ตาม dependency)

---

### D4-2: แนวทางการทดสอบระหว่างทำ (Verification Timing)
**Question**: จะทดสอบตอนไหน?
- 1) Test-after — สร้าง artifact แล้วทดสอบด้วย UAT checklist / Test pane / run history **(Recommended สำหรับ low-code)**
- 2) Test-first — เขียนสถานการณ์ทดสอบ (checklist) ก่อนสร้าง
- 3) Other: _______

**Answer**: 1 (Test-after ด้วย UAT checklist)

---

### D4-3: ความละเอียดของงาน (Task Granularity)
**Question**: ขนาดงานต่อ task?
- 1) ละเอียด (~0.5–1 วัน/task) เห็นความคืบหน้าถี่ ทดสอบทีละชิ้น **(Recommended)**
- 2) หยาบ (~2–3 วัน/task)
- 3) Other: _______

**Answer**: 1 (ละเอียด ~0.5–1 วัน/task)

---

### D4-4: โหมดการลงมือ (Execution Mode)
**Question**: จะ implement แบบไหน (ใช้ตอน Phase 6)?
- 1) Standard (ตามลำดับทีละ task) — เหมาะทีมเล็ก, ทดสอบทีละส่วน, debug ง่าย **(Recommended)**
- 2) Parallel (waves) — เร็วกว่าแต่ review/ทดสอบทีละ wave
- 3) Other: _______

**Answer**: 1 (Standard ตามลำดับ)

---

### D4-5: ขอบเขตการทดสอบ (Testing Strategy)
**Question**: จะทดสอบแค่ไหนก่อน publish?
- 1) UAT checklist ต่อ invariant (INV-1~6) + smoke test end-to-end (เปิดเคส→ack→เปลี่ยนสถานะ→เตือน SLA) ก่อนสลับ prod **(Recommended)**
- 2) เฉพาะ smoke test end-to-end
- 3) Other: _______

**Answer**: 1 (UAT checklist ต่อ INV + smoke test end-to-end)

---

### D4-6: วิธี Migrate ข้อมูลเดิม
**Question**: จะย้ายข้อมูลจาก 2 lists เดิม → `Cases` อย่างไร?
- 1) เขียน one-time migration flow (SharePoint→SharePoint) map `CaseType`/`Username` **(Recommended)**
- 2) Export/Import ผ่าน Excel (manual)
- 3) ไม่ migrate ข้อมูลเก่า (เก็บไว้อ้างอิง)
- 4) Other: _______

**Answer**: 1 (one-time migration flow)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D4-1 Breakdown: ตาม dependency — lists → config → flows → email templates → error handling → migration/cutover
- D4-2 Verification Timing: Test-after (UAT checklist / Test pane / run history)
- D4-3 Granularity: ละเอียด ~0.5–1 วัน/task
- D4-4 Execution Mode: Standard (ตามลำดับทีละ task)
- D4-5 Testing Strategy: UAT checklist ต่อ INV-1~6 + smoke test end-to-end ก่อนสลับ prod
- D4-6 Migration Method: one-time migration flow (SharePoint→SharePoint) map CaseType/Username

---

**Instructions**: Fill in your answers above and respond with "tasks decisions complete" (หรือ "done" / "use recommendations")


---

## Validation Notes
**Conflicts Detected**: 2 | **Resolved/Acknowledged**: 2
### Acknowledged: No automated test framework (🟡 High) → platform-inherent (low-code); mitigation = UAT invariants checklist (INV-1~6) + smoke test end-to-end + parallel-run ใน UAT + ErrorLog monitoring
### Acknowledged: Manual deployment (🟢 Medium) → documented runbook `deploy-helpme-agent.ps1` (pac push/publish), UAT→PROD
