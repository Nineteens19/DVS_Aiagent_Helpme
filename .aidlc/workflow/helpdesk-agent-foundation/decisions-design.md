# D3 Design Decisions — unit: foundation

## Context Summary
- **Unit**: `foundation` (infrastructure, 0 stories) — schema/contracts/conventions กลาง
- **Settled by foundation.md (ไม่ถามซ้ำ)**: SharePoint lists, auth (Integrated/Entra), error format (ErrorLog), inter-unit comms (SharePoint triggers), DB (SharePoint), deployment (pac UAT→PROD), email template กลาง, config-as-data, CaseID pattern `HD-{yyyyMMdd}-{ID}`
- **D3 นี้โฟกัส**: การตัดสินใจระดับ implementation ที่ยังเปิดอยู่

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### D3-1: วิธีสร้างเลขรัน CaseID
**Question**: จะ generate `{ID}` ใน `HD-{yyyyMMdd}-{ID}` อย่างไร?
- 1) ใช้ SharePoint item `ID` ต่อท้าย — ง่าย ไม่ต้องมี counter, ไม่มีปัญหา concurrency **(Recommended)**
- 2) counter list แยก (running number ต่อวัน) — เลขเรียงสวยแต่ซับซ้อน/ต้องกัน race condition
- 3) GUID สั้น (สุ่ม)
- 4) Other: _______

**Answer**: 1 (ใช้ SharePoint item ID)

---

### D3-2: กลยุทธ์ Migration (2 lists เดิม → `Cases`)
**Question**: จะย้ายข้อมูลเคสเดิมอย่างไร?
- 1) Parallel-run — สร้าง `Cases` ใหม่, flow ใหม่เขียน `Cases`, migrate ข้อมูลเก่าด้วย flow/script, เก็บ list เก่า read-only จนมั่นใจ **(Recommended)**
- 2) Big-bang — ย้ายทั้งหมดครั้งเดียวแล้วเลิกใช้ของเก่า
- 3) ไม่ migrate — เริ่มนับใหม่ใน `Cases` (เก็บของเก่าไว้อ้างอิง)
- 4) Other: _______

**Answer**: 1 (Parallel-run + migrate + เก็บเก่า read-only)

---

### D3-3: ตัวตนผู้ส่งอีเมล (Email Sender)
**Question**: อีเมล (ack/notify/reminder) ส่งจากบัญชีใด?
- 1) Service/Shared mailbox เฉพาะ Helpdesk (ผ่าน Office 365 connection ที่กำหนด) — สม่ำเสมอ เป็นทางการ **(Recommended)**
- 2) ส่งในนามบัญชีเจ้าของ connection ปัจจุบัน (แบบเดิม)
- 3) Other: _______

**Answer**: 1 (Service/Shared mailbox)

---

### D3-4: ตารางเวลา RemindStaleCases (SLA reminder)
**Question**: flow เตือนเคสค้างควรรันบ่อยแค่ไหน?
- 1) ทุกวันทำการ ช่วงเช้า (เช่น 09:00) ตรวจเคสที่เกิน SLA **(Recommended)**
- 2) ทุกชั่วโมง
- 3) ทุก 4 ชั่วโมงในเวลาทำการ
- 4) Other: _______

**Answer**: 1 (ทุกวันทำการ 09:00)

---

### D3-5: การ Cutover จาก flow เดิม (`NewcaseHelpDesk`)
**Question**: จะสลับจาก flow เดิมไป flow ใหม่อย่างไร?
- 1) รัน flow ใหม่คู่ขนานใน UAT จนผ่านทดสอบ แล้วค่อยสลับ production (คง flow เดิมไว้จนมั่นใจ) **(Recommended)**
- 2) แทนที่ทันที
- 3) Other: _______

**Answer**: 1 (Parallel ใน UAT แล้วค่อยสลับ)

---

### D3-6: แนวทางการทดสอบ (Low-code Testing)
**Question**: จะทดสอบ/ตรวจรับอย่างไร (ไม่มี unit test framework บนแพลตฟอร์มนี้)?
- 1) Manual UAT test script (checklist ต่อ story) + Copilot Studio Test pane + ตรวจ flow ด้วย run history **(Recommended)**
- 2) ทดสอบ ad-hoc เท่านั้น
- 3) Other: _______

**Answer**: 1 (UAT script + Test pane + run history)

---

### D3-7: Correctness & Property-Based Testing (บังคับถาม)
**Question**: จะยืนยันความถูกต้องเชิงคุณสมบัติ (invariants) อย่างไร?
- 1) ไม่ใช้ PBT (ไม่เหมาะกับ low-code) — ใช้ **invariants checklist** เป็น scenario tests เช่น "ทุกเคสมี CaseID + owner", "ไม่มีการเก็บ Password/OTP", "ทุกเคสที่เปิดต้องส่ง ack", "ตอบเฉพาะ KB ที่ Active" **(Recommended)**
- 2) ใช้ PBT — เขียน harness ภายนอกจำลอง logic การ route/สร้าง CaseID
- 3) Other: _______

**Answer**: 1 (invariants checklist เป็น scenario tests)

---

### D3-8: เป้าหมาย NFR (Performance / Availability / Monitoring)
**Question**: ตั้งเป้าหมายเชิงคุณภาพเท่าไร?
- 1) ack ≤ 1 นาที, ตอบคำถามทั่วไป ≤ ~5 วินาที, availability อิง Microsoft 365 SLA, monitoring = ErrorLog + Power Automate run history **(Recommended)**
- 2) กำหนดเข้มกว่านี้ (ระบุ)
- 3) Other: _______

**Answer**: 1 (ack ≤ 1 นาที, ตอบ ≤ ~5 วินาที, M365 SLA, ErrorLog+run history)

---

### D3-9: Repository & Branch Strategy
**Question**: จะจัดการซอร์ส MCS export อย่างไร?
- 1) repo เดียว, branch แบบ main + feature branch, deploy ผ่าน `pac` (UAT→PROD) ตามสคริปต์เดิม **(Recommended)**
- 2) ไม่มี version control (แก้ตรงใน Studio)
- 3) Other: _______

**Answer**: 1 (repo เดียว, main + feature branch, deploy ผ่าน pac)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D3-1 CaseID Impl: ใช้ SharePoint item `ID` → `HD-{yyyyMMdd}-{ID}`
- D3-2 Migration: Parallel-run — flow ใหม่เขียน `Cases`, migrate ข้อมูลเก่า, เก็บ list เก่า read-only
- D3-3 Email Sender: Service/Shared mailbox เฉพาะ Helpdesk
- D3-4 Reminder Schedule: RemindStaleCases รันทุกวันทำการ 09:00
- D3-5 Cutover: รัน flow ใหม่คู่ขนานใน UAT แล้วค่อยสลับ production
- D3-6 Testing: Manual UAT test script + Copilot Studio Test pane + Power Automate run history
- D3-7 Correctness/PBT: ไม่ใช้ PBT — invariants checklist เป็น scenario tests
- D3-8 NFR: ack ≤ 1 นาที, ตอบ ≤ ~5 วินาที, availability = M365 SLA, monitoring = ErrorLog + run history
- D3-9 Repo/Branch: repo เดียว, main + feature branch, deploy ผ่าน pac (UAT→PROD)

---

**Instructions**: Fill in your answers above and respond with "design decisions complete" (หรือ "done" / "use recommendations")
