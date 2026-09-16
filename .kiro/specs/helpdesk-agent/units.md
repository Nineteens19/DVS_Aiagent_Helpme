# Units of Work

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Units**: 5 — foundation, knowledge-answering, case-management, notification-followup, kb-governance
- **Strategy**: Domain-Driven
- **Architecture**: Copilot Studio topics + Power Automate flows + SharePoint lists (logical units, ไม่ใช่ microservices)
- **Story Distribution**: foundation: 0, knowledge-answering: 4, case-management: 5, notification-followup: 4, kb-governance: 2
- **Key Dependencies**: ทุก unit → foundation (Shared Kernel); case → answering (event); notification → case (event); kb-governance → foundation (KB/Gap data)
- **Development Sequence**: Foundation → case-management + notification-followup (P1) → knowledge-answering → kb-governance

## Overview
แตกฟีเจอร์เป็น 5 units สำหรับส่งมอบแบบ phased/incremental — โดยมี Foundation เป็นแกนข้อมูลและ convention ที่ใช้ร่วม

**Strategy**: Domain-Driven
**Rationale**: 15 stories / 4 functional areas / 3 personas — แบ่งตามขอบเขตธุรกิจให้แต่ละหน่วยออกแบบและทดสอบได้ค่อนข้างอิสระ; Foundation เป็น Shared Kernel เพื่อตัด circular dependency ระหว่าง answering ↔ kb-governance ↔ case

**See**: `.kiro/skills/aidlc/references/guides/decomposition-strategies.md` for strategy details

---

## Unit 1: foundation (infrastructure)

**Purpose**: แกนกลางที่ใช้ร่วมทุกหน่วย — schema ของ SharePoint lists, connection references, `CaseID` convention, email templates และ guardrail baseline
**Priority**: Foundation (ทำก่อน)
**Complexity**: Medium

**Stories**: 0 (โครงสร้างพื้นฐาน — รองรับทุก story)

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| ProvisionSchema | สร้าง/ปรับ SharePoint lists (`Cases` รวม, `Routing`, `SLAConfig`, `KnowledgeGaps`, `ErrorLog` + ใช้ `KnowledgeBase` เดิม) | System/Admin |
| DefineCaseIdConvention | นิยามรูปแบบ `HD-{yyyyMMdd}-{ID}` | System |
| DefineEmailTemplates | เทมเพลตอีเมล HTML กลาง (ack/notify/reminder) | System |
| DefineErrorHandling | Scope + ErrorLog + แจ้ง admin (error codes `[DOMAIN]_[NUMBER]`) | System |
| DefineConfigAsData | routing + SLA thresholds เป็น list config | Admin |

### Domain Model
**Aggregates**: —
**Entities (owned, shared kernel)**: KnowledgeItem, Case (consolidated), RoutingRule, SlaConfig, GapItem, ErrorLog
**Value Objects**: CaseId (`HD-{yyyyMMdd}-{ID}`), Contact (name/email/tel), Severity, Priority, CaseType

### Domain Events
**Publishes**: —
**Subscribes**: —

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| — | — | ไม่มี (ทุกหน่วยอื่นพึ่ง Foundation) |

---

## Unit 2: knowledge-answering

**Purpose**: ตอบคำถามจากฐานความรู้ที่อนุมัติแล้ว รวบรวมข้อมูลที่จำเป็น จัดการหลายรายการใกล้เคียง และบังคับ guardrails
**Priority**: High
**Complexity**: Medium

**Stories**: 4 — US-001, US-002, US-003, US-004

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| SearchKnowledge | ค้นรายการ KB ที่ตรงกับคำถาม | System |
| AnswerFromApproved | ตอบจาก `Approved_Answer` + แสดง `KB_ID` | System |
| RequestRequiredInfo | ถามข้อมูลตาม `Required_Information`/`Followup_Question` | System |
| DisambiguateTopic | ถามแยก System/อาการเมื่อพบหลายรายการ | System |
| EnforceGuardrails | บล็อกรายการที่ไม่ Active/Review Required, ปฏิเสธ secret | System |

### Domain Model
**Aggregates**: —
**Entities**: KnowledgeItem (จาก Foundation — Shared Kernel, read-only)
**Value Objects**: UserQuery, Answer, Kb_Reference

### Domain Events
**Publishes**: `EscalationRequested` — เมื่อไม่พบคำตอบที่ยืนยันได้/ผู้ใช้ขอเจ้าหน้าที่ (consumed by case-management)
**Publishes**: `KnowledgeGapDetected` — เขียนลง Gap list (consumed by kb-governance)
**Subscribes**: —

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| foundation | Data (Shared Kernel) | อ่าน KnowledgeItem + สถานะ; เขียน GapItem |

---

## Unit 3: case-management

**Purpose**: เก็บรายละเอียดปัญหา เปิดเคส กำหนดผู้รับผิดชอบตามระบบ สร้าง CaseID/สถานะ และแจ้งทีม
**Priority**: High
**Complexity**: High

**Stories**: 5 — US-005, US-006, US-007, US-008, US-009

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| CollectCaseDetails | ถาม type/priority/system/detail/ชื่อ/เบอร์ | User/System |
| ClassifyCaseType | แยก Incident / Service Request / Business Support | System |
| RouteCase | หา Owner จาก Routing list (fallback Helpdesk) | System |
| CreateCaseRecord | บันทึกเคส + context (KB_ID, summary) ลง SharePoint | System |
| AssignCaseId | สร้าง `CaseID` + ตั้ง `Statuscase = Open` | System |
| NotifyTeam | ส่งอีเมลแจ้งทีม/Owner (To/CC) | System |

### Domain Model
**Aggregates**: Case (root: Case) + IssueDetail + Contact
**Entities**: Case, RoutingRule (จาก Foundation)
**Value Objects**: IssueDetail, Contact, CaseType, CaseId

### Domain Events
**Publishes**: `CaseCreated` — เมื่อเปิดเคสสำเร็จ (consumed by notification-followup)
**Publishes**: `KnowledgeGapDetected` — กรณีเปิดเคสเพราะตอบไม่ได้ (เขียน Gap list)
**Subscribes**: `EscalationRequested` from knowledge-answering — เริ่มเก็บข้อมูลเปิดเคส

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| foundation | Data (Shared Kernel) | Case/Routing schema, CaseID convention |
| knowledge-answering | Event | รับ `EscalationRequested` (handoff เมื่อตอบไม่ได้) |

---

## Unit 4: notification-followup

**Purpose**: แจ้งทราบผู้แจ้ง (acknowledgment), แจ้งเมื่อสถานะเปลี่ยน, ให้เช็คสถานะผ่าน agent และเตือนเคสค้างตาม SLA
**Priority**: High (ack) / Medium (status) / Low (SLA)
**Complexity**: Medium

**Stories**: 4 — US-010, US-011, US-012, US-013

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| SendAcknowledgment | อีเมล + แชท ยืนยัน CaseID ให้ผู้แจ้ง | System |
| NotifyStatusChange | อีเมลแจ้งผู้แจ้งเมื่อสถานะเปลี่ยน | System |
| QueryCaseStatus | ผู้ใช้พิมพ์ CaseID → แสดงสถานะ | User/System |
| RemindStaleCases | เตือนเจ้าหน้าที่เมื่อเคสค้างเกิน SLA ตาม Severity | System |

### Domain Model
**Aggregates**: —
**Entities**: Case (จาก Foundation — read; status update จากเจ้าหน้าที่)
**Value Objects**: Notification, CaseStatus, SlaThreshold

### Domain Events
**Publishes**: —
**Subscribes**: `CaseCreated` from case-management — ส่ง acknowledgment
**Subscribes**: `CaseStatusChanged` (จาก SharePoint update trigger) — ส่งอีเมลแจ้งผู้แจ้ง

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| foundation | Data (Shared Kernel) | Case data, email templates |
| case-management | Event/Data | ต้องมี Case + CaseID ก่อน |

---

## Unit 5: kb-governance

**Purpose**: รวบรวมคำถามที่ตอบไม่ได้ (gap report) และดูแลวงจรอนุมัติเนื้อหา KB (Review → Active)
**Priority**: Low
**Complexity**: Medium

**Stories**: 2 — US-014, US-015

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| CompileGapReport | จัดกลุ่ม GapItem ตาม System/ความถี่ | Admin/System |
| CreateKnowledgeItem | เพิ่มรายการ KB (เริ่มที่ Review Required) | Admin |
| ReviewKnowledgeItem | ทบทวนเนื้อหา | Admin |
| ApproveKnowledgeItem | อนุมัติ → `Is_Active = Active` | Admin |
| DeactivateKnowledgeItem | ปิดใช้งานรายการ | Admin |

### Domain Model
**Aggregates**: KnowledgeItem (root) — governance lifecycle
**Entities**: KnowledgeItem, GapItem (จาก Foundation)
**Value Objects**: ReviewStatus, ActiveFlag

### Domain Events
**Publishes**: `KnowledgeItemApproved` — เมื่ออนุมัติ (knowledge-answering ใช้รายการล่าสุดที่อนุมัติ)
**Subscribes**: `KnowledgeGapDetected` (อ่าน Gap list) — เพื่อพิจารณาเติม KB

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| foundation | Data (Shared Kernel) | KB list, Gap list |

---

## Context Map

### Relationships
| Upstream | Downstream | Pattern |
|----------|------------|---------|
| foundation | ทุก unit | Shared Kernel |
| knowledge-answering | case-management | Publisher/Subscriber (`EscalationRequested`) |
| case-management | notification-followup | Publisher/Subscriber (`CaseCreated`, `CaseStatusChanged`) |
| knowledge-answering / case-management | kb-governance | Publisher/Subscriber (`KnowledgeGapDetected` via Gap list) |
| kb-governance | knowledge-answering | Shared Kernel / Conformist (answering ยึดรายการ KB ที่อนุมัติ) |

**หมายเหตุการตัด circular dependency**: answering และ kb-governance ไม่พึ่งกันโดยตรง — ทั้งคู่ทำงานกับ KB/Gap data ที่ Foundation เป็นเจ้าของ (Shared Kernel) การรายงาน gap เป็นการเขียนลง shared list (async, decoupled)

---

## Development Sequence

### Phase 1: Foundation
- [ ] foundation — schema (Case/Routing/KB/Gap), connection refs, CaseID convention, email templates, guardrail baseline

### Phase 2: Core P1 (case + notification)
- [ ] case-management — เปิดเคส + routing + CaseID + แจ้งทีม (US-005~009)
- [ ] notification-followup — acknowledgment ผู้แจ้ง (US-010) เป็นหลัก + วางฐาน status/SLA

> หมายเหตุ: knowledge-answering ฐานเดิมทำงานอยู่แล้ว (topic `Search` + agent instructions) การ handoff `Fallback → OpenCase` มีอยู่แล้ว จึงเริ่มที่ case+notification (P1) ได้ทันที

### Phase 3: Answering refinement
- [ ] knowledge-answering — เสริม guardrails (US-004), disambiguation (US-003), required-info flow (US-002)

### Phase 4: Governance
- [ ] kb-governance — gap report (US-014) + วงจรอนุมัติ KB (US-015) + status/SLA ที่เหลือ (US-011~013)

---

## Parallel Development

**Team Assignments**: โปรเจกต์เล็ก/ทีมเดียว — ทำตามลำดับเป็นหลัก; case-management กับ notification-followup ทำคู่กันได้หลัง Foundation
**Sync Points**: หลัง Foundation (schema/contract คงที่), หลัง case-management (CaseCreated/CaseID contract), ก่อน publish production
**Communication**: ผ่าน contract ของ SharePoint lists + ชื่อ event (`EscalationRequested`, `CaseCreated`, `CaseStatusChanged`, `KnowledgeGapDetected`)

---

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| flow เดิมมี nested `For_each` ซ้อนหลายชั้น | High | refactor การ resolve MailTo/CC ให้เรียบใน Foundation/case-management |
| แก้ SharePoint schema กระทบ flow เดิมที่ live | High | เพิ่มฟิลด์แบบ backward-compatible, ทดสอบใน UAT ก่อน publish |
| อีเมลส่งผิดผู้รับ/ตกหล่น | Medium | routing fallback = Helpdesk, log + retry, ทดสอบ acknowledgment แยก |
| ข้อมูลติดต่อผู้แจ้ง (PDPA) | Medium | เก็บเท่าที่จำเป็น, จำกัดการเข้าถึงเคสเฉพาะเจ้าของ/เจ้าหน้าที่ |
| generative answer หลุดกรอบ KB | Medium | บังคับ guardrail + ยึด Approved_Answer + แสดง KB_ID |
