# D2 Units Decisions

## Context Summary
- **Requirements**: 15 stories, 4 functional areas, 3 personas (ผู้แจ้ง / เจ้าหน้าที่-Owner / ผู้ดูแล KB)
- **Platform**: Brownfield low-code — Microsoft Copilot Studio (topics) + Power Automate (flows) + SharePoint lists + Office 365 email
- **Functional areas**: Knowledge Answering, Case Capture & Routing, Notification & Follow-up, KB Governance
- **หมายเหตุ**: "Unit" ในบริบทนี้ = หน่วยฟีเจอร์เชิงตรรกะ ที่ map ไปยัง topics/flows/SharePoint lists (ไม่ใช่ microservice)

> วิธีตอบ: เติมคำตอบในช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือพิมพ์ **"use recommendations"**

---

## Decision Questions

### D2-1: จำเป็นต้องแตกเป็น Units ไหม?
**Question**: ควรแตกระบบเป็นหน่วยย่อยหรือทำเป็นก้อนเดียว?
- 1) แตกเป็น units ตาม domain — เหมาะกับ 15 stories / 4 areas, ออกแบบ/ส่งมอบทีละส่วนได้ **(Recommended)**
- 2) ทำเป็นหน่วยเดียว (comprehensive) — ออกแบบรวมทีเดียว
- 3) Other (ระบุ): _______

**Answer**: 1 (แตกเป็น units ตาม domain)

---

### D2-2: กลยุทธ์การแตกหน่วย (Decomposition Strategy)
**Question**: จะแบ่งหน่วยด้วยหลักการใด?
- 1) Domain-driven — แบ่งตามขอบเขตธุรกิจ (answering / case / notification / kb) **(Recommended)**
- 2) Layer-based — แบ่งตามชั้นเทคนิค (topics / flows / data)
- 3) User journey-based — แบ่งตาม journey (ถาม-ตอบ / แจ้งเคส / ติดตาม)
- 4) Other (ระบุ): _______

**Answer**: 1 (Domain-driven)

---

### D2-3: ชุดหน่วยที่เสนอ (Proposed Units)
**Question**: ยืนยันชุด units และการ map stories?
- 1) **4 units** (Recommended):
  - `knowledge-answering` → US-001, US-002, US-003, US-004
  - `case-management` → US-005, US-006, US-007, US-008, US-009
  - `notification-followup` → US-010, US-011, US-012, US-013
  - `kb-governance` → US-014, US-015
- 2) **3 units** — รวม notification เข้ากับ case-management (case+notify เป็นหน่วยเดียว)
- 3) **5 units** — แยก `routing` (US-007) ออกจาก case-management เป็นหน่วยของตัวเอง
- 4) Other (ระบุ): _______

**Answer**: 1 (4 units ตามที่เสนอ)

---

### D2-4: Shared Foundation และ Data Ownership
**Question**: จะจัดการส่วนที่ใช้ร่วมกัน (SharePoint schema, connection refs, CaseID format, email templates) อย่างไร?
- 1) มี **Foundation unit** รวมของใช้ร่วม: SharePoint list schema (Case/Routing/KB/Gap), connection references, `CaseID` convention, email template, guardrail กลาง **(Recommended)**
- 2) ให้แต่ละหน่วยดูแล list/flow ของตัวเอง ไม่มี foundation กลาง
- 3) Other (ระบุ): _______

**Answer**: 1 (มี Foundation unit รวมของใช้ร่วม)

---

### D2-5: ลำดับการพัฒนา (Development Sequence)
**Question**: จะพัฒนา/ส่งมอบหน่วยตามลำดับใด (สอดคล้อง priority P1→P3)?
- 1) Foundation → `case-management` + `notification-followup` (P1 core) → `knowledge-answering` (ปรับ guardrail/disambiguation) → `kb-governance` **(Recommended)**
- 2) Foundation → `knowledge-answering` → `case-management` → `notification-followup` → `kb-governance` (ไล่ตาม flow บทสนทนา)
- 3) ทำขนานกันทุกหน่วยหลัง Foundation
- 4) Other (ระบุ): _______

**Answer**: 1 (Foundation → case + notification → answering → kb-governance)

---

### D2-6: ความสัมพันธ์/Dependency ระหว่างหน่วย
**Question**: ยืนยันความสัมพันธ์หลักระหว่างหน่วย?
- 1) `case-management` พึ่ง `knowledge-answering` (ตัดสินใจ escalate); `notification-followup` พึ่ง `case-management` (ต้องมี Case/CaseID); `kb-governance` เชื่อมกับ `knowledge-answering` (สถานะ KB) และรับ gap จาก `case-management` **(Recommended)**
- 2) ทุกหน่วยเป็นอิสระ ไม่พึ่งกัน (สื่อสารผ่าน SharePoint เท่านั้น)
- 3) Other (ระบุ): _______

**Answer**: 1 (ตามความสัมพันธ์ที่เสนอ)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D2-1 Decompose: แตกเป็น units ตาม domain (incremental-capable)
- D2-2 Strategy: Domain-driven
- D2-3 Units: 4 domain units — knowledge-answering (US-001~004), case-management (US-005~009), notification-followup (US-010~013), kb-governance (US-014~015) + Foundation unit
- D2-4 Foundation: มี Foundation unit รวม SharePoint schema (Case/Routing/KB/Gap), connection refs, CaseID convention, email templates, guardrail กลาง
- D2-5 Sequence: Foundation → case-management + notification-followup (P1) → knowledge-answering → kb-governance
- D2-6 Dependencies: case→answering, notification→case, kb-governance↔answering + รับ gap จาก case-management

---

**Instructions**: Fill in your answers above and respond with "units decisions complete" (หรือ "done" / "use recommendations")
