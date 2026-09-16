# Implementation Tasks — unit: foundation

## Overview
Tasks จัดลำดับตาม dependency: SharePoint lists → config data → flows → email templates → error handling → migration/cutover

**Derived From**:
- Requirements: รองรับ US-005~US-015 (infra); ตรง ๆ ได้แก่ US-007, US-008, US-010, US-011, US-013
- Design: 6 SharePoint lists, 3 flows, email templates, error scope จาก `.kiro/specs/helpdesk-agent-foundation/design.md`

**Strategy**: Dependency-ordered (infra-first) — Standard execution, Test-after
**Rationale**: Foundation เป็นฐานของทุก unit; ต้องให้ schema/contracts นิ่งและทดสอบได้ก่อน

---

- [ ] 1. SharePoint Lists & Config
  - [ ] 1.1 สร้าง list `Cases` (consolidated)
    - **Deps**: None | **Ref**: `design.md` — Data Model / Cases
    - สร้างคอลัมน์ทั้งหมด (CaseID, CaseType, SystemName, Category, Priority, Severity, ProblemDetail, IssueSummary, ConversationSummary, KBRef, Username, ReporterName, ReporterEmail, ReporterTel, Statuscase, AssignedOwner, SlaDueDate, LastNotifiedStatus, ResolvedAt) พร้อม choice values
    - ตั้ง default `Statuscase = Open`; ทำ index: CaseID, Statuscase+SlaDueDate, ReporterEmail
  - [ ] 1.2 สร้าง lists `SLAConfig`, `KnowledgeGaps`, `ErrorLog`
    - **Deps**: None | **Ref**: `design.md` — Data Model
    - ตามสคีมาในเอกสารออกแบบ (choice/number/datetime ตามที่ระบุ)
  - [ ] 1.3 ปรับ `Routing` + เติม config data
    - **Deps**: 1.2 | **Ref**: `design.md` — Routing / SLAConfig
    - เพิ่มคอลัมน์ `OwnerTeam`; เติม routing rows ตามระบบ (+ row `Helpdesk` เป็น fallback); เติม `SLAConfig` P1/P2/P3 (FirstResponseHours/ResolutionHours/EscalateToCC)

- [ ] 2. Connections & Email Templates
  - [ ] 2.1 ยืนยัน/สร้าง connection references
    - **Deps**: None | **Ref**: `design.md` — Integration Points
    - SharePoint online + Office 365 (shared/service mailbox สำหรับส่งอีเมล ตาม D3-3)
  - [ ] 2.2 สร้าง email templates กลาง (ack / status / reminder / error)
    - **Deps**: None | **Ref**: `foundation.md` — Email template; `design.md`
    - HTML + placeholder (CaseID, System, IssueSummary, Status, Reporter) ภาษาไทย

- [ ] 3. Flow: CreateCaseAndAck (rebuild จาก NewcaseHelpDesk)
  - [ ] 3.1 Skeleton + named input contract
    - **Deps**: 1.1, 2.1 | **Ref**: `design.md` — Flow Specification
    - trigger skills `Request` รับ input แบบตั้งชื่อ (actionType, contactEmail, contactName, contactTel, systemName, caseType, priority, severity, issueDetail, issueSummary, kbRef, username?)
  - [ ] 3.2 สร้าง Cases item + CaseID + Open
    - **Deps**: 3.1 | **Ref**: `design.md` — Cases / CaseID
    - create item → set `CaseID = HD-{yyyyMMdd}-{ID}` (item ID) → `Statuscase = Open`
  - [ ] 3.3 Routing resolve (To/CC, fallback Helpdesk)
    - **Deps**: 3.2, 1.3 | **Ref**: `design.md` — Routing; แทน nested For_each เดิมด้วย filter query ตรง
    - query `Routing` by `SystemName`; ถ้าไม่พบ → ใช้ row `Helpdesk`; set To/CC จาก ToNotifyBA/ToNotifySA/CCNotify; set `AssignedOwner`
  - [ ] 3.4 คำนวณ `SlaDueDate`
    - **Deps**: 3.2, 1.3 | **Ref**: `design.md` — SLAConfig
    - lookup `SLAConfig` by Severity → SlaDueDate = created + ResolutionHours (นับเวลาทำการอย่างง่าย)
  - [ ] 3.5 ส่งอีเมล: ทีม + acknowledgment ผู้แจ้ง
    - **Deps**: 3.3, 2.2 | **Ref**: `design.md` — INV-3 (US-008, US-010)
    - team email (To/CC) + reporter ack (CaseID + สรุป) จาก template; คืน `{caseId, status}` ให้ agent
  - [ ] 3.6 เขียน `KnowledgeGaps` (เส้นทางตอบไม่ได้)
    - **Deps**: 3.2, 1.2 | **Ref**: `design.md` — Event: KnowledgeGapDetected (US-014)
    - ถ้าเปิดเคสเพราะตอบไม่ได้ → เขียน gap (UserQuestion, SystemGuess, RelatedCaseID)
  - [ ] 3.7 Error handling scope → ErrorLog + แจ้ง admin
    - **Deps**: 3.2, 1.2, 2.2 | **Ref**: `design.md` — Error Handling (INV-5)
    - Scope + run-after Failed → เขียน `ErrorLog` (CASE_001/ROUTE_001/EMAIL_001) + email admin; ไม่จบเงียบ

- [ ] 4. Notification & SLA Flows
  - [ ] 4.1 Flow `NotifyStatusChange`
    - **Deps**: 1.1, 2.2 | **Ref**: `design.md` — NotifyStatusChange (US-011)
    - trigger "When item modified" (Cases); ถ้า `Statuscase` ≠ `LastNotifiedStatus` → email ผู้แจ้ง (template) → update `LastNotifiedStatus`; error handling
  - [ ] 4.2 Flow `RemindStaleCases`
    - **Deps**: 1.1, 1.3, 2.2 | **Ref**: `design.md` — RemindStaleCases (US-013)
    - Recurrence ทุกวันทำการ 09:00; query Cases (Open/In Progress + `SlaDueDate` < now) → email owner/CC (+ EscalateToCC); error handling

- [ ] 5. Migration, Test & Cutover
  - [ ] 5.1 Migration flow: legacy Incident → `Cases`
    - **Deps**: 1.1 | **Ref**: `design.md` — Migration Steps
    - one-time flow map ฟิลด์เดิม → Cases, `CaseType = Incident`
  - [ ] 5.2 Migration flow: legacy Password/UserSystem → `Cases`
    - **Deps**: 1.1 | **Ref**: `design.md` — Migration Steps
    - map + `CaseType = Access`, เก็บ `Username`
  - [ ] 5.3 UAT: invariants checklist + smoke test end-to-end
    - **Deps**: 3.5, 3.7, 4.1, 4.2, 5.1, 5.2 | **Ref**: `design.md` — Correctness (INV-1~6)
    - ตรวจ INV-1~6; smoke: เปิดเคส→ack→เปลี่ยนสถานะ→แจ้ง→เตือน SLA; ทดสอบใน UAT (`cr616_helpMeAgentUat`)
  - [ ] 5.4 Guardrail baseline ใน `agent.mcs.yml`
    - **Deps**: 3.5 | **Ref**: `foundation.md` — Guardrail baseline
    - instruction กลาง: แสดง CaseID/ack, ตอบเฉพาะ Approved_Answer, แสดง KB_ID, ห้ามเก็บ secret
  - [ ] 5.5 Cutover (data/flows/publish เท่านั้น)
    - **Deps**: 5.3, 5.4 | **Ref**: `design.md` — Migration/Cutover; `deploy-helpme-agent.ps1`; architecture-review MAJOR-1
    - ตั้ง flow/lists เดิม read-only, publish flows/lists ผ่าน pac (UAT→PROD)
    - **หมายเหตุ**: การชี้ topic `OpenCase`/`Escalate` ไป `CreateCaseAndAck` เป็นของ unit `case-management` (task 3.3) — foundation ไม่แตะ topic

---

## Task Summary

| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | สร้าง `Cases` | None | [ ] |
| 1.2 | สร้าง `SLAConfig`/`KnowledgeGaps`/`ErrorLog` | None | [ ] |
| 1.3 | ปรับ `Routing` + config data | 1.2 | [ ] |
| 2.1 | Connection references | None | [ ] |
| 2.2 | Email templates กลาง | None | [ ] |
| 3.1 | CreateCaseAndAck skeleton + input | 1.1, 2.1 | [ ] |
| 3.2 | Create Cases + CaseID + Open | 3.1 | [ ] |
| 3.3 | Routing resolve | 3.2, 1.3 | [ ] |
| 3.4 | คำนวณ SlaDueDate | 3.2, 1.3 | [ ] |
| 3.5 | อีเมลทีม + ack | 3.3, 2.2 | [ ] |
| 3.6 | เขียน KnowledgeGaps | 3.2, 1.2 | [ ] |
| 3.7 | Error handling + ErrorLog | 3.2, 1.2, 2.2 | [ ] |
| 4.1 | NotifyStatusChange | 1.1, 2.2 | [ ] |
| 4.2 | RemindStaleCases | 1.1, 1.3, 2.2 | [ ] |
| 5.1 | Migration Incident → Cases | 1.1 | [ ] |
| 5.2 | Migration Access → Cases | 1.1 | [ ] |
| 5.3 | UAT checklist + smoke test | 3.5,3.7,4.1,4.2,5.1,5.2 | [ ] |
| 5.4 | Guardrail baseline | 3.5 | [ ] |
| 5.5 | Cutover + publish | 5.3, 5.4 | [ ] |

---

## Requirements Coverage

| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-007 Routing | 1.3, 3.3 | [ ] |
| US-008 CaseID + แจ้งทีม | 3.2, 3.5, 3.7 | [ ] |
| US-010 Acknowledgment | 2.2, 3.5 | [ ] |
| US-011 แจ้งเปลี่ยนสถานะ | 4.1 | [ ] |
| US-013 SLA reminder | 1.3, 4.2 | [ ] |
| US-014 Gap (infra) | 1.2, 3.6 | [ ] |
| US-006/009 Case context/type (schema) | 1.1 | [ ] |
| US-004 Guardrail baseline | 5.4 | [ ] |

> หมายเหตุ: US-001~006, US-009, US-012, US-015 รายละเอียดพฤติกรรมจะทำเต็มใน unit ที่เกี่ยวข้อง (foundation เตรียม schema/contract/flow ให้แล้ว)

---

## Design Coverage
**Components**: 3 flows → 3.x, 4.1, 4.2; email templates → 2.2; error scope → 3.7
**Entities**: 6 lists → 1.1, 1.2, 1.3 (+ KnowledgeBase เดิม)
**Contracts**: input contract → 3.1; events (CaseCreated/StatusChanged/GapDetected) → 3.5, 4.1, 3.6
**Migration**: → 5.1, 5.2, 5.5

---

## Definition of Done
- [ ] สร้าง lists/flows ตามสคีมา/สเปก
- [ ] ผ่าน invariants checklist (INV-1~6)
- [ ] smoke test end-to-end ใน UAT ผ่าน
- [ ] Error handling ทำงาน (ทดสอบ fail path → ErrorLog + admin)
- [ ] Migration verify จำนวน/ความถูกต้องข้อมูล
- [ ] publish ผ่าน pac (UAT→PROD) + เอกสาร runbook

---

## Execution Waves
(โหมดที่เลือก = Standard/ตามลำดับ; ตารางนี้ให้ภาพ dependency และกรณีอยากทำขนานบางช่วง)

| Wave | Tasks | Dependencies Resolved | Parallel |
|------|-------|-----------------------|----------|
| 1 | 1.1, 1.2, 2.1, 2.2 | None | Yes |
| 2 | 1.3, 3.1 | Wave 1 | Yes |
| 3 | 3.2, 5.1, 5.2 | Wave 2 (1.1) | Yes |
| 4 | 3.3, 3.4, 3.6, 4.1, 4.2 | Wave 3 | Yes |
| 5 | 3.5, 3.7 | Wave 4 | Yes |
| 6 | 5.4 | Wave 5 (3.5) | No |
| 7 | 5.3 | Waves 3–6 | No |
| 8 | 5.5 | Wave 7 (+5.4) | No |

### File / Artifact Ownership Per Wave (parallel waves)
**Wave 1**:
- 1.1: list `Cases`
- 1.2: lists `SLAConfig`, `KnowledgeGaps`, `ErrorLog`
- 2.1: `connectionreferences.mcs.yml`
- 2.2: email templates asset

**Wave 2**:
- 1.3: list `Routing` + config rows
- 3.1: flow `CreateCaseAndAck` (skeleton)

**Wave 3**:
- 3.2: flow `CreateCaseAndAck` (create step)
- 5.1: flow `MigrateIncident`
- 5.2: flow `MigrateAccess`

**Wave 4** (ทั้งหมดอยู่คนละ flow/สาขา):
- 3.3, 3.4, 3.6: `CreateCaseAndAck` (คนละ branch — ต้อง merge อย่างระวังถ้าทำขนาน; standard mode ทำตามลำดับ)
- 4.1: flow `NotifyStatusChange`
- 4.2: flow `RemindStaleCases`

**Wave 5**:
- 3.5, 3.7: `CreateCaseAndAck` (email + error scope)

> หมายเหตุ: task ภายใน `CreateCaseAndAck` (3.3–3.7) แก้ flow เดียวกัน — ในโหมด Standard ทำตามลำดับปลอดภัยกว่า; ถ้าจะทำขนานให้จัด 3.x ไว้คนละ wave

---

## Notes
**Technical Debt**: flow เดิม `NewcaseHelpDesk` (nested For_each) จะถูกแทนที่; เก็บไว้ read-only ช่วง transition
**Future Enhancements**: full redesign ของ topic `OpenCase`/`Escalate` (IssueSummary/ConversationSummary/CaseType prompts) อยู่ใน unit `case-management`; self-service `CaseStatus` topic อยู่ใน `notification-followup`
