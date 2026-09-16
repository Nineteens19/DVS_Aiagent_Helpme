# Implementation Tasks — unit: notification-followup

## Overview
Tasks จัดตาม component: acknowledgment → NotifyStatusChange → RemindStaleCases → CaseStatus topic

**Derived From**: US-010, US-011, US-012, US-013; design `.kiro/specs/helpdesk-agent-notification-followup/design.md`
**Strategy**: Component-ordered — Standard, Test-after
**Depends on unit**: `foundation` (flow shells NotifyStatusChange/RemindStaleCases, ack ใน CreateCaseAndAck, `Cases`/`SLAConfig`, templates)

---

- [ ] 1. Acknowledgment Content
  - [ ] 1.1 กำหนดเนื้อหา ack ใน `CreateCaseAndAck`
    - **Deps**: None (ประสานกับ foundation 3.5) | **Ref**: `design.md` — Ack content (US-010, INV-NF2)
    - CaseID + สรุปเรื่อง + เวลาตอบสนองโดยประมาณ (จาก `SLAConfig.FirstResponseHours`) + วิธีติดตาม; ส่งครั้งเดียว/เคส

- [ ] 2. NotifyStatusChange
  - [ ] 2.1 Detect status change + ทุก transition
    - **Deps**: 1.1 | **Ref**: `design.md` — NotifyStatusChange (US-011)
    - trigger item modified; เทียบ `Statuscase` กับ `LastNotifiedStatus`
  - [ ] 2.2 เนื้อหาอีเมลสถานะ (+Resolved invite)
    - **Deps**: 2.1 | **Ref**: `design.md` — NotifyStatusChange (US-011)
    - ใช้ template status; แนบหมายเหตุ; ถ้า Resolved → เชิญยืนยัน/ปิด
  - [ ] 2.3 กันแจ้งซ้ำ
    - **Deps**: 2.1 | **Ref**: `design.md` — INV-NF1
    - หลังส่ง → set `LastNotifiedStatus = Statuscase`

- [ ] 3. RemindStaleCases
  - [ ] 3.1 Query เคสเกิน SLA
    - **Deps**: None (foundation shell) | **Ref**: `design.md` — RemindStaleCases (US-013)
    - recurrence 09:00 วันทำการ; filter Open/In Progress + `SlaDueDate` < now
  - [ ] 3.2 อีเมลเตือน owner + CC escalate
    - **Deps**: 3.1 | **Ref**: `design.md` — Reminder recipients (US-013, INV-NF4)
    - To `AssignedOwner` + CC `EscalateToCC`

- [ ] 4. CaseStatus Topic (self-service)
  - [ ] 4.1 Query by CaseID (filter ReporterEmail)
    - **Deps**: None | **Ref**: `design.md` — CaseStatus topic (US-012, INV-NF3)
    - พิมพ์ CaseID → แสดงสถานะ + อัปเดตล่าสุด; จำกัดเฉพาะเคสของตน
  - [ ] 4.2 "เคสของฉัน" list + not-found handling
    - **Deps**: 4.1 | **Ref**: `design.md` — CaseStatus topic (US-012)
    - แสดงรายการเคสของผู้ใช้; ไม่พบ → เสนอเปิดเคสใหม่

- [ ] 5. Test & Deploy (UAT)
  - [ ] 5.1 UAT checklist INV-NF1~4
    - **Deps**: 2.3, 3.2, 4.2 | **Ref**: `design.md` — Correctness
  - [ ] 5.2 Smoke test end-to-end + deploy
    - **Deps**: 5.1 (+ foundation) | **Ref**: `foundation.md` — deployment
    - เปลี่ยนสถานะ→อีเมลถึงผู้แจ้ง; พิมพ์ CaseID/"เคสของฉัน"→เห็นสถานะ; รัน SLA reminder; publish ผ่าน pac

---

## Task Summary
| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | Ack content | None | [ ] |
| 2.1 | Detect status change | 1.1 | [ ] |
| 2.2 | เนื้อหาอีเมลสถานะ | 2.1 | [ ] |
| 2.3 | กันแจ้งซ้ำ | 2.1 | [ ] |
| 3.1 | Query เคสเกิน SLA | None | [ ] |
| 3.2 | อีเมลเตือน owner+CC | 3.1 | [ ] |
| 4.1 | CaseStatus by CaseID | None | [ ] |
| 4.2 | "เคสของฉัน" + not-found | 4.1 | [ ] |
| 5.1 | UAT checklist INV-NF | 2.3,3.2,4.2 | [ ] |
| 5.2 | Smoke + deploy | 5.1 | [ ] |

---

## Requirements Coverage
| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-010 ack | 1.1 | [ ] |
| US-011 status notify | 2.1, 2.2, 2.3 | [ ] |
| US-012 self-service | 4.1, 4.2 | [ ] |
| US-013 SLA reminder | 3.1, 3.2 | [ ] |

---

## Design Coverage
**Components**: NotifyStatusChange → 2.x; RemindStaleCases → 3.x; CaseStatus topic → 4.x; ack → 1.1
**Entities**: Cases/SLAConfig (foundation) — read/update only

---

## Definition of Done
- [ ] ผ่าน INV-NF1~4
- [ ] smoke: status change→email; self-service→สถานะ; reminder ทำงาน
- [ ] publish ผ่าน pac

---

## Execution Waves
| Wave | Tasks | Dependencies Resolved | Parallel |
|------|-------|-----------------------|----------|
| 1 | 1.1, 3.1, 4.1 | None | Yes |
| 2 | 2.1, 3.2, 4.2 | Wave 1 | Yes |
| 3 | 2.2, 2.3 | Wave 2 | Yes |
| 4 | 5.1 | Wave 3 | No |
| 5 | 5.2 | Wave 4 | No |

### File / Artifact Ownership Per Wave
**Wave 1**: 1.1 → `CreateCaseAndAck`; 3.1 → `RemindStaleCases`; 4.1 → `topics/CaseStatus.mcs.yml`
**Wave 2**: 2.1 → `NotifyStatusChange`; 3.2 → `RemindStaleCases`; 4.2 → `topics/CaseStatus.mcs.yml`

---

## Notes
**Cross-unit**: ack content (1.1) ประสานกับ foundation task 3.5; flow shells มาจาก foundation 4.1/4.2
