# Design: knowledge-answering (helpdesk-agent)

## Summary
- **Architecture**: Copilot Studio generative answering (grounded บน KB) + guardrails ใน agent instructions + handoff เมื่อไม่พบ
- **Stack**: MCS topic `Search` (`SearchAndSummarizeContent`) + `agent.mcs.yml` instructions; KB `AI_KnowledgeBase_Helpdesk`
- **Components**: Search/answer, disambiguation, required-info check, guardrails, no-answer handoff
- **Entities**: `KnowledgeBase` (read), `KnowledgeGaps` (write) — จาก foundation
- **Endpoints**: SearchAndSummarizeContent; handoff → `OpenCase`

> อ้างอิง: `.kiro/specs/helpdesk-agent/foundation.md`; agent เดิม `HelpMe Agent/agent.mcs.yml`, `topics/Search.mcs.yml`

## Architecture
```
[User question] --> Search topic (SearchAndSummarizeContent over KB)
   ├─ match 1 รายการ Active --> ตอบจาก Approved_Answer + KB_ID           (US-001)
   │      └─ ถ้า Required_Information ยังไม่ครบ --> ถามเพิ่ม (US-002)
   ├─ match หลายรายการ --> ถามเลือก System/อาการ --> ตอบรายการเดียว        (US-003)
   └─ ไม่พบ/ไม่ยืนยันได้ --> แจ้ง + handoff OpenCase + เขียน KnowledgeGaps  (US-001 AC3, US-014)
[Guardrails ใน agent instructions] --> ไม่ใช้ Review Required/ไม่ Active, ไม่เดา, ไม่เก็บ secret (US-004)
```

---

## Components

### Topic: Search (grounded answering)
- คง `SearchAndSummarizeContent` เหนือ KB; instruction บังคับยึด `Approved_Answer` + แสดง `KB_ID` ท้ายคำตอบ
- ถ้า `Required_Information` ของรายการที่ match ยังไม่ครบ → ถามเพิ่มตาม `Followup_Question` (US-002)

### Logic: Disambiguation (US-003)
- ถ้า match หลาย System/อาการ → ถามผู้ใช้เลือกก่อน (ไม่รวมคำตอบ) → ตอบรายการเดียว

### Agent instructions: Guardrails (US-004)
- baseline จาก foundation + ย้ำ: ไม่ตอบจากรายการ `Review_Status = Review Required` หรือ `Is_Active ≠ Active`; ไม่เดาสาเหตุ/วิธีแก้/ผู้รับผิดชอบ; ไม่ขอ/เก็บ Password/OTP; ตอบไทยสุภาพ กระชับ

### No-answer handoff
- ไม่พบคำตอบที่ยืนยันได้ → แจ้ง + `BeginDialog OpenCase` + เขียน `KnowledgeGaps` (US-001 AC3, feeds US-014)

---

## Data Model
ใช้ (foundation): `KnowledgeBase` (read: Approved_Answer, Required_Information, Action_Type, KB_ID, Review_Status, Is_Active), `KnowledgeGaps` (write). **ไม่มี list ใหม่**

---

## Integration Points
| External | Protocol | Purpose | Error Handling |
|----------|----------|---------|----------------|
| KnowledgeBase (structured search) | SearchAndSummarizeContent | ค้น/สรุปคำตอบ grounded | ไม่พบ → handoff OpenCase |
| OpenCase (case-management) | BeginDialog / handoff | เปิดเคสเมื่อตอบไม่ได้ | — |
| KnowledgeGaps | SharePoint write | log คำถามที่ตอบไม่ได้ | error → ErrorLog (foundation) |

---

## Implementation
### Artifacts
```
HelpMe Agent/
├── topics/Search.mcs.yml     (เสริม: required-info check, disambiguation, no-answer handoff)
└── agent.mcs.yml             (guardrails — baseline foundation + ย้ำ answering)
```
### Conventions
- แสดง `KB_ID` ท้ายคำตอบเสมอเมื่ออ้างจาก KB
- ไม่รวมคำตอบจากหลายรายการ

---

## Non-Functional Requirements
- ตอบทั่วไป ≤ ~5 วินาที (ขึ้นกับ model); ยึด grounding เพื่อลดการหลุดกรอบ

---

## Correctness Properties (Invariants)
| Property | Description | Validates |
|----------|-------------|-----------|
| INV-KA1 | ตอบเฉพาะจาก `Approved_Answer` + แสดง `KB_ID` | US-001 |
| INV-KA2 | ไม่ตอบจากรายการ `Review Required`/ไม่ `Active` | US-004 |
| INV-KA3 | match หลายรายการ → ถามเลือกก่อน (ไม่รวมคำตอบ) | US-003 |
| INV-KA4 | Required_Information ไม่ครบ → ถามเพิ่มก่อนสรุป | US-002 |
| INV-KA5 | ไม่พบคำตอบ → handoff เปิดเคส + เขียน gap | US-001, US-014 |
| INV-KA6 | ไม่ขอ/เก็บ Password/OTP | US-004 |

---

## Traceability
| Requirement | Component |
|-------------|-----------|
| US-001 ตอบจาก KB | Search/answer |
| US-002 required-info | required-info check |
| US-003 disambiguation | disambiguation logic |
| US-004 guardrails | agent instructions |
