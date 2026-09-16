# D3 Design Decisions — unit: case-management

## Context Summary
- **Unit**: `case-management` — US-005, US-006, US-007, US-008, US-009 (เปิดเคส, บันทึกบริบท, routing, CaseID+แจ้งทีม, แยกประเภท)
- **Settled by foundation (ไม่ถามซ้ำ)**: `Cases` schema, `CreateCaseAndAck` flow + input contract, routing logic, CaseID, error handling, email templates
- **D3 นี้โฟกัส**: พฤติกรรมฝั่ง agent/topic (การเก็บข้อมูล, การจำแนกประเภท, การสรุปบริบท) ที่จะ map เข้า flow ของ foundation

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### D3-1: การรวม topic OpenCase / Escalate
**Question**: ปัจจุบันมี 2 topics ที่เนื้อหาเกือบเหมือนกัน จะจัดการอย่างไร?
- 1) รวมเป็น topic เดียว `OpenCase` (reusable) แล้วให้ `Escalate` เรียกใช้ **(Recommended)** — ลดความซ้ำซ้อน
- 2) คงแยก 2 topics (แก้ให้ตรงกันด้วยมือ)
- 3) Other: _______

**Answer**: 1 (รวมเป็น OpenCase reusable, Escalate เรียกใช้)

---

### D3-2: การจำแนกประเภทเคส (CaseType) — US-009
**Question**: จะกำหนด `CaseType` (Incident/Service Request/Business Support/Access) อย่างไร?
- 1) agent อนุมานจาก `Action_Type` ของรายการ KB ที่ match + ยืนยันกับผู้ใช้เมื่อไม่ชัด **(Recommended)**
- 2) ถามผู้ใช้เลือกเองทุกครั้ง
- 3) อนุมานล้วนโดยไม่ถาม
- 4) Other: _______

**Answer**: 1 (อนุมานจาก Action_Type + ยืนยันเมื่อไม่ชัด)

---

### D3-3: การสร้างสรุปปัญหา (IssueSummary) — US-006
**Question**: จะสร้าง `IssueSummary` ที่บันทึกลงเคสอย่างไร?
- 1) agent สรุปสั้นจากบทสนทนา + แนบรายละเอียดดิบ (ProblemDetail) **(Recommended)**
- 2) ใช้ข้อความดิบที่ผู้ใช้พิมพ์อย่างเดียว
- 3) Other: _______

**Answer**: 1 (agent สรุป + แนบดิบ)

---

### D3-4: ขอบเขต ConversationSummary
**Question**: จะเก็บประวัติสนทนาลงเคสแค่ไหน?
- 1) สรุปย่อ (ประเด็นหลัก + KB_ID ที่ลองแล้ว + ข้อมูลที่รวบรวม) **(Recommended)**
- 2) เก็บ transcript เต็ม
- 3) ไม่เก็บ
- 4) Other: _______

**Answer**: 1 (สรุปย่อ + KB_ID ที่ลองแล้ว)

---

### D3-5: การเก็บข้อมูลที่จำเป็น (Required Info) — US-006
**Question**: จะถามข้อมูลก่อนเปิดเคสอย่างไร?
- 1) Dynamic ตาม `Required_Information` ของ KB ที่ match + fixed fields (ชื่อ/เบอร์/System/priority) **(Recommended)**
- 2) ถาม fixed set เท่านั้น (แบบเดิม)
- 3) Other: _______

**Answer**: 1 (Dynamic ตาม Required_Information + fixed fields)

---

### D3-6: การรับภาพหน้าจอ/Error (Attachments) — US-006 AC3
**Question**: จะจัดการภาพหน้าจอ/ข้อความ error อย่างไร (Copilot Studio จำกัดไฟล์แนบ)?
- 1) รับเป็นข้อความ/ลิงก์ + แนะให้แนบเพิ่มทางอีเมลตอบกลับเคส (บันทึกอ้างอิงในเคส) **(Recommended)**
- 2) พยายามรองรับไฟล์แนบเต็มรูปแบบใน agent
- 3) ไม่รองรับ
- 4) Other: _______

**Answer**: 1 (รับ text/ลิงก์ + แนะแนบเพิ่มทางอีเมล)

---

### D3-7: Correctness (Invariants) — บังคับถาม
**Question**: จะยืนยันความถูกต้องเชิงพฤติกรรมอย่างไร?
- 1) Invariants checklist: "ข้อมูลจำเป็นครบก่อนเรียก flow", "CaseType ถูก set เสมอ", "ไม่ส่ง/เก็บ secret", "ยกเลิกกลางคัน = ไม่สร้างเคส" **(Recommended)**
- 2) ใช้ PBT (harness ภายนอก)
- 3) Other: _______

**Answer**: 1 (invariants checklist)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
- D3-1 Topic Consolidation: รวมเป็น `OpenCase` reusable; `Escalate` เรียกใช้
- D3-2 CaseType Classification: agent อนุมานจาก KB `Action_Type` + ยืนยันเมื่อไม่ชัด
- D3-3 IssueSummary: agent สรุปสั้นจากบทสนทนา + แนบ ProblemDetail ดิบ
- D3-4 ConversationSummary: สรุปย่อ (ประเด็นหลัก + KB_ID ที่ลองแล้ว + ข้อมูลที่รวบรวม)
- D3-5 Required Info: Dynamic ตาม `Required_Information` + fixed fields (ชื่อ/เบอร์/System/priority)
- D3-6 Attachments: รับ text/ลิงก์ + แนะแนบเพิ่มทางอีเมลตอบกลับเคส
- D3-7 Correctness: invariants checklist (ข้อมูลครบ, CaseType set, no secret, cancel = no case)

---

**Instructions**: Fill in your answers above and respond with "design decisions complete" (หรือ "done" / "use recommendations")
