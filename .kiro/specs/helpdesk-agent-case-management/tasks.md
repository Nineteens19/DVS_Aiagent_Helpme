# Implementation Tasks — unit: case-management

## Overview
Tasks จัดตามลำดับบทสนทนา: consolidate topic → เก็บ/จำแนกข้อมูล → สรุป → เรียก flow → ยืนยัน CaseID

**Derived From**:
- Requirements: US-005, US-006, US-007, US-008, US-009
- Design: `OpenCase`/`Escalate` topics + CaseType inference + summary → เรียก `CreateCaseAndAck` (foundation)

**Strategy**: Conversation-flow ordered — Standard, Test-after
**Depends on unit**: `foundation` (flow `CreateCaseAndAck`, list `Cases`, templates) — ต้อง implement foundation ก่อน (หรือคู่ขนานใน UAT) จึงจะทดสอบ end-to-end ได้

---

- [ ] 1. Topic Consolidation & Structure
  - [ ] 1.1 Redesign `OpenCase` เป็น reusable topic
    - **Deps**: None | **Ref**: `design.md` — Topic: OpenCase
    - รวม logic เดิม, จัดโครงคำถาม, trigger queries (เปิดเคส/แจ้งปัญหา/ติดต่อเจ้าหน้าที่)
  - [ ] 1.2 `Escalate` delegate → `OpenCase` + คง `Fallback` ชี้ `OpenCase`
    - **Deps**: 1.1 | **Ref**: `design.md` — Escalate (delegator)
    - ลบ logic ซ้ำใน `Escalate`; `Fallback (>3)` → `BeginDialog OpenCase`

- [ ] 2. Data Collection & Classification
  - [ ] 2.1 CaseType inference จาก `Action_Type`
    - **Deps**: 1.1 | **Ref**: `design.md` — CaseType inference (US-009)
    - map Action_Type→CaseType; ถ้าไม่ชัด → ถามยืนยันจากตัวเลือก
  - [ ] 2.2 Dynamic required-info + fixed fields
    - **Deps**: 1.1 | **Ref**: `design.md` — Required Info (US-005, US-006)
    - ถามตาม `Required_Information` ของ KB ที่ match + fixed (name/tel/system/priority); ไม่ถามซ้ำสิ่งที่มี
  - [ ] 2.3 Access-case: ถาม `Username` (ไม่ถาม password)
    - **Deps**: 2.1 | **Ref**: `design.md` — Data Model (US-009, INV-CM4)
    - เมื่อ CaseType=Access → ขอ Username; guardrail ห้าม password/OTP
  - [ ] 2.4 รับ screenshot/error เป็น text/ลิงก์
    - **Deps**: 1.1 | **Ref**: `design.md` — Attachments (US-006 AC3)
    - เก็บเป็นข้อความ/ลิงก์ + แนะให้แนบเพิ่มทางอีเมลตอบกลับเคส
  - [ ] 2.5 Cancel handling
    - **Deps**: 1.1 | **Ref**: `design.md` — INV-CM3 (US-005 AC3)
    - ยกเลิกกลางคัน → จบโดยไม่เรียก flow / ไม่สร้างเคส

- [ ] 3. Summary & Flow Invocation
  - [ ] 3.1 สร้าง `IssueSummary` + เก็บ `ProblemDetail` ดิบ
    - **Deps**: 2.2 | **Ref**: `design.md` — IssueSummary (US-006)
  - [ ] 3.2 สร้าง `ConversationSummary` ย่อ + KB_ID ที่ลองแล้ว
    - **Deps**: 2.2 | **Ref**: `design.md` — ConversationSummary (US-006)
  - [ ] 3.3 เรียก `CreateCaseAndAck` (named input contract)
    - **Deps**: 2.1, 2.2, 3.1, 3.2 (+ foundation flow) | **Ref**: `design.md` — Flow Specification (US-007, US-008)
    - map ตัวแปร topic → input contract; ส่ง systemName/caseType/priority/severity/kbRef/username
  - [ ] 3.4 แสดง `CaseID` ยืนยัน + จัดการ error จาก flow
    - **Deps**: 3.3 | **Ref**: `design.md` — INV-CM5 (US-008, US-010)
    - flow สำเร็จ → แสดง CaseID; error → แจ้งจะมีเจ้าหน้าที่ตรวจสอบ (ไม่จบเงียบ)

- [ ] 4. Test & Deploy (UAT)
  - [ ] 4.1 UAT checklist INV-CM1~5
    - **Deps**: 3.4 | **Ref**: `design.md` — Correctness Properties
  - [ ] 4.2 Smoke test end-to-end + deploy UAT
    - **Deps**: 3.4 (+ foundation implemented) | **Ref**: `foundation.md` — deployment
    - แชทเปิดเคสจริง → ได้ CaseID → เห็น item ใน `Cases` + ผู้แจ้งได้ ack; publish ผ่าน pac

---

## Task Summary

| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | Redesign OpenCase (reusable) | None | [ ] |
| 1.2 | Escalate delegate + Fallback | 1.1 | [ ] |
| 2.1 | CaseType inference | 1.1 | [ ] |
| 2.2 | Dynamic required-info | 1.1 | [ ] |
| 2.3 | Access-case Username | 2.1 | [ ] |
| 2.4 | Screenshot/error capture | 1.1 | [ ] |
| 2.5 | Cancel handling | 1.1 | [ ] |
| 3.1 | IssueSummary | 2.2 | [ ] |
| 3.2 | ConversationSummary | 2.2 | [ ] |
| 3.3 | เรียก CreateCaseAndAck | 2.1,2.2,3.1,3.2 | [ ] |
| 3.4 | แสดง CaseID + error handling | 3.3 | [ ] |
| 4.1 | UAT checklist INV-CM | 3.4 | [ ] |
| 4.2 | Smoke test + deploy | 3.4 | [ ] |

---

## Requirements Coverage
| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-005 เปิดเคส | 1.1, 2.2, 2.5 | [ ] |
| US-006 บันทึกบริบท | 2.2, 2.4, 3.1, 3.2 | [ ] |
| US-007 routing | 3.3 (ผ่าน flow) | [ ] |
| US-008 CaseID+แจ้งทีม | 3.3, 3.4 | [ ] |
| US-009 CaseType | 2.1, 2.3 | [ ] |

---

## Design Coverage
**Components**: OpenCase → 1.1, 2.x, 3.x; Escalate → 1.2; classification → 2.1
**Entities**: Cases (foundation) → ป้อนผ่าน 3.3
**Flow**: CreateCaseAndAck → 3.3, 3.4

---

## Definition of Done
- [ ] `OpenCase` reusable + `Escalate`/`Fallback` delegate ถูกต้อง
- [ ] CaseType set ทุกเคส; ข้อมูลจำเป็นครบก่อนเรียก flow
- [ ] ผ่าน INV-CM1~5
- [ ] smoke end-to-end ใน UAT: แชท → CaseID → item + ack
- [ ] publish ผ่าน pac

---

## Execution Waves
(Standard/ตามลำดับ; ตารางแสดง dependency)

| Wave | Tasks | Dependencies Resolved | Parallel |
|------|-------|-----------------------|----------|
| 1 | 1.1 | None | No |
| 2 | 1.2, 2.1, 2.2, 2.4, 2.5 | Wave 1 | Yes |
| 3 | 2.3, 3.1, 3.2 | Wave 2 | Yes |
| 4 | 3.3 | Wave 3 (+foundation) | No |
| 5 | 3.4 | Wave 4 | No |
| 6 | 4.1, 4.2 | Wave 5 | Yes |

### File / Artifact Ownership Per Wave (parallel waves)
**Wave 2/3**: ทั้งหมดอยู่ใน `topics/OpenCase.mcs.yml` (branch คนละส่วน) + `topics/Escalate.mcs.yml` (1.2) — โหมด Standard ทำตามลำดับปลอดภัยกว่าเพราะแก้ไฟล์เดียวกัน

---

## Notes
**Cross-unit dependency**: 4.2 ต้องมี foundation (`CreateCaseAndAck`, `Cases`) พร้อมใน UAT
**Deferred**: การแจ้ง ack ทางอีเมล/สถานะ อยู่ใน `notification-followup` (unit นี้แค่ trigger ผ่าน flow ของ foundation)
