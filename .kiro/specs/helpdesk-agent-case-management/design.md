# Design: case-management (helpdesk-agent)

## Summary
- **Architecture**: Copilot Studio topics (agent-side) เก็บข้อมูล/จำแนกประเภท → เรียก `CreateCaseAndAck` (foundation flow) → คืน CaseID
- **Stack**: MCS topics (`.mcs.yml`) + Power Fx; ใช้ flow/lists/templates จาก foundation
- **Components**: `OpenCase` (reusable, redesigned), `Escalate` (delegates), classification + summary logic
- **Entities**: ใช้ `Cases` จาก foundation (ไม่มี list ใหม่)
- **Endpoints**: เรียก `CreateCaseAndAck` (skills) ด้วย input contract ที่ตั้งชื่อแล้ว

> อ้างอิง foundation: `.kiro/specs/helpdesk-agent/foundation.md`, `.kiro/specs/helpdesk-agent-foundation/design.md`

## Architecture
```
[User] --> OpenCase topic (reusable)
             1) จำแนก/ยืนยัน CaseType (จาก Action_Type ของ KB ที่ match)
             2) ถาม required info (dynamic ตาม KB + fixed: name/tel/system/priority)
             3) สร้าง IssueSummary + ConversationSummary (agent)
             4) InvokeFlowAction CreateCaseAndAck ---> [foundation flow] --> Cases + CaseID + emails
             5) แสดง CaseID ยืนยันในแชท
Escalate topic --> BeginDialog OpenCase (ไม่ทำซ้ำ logic)
Fallback (>3) --> BeginDialog OpenCase   (คงลิงก์เดิม)
```

---

## Components

### Topic: OpenCase (reusable, redesigned)
- **Purpose**: เก็บรายละเอียดปัญหาให้ครบ → จำแนกประเภท → เรียก flow → ยืนยัน CaseID
- **Responsibilities**:
  - จำแนก `CaseType` จาก `Action_Type` ของรายการ KB ที่ match; ถ้าไม่ชัด → ถามยืนยัน (US-009)
  - ถาม required info แบบ dynamic ตาม `Required_Information` ของ KB + fixed fields (ชื่อ/เบอร์/System/priority) (US-005, US-006)
  - รับภาพหน้าจอ/error เป็น text/ลิงก์ + แนะแนบเพิ่มทางอีเมล (US-006 AC3)
  - สร้าง `IssueSummary` (agent สรุป) + `ConversationSummary` (ย่อ + KB_ID ที่ลองแล้ว)
  - เรียก `CreateCaseAndAck` แล้วแสดง `CaseID` ยืนยัน
- **Consumes**: `CreateCaseAndAck` (foundation), KB context (KB_ID/Action_Type/Required_Information)
- **Cancel**: ถ้าผู้ใช้ยกเลิกกลางคัน → จบโดยไม่เรียก flow (INV)

### Topic: Escalate (delegator)
- เมื่อผู้ใช้ขอเจ้าหน้าที่ → `BeginDialog OpenCase` (ไม่ทำซ้ำ)

### Logic: CaseType inference
- map `Action_Type` → `CaseType`: Service Request→Service Request, Incident→Incident, Business Support→Business Support, access-related (reset/unlock/ขอ user)→Access
- ถ้า match หลาย/ไม่ชัด → ถามผู้ใช้ยืนยันจากตัวเลือก

---

## Data Model
ใช้ `Cases` (foundation) — ฟิลด์ที่ unit นี้ป้อน:
| Field | มาจาก |
|-------|-------|
| CaseType | inference (D3-2) |
| SystemName | คำถาม System (+ระบุเองถ้า "อื่นๆ") |
| Priority | คำถาม ปกติ/ด่วน |
| Severity | จาก KB (ถ้ามี match) |
| ProblemDetail | ข้อความผู้ใช้ |
| IssueSummary | agent สรุป |
| ConversationSummary | agent ย่อ + KB_ID |
| KBRef | KB_ID ที่เกี่ยว |
| Username | ถามเพิ่มเมื่อ CaseType = Access |
| ReporterName/Email/Tel | ถาม + System.User.Email |

**ไม่มี list ใหม่ในหน่วยนี้**

---

## API / Flow Specification
เรียก `CreateCaseAndAck` (foundation, skills) ด้วย input:
```
{ actionType: <label>, contactEmail: System.User.Email, contactName, contactTel,
  systemName, caseType, priority, severity, issueDetail, issueSummary,
  kbRef, username? }
```
- **Response**: `{ caseId, status }` → แสดง `caseId` ในแชท (US-010 AC2 ฝั่ง chat)
- **Errors**: ถ้า flow คืน error → แจ้งผู้ใช้ว่าจะมีเจ้าหน้าที่ตรวจสอบ (ไม่จบเงียบ)

---

## Integration Points
| External | Protocol | Purpose | Error Handling |
|----------|----------|---------|----------------|
| foundation `CreateCaseAndAck` | InvokeFlowAction (skills) | สร้างเคส + แจ้ง + ack | flow มี error handling; agent แจ้งผู้ใช้เมื่อ error |
| KnowledgeBase | (ผ่าน answering/KB context) | ดึง Action_Type/Required_Information/KB_ID | ถ้าไม่มี match → CaseType ถามผู้ใช้ |

---

## Implementation
### Artifacts
```
HelpMe Agent/topics/
├── OpenCase.mcs.yml      (redesign: dynamic questions, CaseType infer, summary, named flow input)
└── Escalate.mcs.yml      (delegate → OpenCase)
```
### Conventions
- ใช้ ClosedListEntity เดิมสำหรับ priority/system; เพิ่ม logic ระบุ System เอง
- Flow input ใช้ชื่อ field ตาม contract ของ foundation (ไม่ใช้ text_1..6)

---

## Non-Functional Requirements
- อ้าง NFR ของ foundation; เพิ่ม: การถามข้อมูลต้องกระชับ (ไม่ถามซ้ำสิ่งที่มี), แสดง CaseID ทันทีหลัง flow สำเร็จ

---

## Correctness Properties (Invariants)
| Property | Description | Validates |
|----------|-------------|-----------|
| INV-CM1 | ข้อมูลจำเป็นครบก่อนเรียก `CreateCaseAndAck` | US-005, US-006 |
| INV-CM2 | ทุกเคสมี `CaseType` ถูก set | US-009 |
| INV-CM3 | ยกเลิกกลางคัน → ไม่เรียก flow / ไม่สร้างเคส | US-005 AC3 |
| INV-CM4 | ไม่ถาม/ส่ง Password/OTP แม้เป็นเคส Access | US-004, US-009 |
| INV-CM5 | หลัง flow สำเร็จ ต้องแสดง `CaseID` ในแชท | US-010 |

---

## Traceability
| Requirement | Component |
|-------------|-----------|
| US-005 เปิดเคส | OpenCase (collect + cancel) |
| US-006 บันทึกบริบท | IssueSummary/ConversationSummary/attachments |
| US-007 routing | ส่งผ่าน flow (foundation) |
| US-008 CaseID+แจ้งทีม | เรียก flow + แสดง CaseID |
| US-009 CaseType | inference logic |
