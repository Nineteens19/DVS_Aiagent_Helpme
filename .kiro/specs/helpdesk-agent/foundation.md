# Foundation Specification

## Summary
<!-- Compact digest for downstream agents. Read ONLY this section. -->
- **Team**: Small team (1–3), sequential
- **Repo**: Single repo (MCS project export) — `HelpMe Agent/` + supporting assets
- **Architecture**: Copilot Studio agent (topics) + Power Automate flows + SharePoint lists (logical units)
- **Gateway**: N/A (ไม่ใช่ microservices)
- **Auth**: Integrated (Entra); reporter identity = `System.User.Email`
- **Error Format**: Flow error handling + `ErrorLog` list, error code `[DOMAIN]_[NUMBER]`
- **Inter-Unit Comms**: SharePoint lists = source of truth + Power Automate triggers (managed eventing) + topic handoff
- **Database**: SharePoint lists (site `PowerAppPRD`) — Case (consolidated), Routing, SLAConfig, KB, Gap, ErrorLog
- **Shared Types**: SharePoint column schema + flow input contract (skills trigger) + event payloads
- **Frontend**: N/A (channels: MS Teams, M365 Copilot)
- **Infrastructure Units**: Foundation (combined)

---

## Team & Sequence

| Unit | Owner | Priority | Sequence |
|------|-------|----------|----------|
| foundation | ทีม Helpdesk/BA | Foundation | 1st — schema/contracts/conventions ต้องนิ่งก่อน |
| case-management | ทีม Helpdesk/BA | High | 2nd — core P1 |
| notification-followup | ทีม Helpdesk/BA | High/Med | 2nd–3rd — ทำคู่กับ case ได้ (ack), status/SLA ตามหลัง |
| knowledge-answering | ทีม Helpdesk/BA | High | 3rd — ฐานเดิมทำงานอยู่ เสริม guardrail/disambiguation |
| kb-governance | ผู้ดูแล KB | Low | 4th |

**Parallel Work**: case-management กับ notification-followup (เฉพาะ acknowledgment) ทำคู่ขนานได้หลัง Foundation เพราะแชร์ contract `CaseCreated`

---

## Repository / Project Structure

**Strategy**: Single repo (โครงสร้าง MCS export เดิม)
**Rationale**: เป็น agent เดียว จัดการผ่าน pac CLI; ไม่จำเป็นต้องแยก repo

```
HelpMe Agent/
├── agent.mcs.yml                 # instructions/guardrails (แก้เพื่อสื่อสาร CaseID/ack)
├── settings.mcs.yml              # channels, auth, AI settings
├── connectionreferences.mcs.yml  # SharePoint + Office 365 connections
├── topics/
│   ├── Search.mcs.yml            # [knowledge-answering] ตอบจาก KB
│   ├── OpenCase.mcs.yml          # [case-management] เก็บข้อมูล → เรียก flow
│   ├── Escalate.mcs.yml          # [case-management] handoff เจ้าหน้าที่
│   ├── Fallback.mcs.yml          # [knowledge-answering] → OpenCase
│   └── CaseStatus.mcs.yml        # [notification-followup] เช็คสถานะด้วย CaseID (ใหม่)
├── workflows/
│   ├── CreateCaseAndAck/         # [case+notification] สร้างเคส + แจ้งทีม + ack ผู้แจ้ง
│   ├── NotifyStatusChange/       # [notification] แจ้งเมื่อสถานะเปลี่ยน (ใหม่)
│   └── RemindStaleCases/         # [notification] SLA reminder (ใหม่)
├── entities/
└── knowledge/                    # KB + Manual Systems

SharePoint (site PowerAppPRD):
├── Cases            # เคสรวม (consolidated)
├── Routing          # ผู้รับผิดชอบตามระบบ (เดิม + generalize)
├── SLAConfig        # เกณฑ์ SLA ตาม Severity (ใหม่)
├── KnowledgeBase    # AI_KnowledgeBase_Helpdesk (เดิม)
├── KnowledgeGaps    # คำถามที่ตอบไม่ได้ (ใหม่)
└── ErrorLog         # log ข้อผิดพลาดของ flow (ใหม่)
```

**Ownership Rules**:
- SharePoint schema + connection refs + email templates + error handling → Foundation (แก้ผ่าน review)
- topic/flow เฉพาะหน่วย → หน่วยนั้นดูแล
- Deploy → ผ่าน `deploy-helpme-agent.ps1` (UAT → PROD)

---

## Authentication & Authorization

**Approach**: Integrated authentication (Entra ID) — คงของเดิม (`authenticationMode: Integrated`, `authenticationTrigger: Always`)

**Identity Contract**:
- Reporter email = `System.User.Email` (ไม่ต้องถามซ้ำ)
- ถามเพิ่ม: ชื่อ (`ContactName`), เบอร์ (`ContactTel`)

**Authorization**: Simple role/ownership check
- ผู้แจ้ง: เห็น/เช็คได้เฉพาะเคสที่ `ReporterEmail = System.User.Email`
- เจ้าหน้าที่/Owner: จัดการเคสใน SharePoint (สิทธิ์ตาม SharePoint permission)
- ผู้ดูแล KB: แก้ KnowledgeBase/KnowledgeGaps (สิทธิ์ตาม SharePoint permission)

---

## Error Handling & Reliability

**Format**: Flow-level error handling ด้วย Scope + "run after" (Failed/TimedOut) → เขียน `ErrorLog` → แจ้ง admin

**Standard Error Record** (`ErrorLog` list):
| Field | Type | Note |
|-------|------|------|
| Title | text | สรุปสั้น |
| FlowName | text | ชื่อ flow |
| ErrorCode | choice | `[DOMAIN]_[NUMBER]` |
| ErrorMessage | multiline | ข้อความ error |
| ContextData | multiline | input ที่เกี่ยวข้อง (ไม่รวมข้อมูลลับ) |
| Timestamp | datetime | UTC |
| Notified | yes/no | แจ้ง admin แล้วหรือยัง |

**Error Code Convention** `[DOMAIN]_[NUMBER]`:
| Code | Meaning |
|------|---------|
| CASE_001 | สร้าง Case item ไม่สำเร็จ |
| ROUTE_001 | หา Owner ไม่พบ (ใช้ fallback Helpdesk) |
| EMAIL_001 | ส่งอีเมลไม่สำเร็จ |
| SP_001 | อ่าน/เขียน SharePoint ล้มเหลว |
| SLA_001 | คำนวณ/Query SLA ล้มเหลว |

**Retry**: ใช้ retry policy ของ connector (transient) + ถ้ายัง fail → log + แจ้ง admin + แจ้งผู้ใช้ว่าจะมีเจ้าหน้าที่ตรวจสอบ (ไม่จบเงียบ — สอดคล้อง US-008 AC3)

---

## Inter-Unit Communication (Eventing)

**Pattern**: SharePoint lists = source of truth + Power Automate triggers (managed eventing) + topic handoff ภายใน agent

**Event Catalog**:
| Event | กลไก | Publisher | Subscriber |
|-------|------|-----------|------------|
| `EscalationRequested` | topic handoff (BeginDialog → OpenCase) | knowledge-answering (Fallback/Search) | case-management (OpenCase) |
| `CaseCreated` | flow `CreateCaseAndAck` (หลัง create item) | case-management | notification-followup (ack + team notify) |
| `CaseStatusChanged` | SharePoint "When item modified" (Cases) | เจ้าหน้าที่ (แก้ Statuscase) | notification-followup (`NotifyStatusChange`) |
| `KnowledgeGapDetected` | เขียน `KnowledgeGaps` item | knowledge-answering / case-management | kb-governance |

**Event Payload (logical)**:
```
CaseCreated: { CaseID, CaseType, SystemName, Priority, Severity,
               ReporterName, ReporterEmail, ReporterTel, IssueSummary, KBRef }
CaseStatusChanged: { CaseID, ReporterEmail, OldStatus, NewStatus, StaffNote, ModifiedAt }
KnowledgeGapDetected: { UserQuestion, SystemGuess, RelatedCaseID, Timestamp }
```

**Flow Trigger Input Contract** (skills-triggered `CreateCaseAndAck`, แทน text_/text_1 เดิมด้วยชื่อที่สื่อความหมาย):
```
{ actionType, contactEmail, contactName, contactTel, systemName,
  caseType, priority, severity, issueDetail, issueSummary, kbRef, username? }
```

---

## Database Strategy (SharePoint Lists)

**Approach**: Shared site (`PowerAppPRD`), list-per-concern; Foundation เป็นเจ้าของ schema

### List: `Cases` (consolidated — รวม Incident + UserSystem เดิม)
| Column | Type | Note |
|--------|------|------|
| CaseID | text | `HD-{yyyyMMdd}-{ID}` (unique) |
| CaseType | choice | Incident / Service Request / Business Support / Access |
| SystemName | text | ระบบที่เกี่ยวข้อง |
| Category | text | จาก KB (optional) |
| Priority | choice | ปกติ / ด่วน |
| Severity | choice | P1 / P2 / P3 (จาก KB) |
| ProblemDetail | multiline | รายละเอียดที่ผู้ใช้แจ้ง |
| IssueSummary | multiline | สรุปโดย agent |
| ConversationSummary | multiline | ประวัติสนทนาย่อ |
| KBRef | text | KB_ID ที่อ้างอิง (ถ้ามี) |
| Username | text | optional (เคส access) |
| ReporterName | text | |
| ReporterEmail | text | = System.User.Email |
| ReporterTel | text | |
| Statuscase | choice | Open / In Progress / Resolved / Closed |
| AssignedOwner | text | ทีม/ผู้รับผิดชอบ |
| SlaDueDate | datetime | คำนวณจาก Severity + SLAConfig |
| LastNotifiedStatus | text | ใช้ตรวจจับการเปลี่ยนสถานะ |
| ResolvedAt | datetime | |

### List: `Routing` (เดิม + generalize)
| Column | Type | Note |
|--------|------|------|
| SystemName | text | key (fallback = "Helpdesk") |
| OwnerTeam | text | ชื่อทีม |
| ToNotifyBA | text | email |
| ToNotifySA | text | email |
| CCNotify | text | email |

### List: `SLAConfig` (ใหม่)
| Column | Type | Note |
|--------|------|------|
| Severity | choice | P1/P2/P3 |
| FirstResponseHours | number | เกณฑ์ตอบสนอง |
| ResolutionHours | number | เกณฑ์แก้ไข |
| EscalateToCC | text | email เมื่อเกินเกณฑ์ |

### List: `KnowledgeGaps` (ใหม่)
| Column | Type | Note |
|--------|------|------|
| UserQuestion | multiline | คำถามที่ตอบไม่ได้ |
| SystemGuess | text | ระบบที่คาดว่าเกี่ยว |
| Frequency | number | นับความถี่ |
| RelatedCaseID | text | |
| Status | choice | New / Reviewed / Added to KB / Rejected |

### List: `ErrorLog` (ใหม่) — ดูหัวข้อ Error Handling
### List: `KnowledgeBase` (เดิม) — `AI_KnowledgeBase_Helpdesk` (19 ฟิลด์; key governance: `Review_Status`, `Is_Active`)

**Migration**: ย้ายข้อมูลจาก 2 lists เดิม (Incident + Password/UserSystem) → `Cases` โดย map `CaseType` และ `Username`; เก็บ list เดิมเป็น read-only ชั่วคราวจน migrate เสร็จ

---

## Shared Types & Contracts

**Strategy**: SharePoint column schema เป็น source of truth ของ data + flow input contract + event payload (ด้านบน)
- เปลี่ยนชื่อ binding ของ flow จาก `text`,`text_1`..`text_6` → ชื่อ field ที่สื่อความหมาย (ลด error)
- Choice values เก็บเป็นภาษาอังกฤษภายใน (mapping แสดงผลไทยที่ UI)

---

## Code & Data Conventions

### Artifacts
- **Naming**: lists = PascalCase; flows = Verb-Noun (`CreateCaseAndAck`, `NotifyStatusChange`, `RemindStaleCases`); topics = ชื่อสื่อความหมาย
- **Content language**: ไทย (locale 1054); field/technical names = อังกฤษ
- **Guardrail baseline**: instruction กลางใน `agent.mcs.yml` (ตอบเฉพาะ Approved_Answer, แสดง KB_ID, ห้ามเดา, ห้ามเก็บ secret)

### Data
- **CaseID**: `HD-{yyyyMMdd}-{ID}` (ID = SharePoint item ID)
- **Timestamps**: SharePoint เก็บ UTC; แสดงผล Asia/Bangkok
- **Soft delete**: ใช้ `Statuscase = Closed` (ไม่ลบจริง)

---

## Integration Contracts (sketches)

### knowledge-answering → case-management (`EscalationRequested`)
ส่งผ่าน topic variables: `issue_type`, `priority`, `System`/`SystemName`, `IssueDetail`, `ContactName`, `ContactTel`, `KBRef`, `ConversationSummary`

### case-management → notification-followup (`CaseCreated`)
Case record: `CaseID`, `ReporterEmail`, `Statuscase`, `IssueSummary`, `SystemName`

### notification-followup ← SharePoint (`CaseStatusChanged`)
Trigger "When item modified" on `Cases`; เทียบ `Statuscase` กับ `LastNotifiedStatus`

### (answering|case) → kb-governance (`KnowledgeGapDetected`)
`KnowledgeGaps` item: `UserQuestion`, `SystemGuess`, `RelatedCaseID`

---

## Infrastructure Units

### Foundation (combined)
**Type**: Infrastructure (not domain)
**Purpose**: schema/contract/convention กลางของทั้งระบบ
**Priority**: ทำก่อน domain units ทั้งหมด
**Responsibilities**:
- Provision SharePoint lists: `Cases`, `Routing`, `SLAConfig`, `KnowledgeGaps`, `ErrorLog` (+ ใช้ `KnowledgeBase` เดิม)
- Connection references (SharePoint, Office 365)
- `CaseID` generation logic
- Email templates กลาง (ack / status / reminder)
- Error handling scope + `ErrorLog` + admin notification
- Config-as-data (Routing, SLAConfig)
- Guardrail baseline ใน `agent.mcs.yml`
**Stories**: None (cross-cutting)
**Depended on by**: ทุก domain unit

---

## Logging & Observability
- **Errors**: `ErrorLog` list (โครงสร้างด้านบน)
- **Run history**: Power Automate run history (native)
- **Correlation**: ใช้ `CaseID` เป็น correlation key ข้าม flow/อีเมล

---

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Migrate 2 case lists → `Cases` | High | map CaseType/Username, เก็บ list เดิม read-only จน migrate เสร็จ, ทดสอบใน UAT |
| Rebuild flow เดิม (nested For_each) เป็น 3 flows | High | แยกทีละ flow, รักษา trigger input เดิมชั่วคราว, ทดสอบ end-to-end ก่อน publish |
| แก้ schema กระทบ flow ที่ live | High | เพิ่ม field แบบ backward-compatible, deploy UAT ก่อน |
| อีเมล ack ไม่ถึงผู้แจ้ง | Medium | ใช้ System.User.Email, log EMAIL_001, fallback แสดง CaseID ในแชท |
| PDPA (ข้อมูลติดต่อ) | Medium | เก็บเท่าที่จำเป็น, จำกัดสิทธิ์การเข้าถึงเคส |


---

## Site & Data Location Constraints (ยืนยันโดยผู้ใช้ 2026-09-14)

- **`https://dvsins.sharepoint.com/sites/PowerAppPRD`** — ที่วาง lists ของ Helpdesk solution นี้; **สร้างเฉพาะ list ใหม่ของเรา** (`Cases`, `SLAConfig`, `KnowledgeGaps`, `ErrorLog`). **ห้ามแก้/แตะ list ของทีมอื่น** บน site นี้
- **`Routing`** (มีอยู่แล้วบน PowerAppPRD, table `3d5264cb-...`) — เป็นของ solution เรา; การเพิ่มคอลัมน์ `OwnerTeam` ต้อง**ยืนยันก่อน**
- **KnowledgeBase** = `https://dvsins.sharepoint.com/sites/BusinessAnalystandHelpdesk/Lists/AI_KnowledgeBase_Helpdesk` — **อยู่คนละ site และเป็นของทีมอื่น** → ปฏิบัติแบบ **read-only** เท่านั้น; `kb-governance` = เสนอ/ประสานงานกับเจ้าของ ไม่ปรับโครงสร้าง/สิทธิ์ของเขา
- **นัยต่อ `knowledge-answering`**: KB source (structured search) ชี้ไป site `BusinessAnalystandHelpdesk`; guardrail เรื่อง `Is_Active`/`Review_Status` เป็นการ "อ่านและเคารพ" สถานะที่ทีมนั้นตั้ง
