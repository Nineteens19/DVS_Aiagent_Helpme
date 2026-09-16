# Design: notification-followup (helpdesk-agent)

## Summary
- **Architecture**: SharePoint triggers/recurrence + Power Automate → อีเมล; + topic `CaseStatus` (agent-side query)
- **Stack**: Power Automate flows (foundation shells) + MCS topic; ใช้ `Cases`/`SLAConfig`/templates จาก foundation
- **Components**: ack content spec, `NotifyStatusChange` (logic/content), `RemindStaleCases` (SLA logic), `CaseStatus` topic
- **Entities**: ใช้ `Cases`, `SLAConfig` (foundation); ไม่มี list ใหม่
- **Endpoints**: SharePoint triggers (item modified / recurrence) + topic query

> อ้างอิง foundation: `.kiro/specs/helpdesk-agent/foundation.md`, `.kiro/specs/helpdesk-agent-foundation/design.md`

## Architecture
```
[CreateCaseAndAck] --(ack template: CaseID+summary+ETA+track)--> Email ผู้แจ้ง            (US-010)
[Cases item modified] --> NotifyStatusChange:                                              (US-011)
      ถ้า Statuscase != LastNotifiedStatus (ทุก transition) --> Email ผู้แจ้ง --> update LastNotifiedStatus
[Recurrence 09:00 วันทำการ] --> RemindStaleCases:                                           (US-013)
      query Cases(open) where now > SlaDueDate --> Email AssignedOwner (+CC EscalateToCC)
[User: CaseID | "เคสของฉัน"] --> CaseStatus topic --> query Cases (filter ReporterEmail) --> แสดงสถานะ (US-012)
```

---

## Components

### Ack content (ใน CreateCaseAndAck — foundation flow)
- unit นี้กำหนด "เนื้อหา": `CaseID` + สรุปเรื่อง + เวลาตอบสนองโดยประมาณ (จาก `SLAConfig.FirstResponseHours`) + วิธีติดตาม (พิมพ์ CaseID กับ agent) — US-010
- ส่งครั้งเดียวต่อเคส (INV-NF2)

### Flow: NotifyStatusChange (logic/content)
- trigger: `Cases` item modified
- ถ้า `Statuscase` ≠ `LastNotifiedStatus` → ส่งอีเมลผู้แจ้ง (template status) พร้อมสถานะใหม่ + หมายเหตุ (ถ้ามี) → set `LastNotifiedStatus = Statuscase`
- แจ้งทุก transition; ถ้า Resolved → เพิ่มข้อความเชิญยืนยัน/ปิด (US-011)

### Flow: RemindStaleCases (SLA logic)
- trigger: recurrence ทุกวันทำการ 09:00
- query `Cases` where `Statuscase` in (Open, In Progress) and `SlaDueDate` < now
- ส่งอีเมลเตือน `AssignedOwner` (To) + CC `EscalateToCC` (US-013)
- business-hours: คำนวณ SlaDueDate แบบง่าย (นับชั่วโมงทำการโดยประมาณ)

### Topic: CaseStatus (new, agent-side)
- ผู้ใช้พิมพ์ `CaseID` → query `Cases` (filter `ReporterEmail = System.User.Email`) → แสดงสถานะ + วันเวลาอัปเดตล่าสุด
- ผู้ใช้พิมพ์ "เคสของฉัน" → แสดงรายการเคสของผู้ใช้ (สถานะ + CaseID)
- ไม่พบ/ไม่ใช่เจ้าของ → แจ้งไม่พบ + เสนอเปิดเคสใหม่ (US-012)

---

## Data Model
ใช้ (foundation): `Cases` (Statuscase, LastNotifiedStatus, SlaDueDate, ReporterEmail, AssignedOwner), `SLAConfig`, `Routing.EscalateToCC`. **ไม่มี list ใหม่**

---

## Integration Points
| External | Protocol | Purpose | Error Handling |
|----------|----------|---------|----------------|
| SharePoint (Cases) | trigger "item modified" | ตรวจจับเปลี่ยนสถานะ | error → ErrorLog (foundation) |
| SharePoint (Cases/SLAConfig) | GetItems (filter) | หาเคสเกิน SLA + query สถานะ | retry → ErrorLog |
| Office 365 | SendEmailV2 | อีเมล status/reminder | retry → ErrorLog EMAIL_001 |

---

## Implementation
### Artifacts
```
HelpMe Agent/
├── workflows/NotifyStatusChange/   (เติม logic/content จาก shell ของ foundation)
├── workflows/RemindStaleCases/     (เติม SLA logic จาก shell)
└── topics/CaseStatus.mcs.yml       (ใหม่ — self-service query)
```
### Conventions
- ใช้ email templates กลาง (foundation); correlation ด้วย `CaseID`
- Query filter ต้องมี `ReporterEmail = System.User.Email` เสมอสำหรับ self-service

---

## Non-Functional Requirements
- แจ้งเปลี่ยนสถานะภายในไม่กี่นาทีหลังแก้ (ขึ้นกับ SharePoint trigger); reminder ตรงเวลานัด
- Privacy: self-service เห็นเฉพาะเคสของตน

---

## Correctness Properties (Invariants)
| Property | Description | Validates |
|----------|-------------|-----------|
| INV-NF1 | แต่ละการเปลี่ยนสถานะแจ้งผู้แจ้งครั้งเดียว (กันซ้ำด้วย LastNotifiedStatus) | US-011 |
| INV-NF2 | ack ส่งครั้งเดียวต่อเคส | US-010 |
| INV-NF3 | self-service แสดงเฉพาะเคสของผู้ใช้ (ReporterEmail match) | US-012 |
| INV-NF4 | reminder ส่งเฉพาะเคสที่ยังไม่ปิดและเกิน SlaDueDate | US-013 |

---

## Traceability
| Requirement | Component |
|-------------|-----------|
| US-010 ack | Ack content (CreateCaseAndAck) |
| US-011 status notify | NotifyStatusChange |
| US-012 self-service | CaseStatus topic |
| US-013 SLA reminder | RemindStaleCases |
