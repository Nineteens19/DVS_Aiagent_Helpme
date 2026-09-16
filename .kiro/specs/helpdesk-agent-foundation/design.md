# Design: Foundation (helpdesk-agent)

## Summary
- **Architecture**: Copilot Studio agent → Power Automate flows → SharePoint lists + Office 365 email — infra/shared layer สำหรับทุก domain unit
- **Stack**: MCS (`.mcs.yml`) / Power Automate (`workflow.json`) / SharePoint Online / Office 365 Outlook
- **Components**: 3 flows (CreateCaseAndAck, NotifyStatusChange, RemindStaleCases) + shared email templates + error-handling scope
- **Entities (SharePoint lists)**: 6 — Cases, Routing, SLAConfig, KnowledgeBase, KnowledgeGaps, ErrorLog
- **Contracts**: flow input schema (named), event catalog, CaseID `HD-{yyyyMMdd}-{ID}`

> อ้างอิงภาพรวมที่ `.kiro/specs/helpdesk-agent/foundation.md` — เอกสารนี้คือรายละเอียดระดับ implementation ของ Foundation unit

## Architecture

**Pattern**: SharePoint = source of truth; flows แยกตามหน้าที่; eventing ผ่าน SharePoint triggers (managed)

```
[User] ──Teams/M365 Copilot──> [HelpMe Agent (Copilot Studio)]
                                    │  topics: Search / OpenCase / Escalate / Fallback / CaseStatus
                                    ▼ InvokeFlowAction (skills trigger)
                        [CreateCaseAndAck flow] ──> [SharePoint: Cases] (create + CaseID + Open)
                                    │                      │
                                    │                      ├─> read [Routing] (owner To/CC, fallback Helpdesk)
                                    │                      └─> write [KnowledgeGaps] (ถ้าตอบไม่ได้)
                                    ├─> Email team/owner (Office 365)
                                    └─> Email acknowledgment → reporter (Office 365)

[SharePoint: Cases] --item modified--> [NotifyStatusChange flow] --> Email reporter (สถานะเปลี่ยน)
[Recurrence 09:00]  ------------------> [RemindStaleCases flow] --> read [Cases]+[SLAConfig] --> Email owner (เกิน SLA)
[any flow error] ---------------------> [ErrorLog] + Email admin
```

---

## Components

### Flow: CreateCaseAndAck
- **Purpose**: สร้างเคส + สร้าง CaseID + route owner + แจ้งทีม + ส่ง acknowledgment ผู้แจ้ง (+ เขียน gap ถ้ามี)
- **Technology**: Power Automate (skills-triggered `Request`)
- **Exposes**: named input contract (ด้านล่าง); returns `CaseID`, `status` ให้ agent
- **Consumes**: `Cases`, `Routing`, `KnowledgeGaps` (SharePoint); Office 365 SendEmailV2
- **แทนที่**: `NewcaseHelpDesk` เดิม (ลบ nested For_each, ใช้ filter query ตรง)

### Flow: NotifyStatusChange
- **Purpose**: เมื่อ `Statuscase` เปลี่ยน → อีเมลแจ้งผู้แจ้ง + อัปเดต `LastNotifiedStatus`
- **Technology**: Power Automate (SharePoint "When an item is modified" on `Cases`)
- **Consumes**: `Cases`; Office 365 SendEmailV2

### Flow: RemindStaleCases
- **Purpose**: เตือน owner เมื่อเคสค้างเกิน SLA ตาม Severity
- **Technology**: Power Automate (Recurrence — ทุกวันทำการ 09:00)
- **Consumes**: `Cases` (filter open + เกิน SlaDueDate), `SLAConfig`, `Routing`; Office 365

### Shared: Email templates + Error handling
- เทมเพลต HTML กลาง (ack / status / reminder / error) พร้อม placeholder
- Error scope + เขียน `ErrorLog` + แจ้ง admin; error codes `[DOMAIN]_[NUMBER]`

---

## Data Model (SharePoint Lists)

### Cases (consolidated)
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| CaseID | Single line | unique | `HD-{yyyyMMdd}-{ID}` (ID = item ID) |
| CaseType | Choice | Incident/Service Request/Business Support/Access | ประเภทเคส |
| SystemName | Single line | required | ระบบ |
| Category | Single line | optional | จาก KB |
| Priority | Choice | ปกติ/ด่วน | ความเร่งด่วนจากผู้ใช้ |
| Severity | Choice | P1/P2/P3 | จาก KB (ใช้คำนวณ SLA) |
| ProblemDetail | Multiline | required | รายละเอียดที่ผู้ใช้แจ้ง |
| IssueSummary | Multiline | optional | สรุปโดย agent |
| ConversationSummary | Multiline | optional | ประวัติสนทนาย่อ |
| KBRef | Single line | optional | KB_ID อ้างอิง |
| Username | Single line | optional | เคส access |
| ReporterName | Single line | required | ชื่อผู้แจ้ง |
| ReporterEmail | Single line | required | = System.User.Email |
| ReporterTel | Single line | optional | เบอร์ติดต่อ |
| Statuscase | Choice | Open/In Progress/Resolved/Closed | สถานะ (default Open) |
| AssignedOwner | Single line | optional | ทีม/ผู้รับผิดชอบ |
| SlaDueDate | Date/Time | optional | คำนวณจาก Severity + SLAConfig |
| LastNotifiedStatus | Single line | optional | สถานะที่แจ้งผู้แจ้งล่าสุด |
| ResolvedAt | Date/Time | optional | เวลาปิด/แก้ไข |

**Indexes**: CaseID (unique lookup), Statuscase + SlaDueDate (สำหรับ RemindStaleCases), ReporterEmail (self-service query)

### Routing
| Field | Type | Description |
|-------|------|-------------|
| SystemName | Single line | key (fallback = "Helpdesk") |
| OwnerTeam | Single line | ชื่อทีม |
| ToNotifyBA | Single line | email |
| ToNotifySA | Single line | email |
| CCNotify | Single line | email |

### SLAConfig
| Field | Type | Description |
|-------|------|-------------|
| Severity | Choice (P1/P2/P3) | ระดับ |
| FirstResponseHours | Number | เกณฑ์ตอบสนอง |
| ResolutionHours | Number | เกณฑ์แก้ไข (ใช้คำนวณ SlaDueDate) |
| EscalateToCC | Single line | email เมื่อเกินเกณฑ์ |

### KnowledgeGaps
| Field | Type | Description |
|-------|------|-------------|
| UserQuestion | Multiline | คำถามที่ตอบไม่ได้ |
| SystemGuess | Single line | ระบบที่คาดว่าเกี่ยว |
| Frequency | Number | นับซ้ำ |
| RelatedCaseID | Single line | เคสที่เกี่ยว |
| Status | Choice | New/Reviewed/Added to KB/Rejected |

### ErrorLog
| Field | Type | Description |
|-------|------|-------------|
| Title | Single line | สรุปสั้น |
| FlowName | Single line | ชื่อ flow |
| ErrorCode | Choice | `[DOMAIN]_[NUMBER]` |
| ErrorMessage | Multiline | ข้อความ error |
| ContextData | Multiline | input (ไม่รวม secret) |
| Timestamp | Date/Time | UTC |
| Notified | Yes/No | แจ้ง admin แล้ว |

### KnowledgeBase (เดิม)
ใช้ `AI_KnowledgeBase_Helpdesk` (19 ฟิลด์) — governance keys: `Review_Status`, `Is_Active`

---

## Flow Specification (Contracts)

### CreateCaseAndAck — Input (named, แทน text_/text_1..6 เดิม)
```
{ actionType, contactEmail, contactName, contactTel, systemName,
  caseType, priority, severity, issueDetail, issueSummary, kbRef, username? }
```
- **Auth**: Skills trigger (เรียกจาก agent ที่ auth Integrated แล้ว)
- **Output**: `{ caseId, status }`
- **Errors**: CASE_001 (create fail), ROUTE_001 (owner not found → Helpdesk), EMAIL_001 (send fail)

### Event Catalog
| Event | กลไก | Publisher → Subscriber |
|-------|------|------------------------|
| CaseCreated | หลัง create ใน CreateCaseAndAck | case → notification (ack + team) |
| CaseStatusChanged | SharePoint item modified (Cases) | เจ้าหน้าที่ → NotifyStatusChange |
| KnowledgeGapDetected | เขียน KnowledgeGaps | answering/case → kb-governance |

---

## Integration Points

| External System | Protocol | Purpose | Error Handling |
|----------------|----------|---------|----------------|
| SharePoint Online | OpenApiConnection | อ่าน/เขียน lists | retry transient → ErrorLog SP_001 |
| Office 365 Outlook | SendEmailV2 | อีเมล ack/notify/reminder | retry → ErrorLog EMAIL_001; ไม่จบเงียบ |
| Copilot Studio | InvokeFlowAction (skills) | เรียก CreateCaseAndAck | คืน error ให้ agent แจ้งผู้ใช้ |

---

## Implementation

### Directory / Artifact Layout
```
HelpMe Agent/
├── workflows/
│   ├── CreateCaseAndAck/     (rebuild จาก NewcaseHelpDesk)
│   ├── NotifyStatusChange/   (ใหม่)
│   └── RemindStaleCases/     (ใหม่)
├── agent.mcs.yml             (guardrail baseline + สื่อสาร CaseID/ack)
└── connectionreferences.mcs.yml

SharePoint (PowerAppPRD): Cases, Routing, SLAConfig, KnowledgeGaps, ErrorLog (+ KnowledgeBase เดิม)
```

### Dev Setup / Deploy
```powershell
# แก้ไฟล์ local แล้ว push + publish ผ่านสคริปต์เดิม
powershell -ExecutionPolicy Bypass -File "e:\DVS\Project\Aiagent_Helpme\deploy-helpme-agent.ps1"
```

### Migration Steps (2 lists → Cases)
1. สร้าง `Cases`, `SLAConfig`, `KnowledgeGaps`, `ErrorLog` ใน UAT
2. เติม `Routing.OwnerTeam` + `SLAConfig` (P1/P2/P3)
3. สร้าง CreateCaseAndAck (เขียน `Cases`) คู่ขนานของเดิม
4. migrate ข้อมูลเก่า (Incident + UserSystem) → `Cases` (map CaseType/Username) ด้วย flow/script
5. ทดสอบ end-to-end ใน UAT → สลับ production → คงของเดิม read-only

### Conventions
- **Naming**: lists PascalCase; flows Verb-Noun; choice values อังกฤษ (แสดงผลไทย)
- **CaseID**: `HD-{yyyyMMdd}-{ID}`
- **Timestamps**: UTC (แสดง Asia/Bangkok)
- **Soft delete**: `Statuscase = Closed`

---

## Non-Functional Requirements
- **Performance**: acknowledgment ≤ 1 นาทีหลังเปิดเคส; ตอบคำถามทั่วไป ≤ ~5 วินาที (ขึ้นกับ model)
- **Security/Privacy**: auth Integrated/Entra; encryption at rest + in transit (จัดการโดย M365); ไม่เก็บ Password/OTP; เข้าถึงเคสเฉพาะเจ้าของ/เจ้าหน้าที่ (PDPA)
- **Availability**: อิง Microsoft 365 / Power Platform SLA (managed, redundant)
- **Reliability**: flow มี retry + ErrorLog + แจ้ง admin; ไม่จบการทำงานแบบเงียบ
- **Observability**: `ErrorLog` list + Power Automate run history; correlation ด้วย `CaseID`

---

## Correctness Properties (Invariants Checklist — ไม่ใช้ PBT)
| Property | Description | Validates |
|----------|-------------|-----------|
| INV-1 | ทุกเคสที่สร้างต้องมี `CaseID` และ `Statuscase = Open` | US-008 |
| INV-2 | ทุกเคสต้องมีผู้รับผิดชอบ (owner จาก Routing หรือ fallback Helpdesk) | US-007 |
| INV-3 | ทุกเคสที่เปิดสำเร็จต้องมีการส่ง acknowledgment (หรือ log ถ้าส่งไม่ได้) | US-010 |
| INV-4 | ไม่มีการบันทึกค่า Password/OTP ในทุก list | US-004, US-009 |
| INV-5 | flow ที่ error ต้องเขียน `ErrorLog` (ไม่จบเงียบ) | US-008 |
| INV-6 | `CaseID` ไม่ซ้ำ | US-008 |

---

## Traceability
Foundation เป็น cross-cutting — รองรับทุก story ผ่าน schema/flows/conventions:
| Requirement | รองรับโดย |
|-------------|-----------|
| US-005~009 (case) | Cases, Routing, CreateCaseAndAck, CaseID |
| US-010~013 (notify) | CreateCaseAndAck (ack), NotifyStatusChange, RemindStaleCases, SLAConfig |
| US-014~015 (kb) | KnowledgeGaps, KnowledgeBase governance keys |
| US-001~004 (answering) | guardrail baseline, KnowledgeBase (Active/Review) |
