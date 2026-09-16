# Design: kb-governance (helpdesk-agent)

> ⚠️ **ข้อจำกัดสำคัญ**: `KnowledgeBase` (`AI_KnowledgeBase_Helpdesk`) อยู่ที่ site **`BusinessAnalystandHelpdesk`** และเป็น **ของทีมอื่น** → unit นี้ทำได้แค่ **read + เสนอ/ประสาน** เท่านั้น ห้ามปรับโครงสร้าง/สิทธิ์ของ list เขา. `KnowledgeGaps` (ของเรา) อยู่บน PowerAppPRD. การอนุมัติเนื้อหา (US-015) ดำเนินการโดยเจ้าของ KB — สเปกนี้เตรียม gap report + ข้อเสนอ draft ให้เขาพิจารณา

## Summary
- **Architecture**: กระบวนการบน SharePoint — views สำหรับ gap (บน `KnowledgeGaps` ของเรา) + เสนอ lifecycle ให้เจ้าของ `KnowledgeBase` (ส่วนใหญ่เป็น process/coordination ไม่ใช่ flow ใหม่)
- **Stack**: SharePoint lists + permissions; (option) flow ช่วยรวม gap/สร้าง draft
- **Components**: Gap report views, KB approval lifecycle, Gap→KB linkage
- **Entities**: `KnowledgeGaps`, `KnowledgeBase` (foundation) — ไม่มี list ใหม่
- **Endpoints**: SharePoint views/forms; (option) flow `CompileGap`

> อ้างอิง: `.kiro/specs/helpdesk-agent/foundation.md`; KB `AI_KnowledgeBase_Helpdesk`

## Architecture
```
[KnowledgeGaps] --SharePoint views (group by System, sort Frequency, filter New)--> ผู้ดูแล KB  (US-014)
   └─ (option) flow CompileGap: normalize + เพิ่ม Frequency แทนสร้างซ้ำ
[KnowledgeBase] --lifecycle: Draft -> Review Required -> Approved (+ Is_Active)--> agent ใช้เฉพาะ Approved+Active (US-015, US-004)
[Gap เลือกทำ] --> สร้าง KB draft --> update KnowledgeGaps.Status = Added to KB
```

---

## Components

### Gap Report (US-014)
- SharePoint views บน `KnowledgeGaps`: group by `SystemGuess`, sort `Frequency` desc, filter `Status = New`
- (option) flow `CompileGap`: เมื่อเขียน gap ใหม่ → normalize (System + คำถามคล้าย) → ถ้ามีอยู่แล้วเพิ่ม `Frequency`, ไม่งั้นสร้างใหม่

### KB Approval Lifecycle (US-015)
- `KnowledgeBase.Review_Status`: Draft → Review Required → Approved
- `Is_Active`: Active/Inactive
- อนุมัติ = ผู้ดูแล KB เปลี่ยน Review_Status=Approved + Is_Active=Active (จำกัดด้วย SharePoint permission)
- รายการใหม่/แก้ไข → เริ่มที่ Review Required

### Gap → KB Linkage
- จาก gap รายการหนึ่ง → สร้าง KB draft (คัดลอกบริบท) → อัปเดต `KnowledgeGaps.Status = Added to KB`

---

## Data Model
ใช้ (foundation): `KnowledgeGaps` (UserQuestion, SystemGuess, Frequency, RelatedCaseID, Status), `KnowledgeBase` (Review_Status, Is_Active, + ฟิลด์เนื้อหา). **ไม่มี list ใหม่**

---

## Integration Points
| External | Protocol | Purpose | Error Handling |
|----------|----------|---------|----------------|
| SharePoint (KnowledgeGaps) | views / (option) flow | รายงาน + dedup | flow error → ErrorLog |
| SharePoint (KnowledgeBase) | list forms + permission | authoring/approval | — |
| knowledge-answering | (ทางอ้อม) | ใช้เฉพาะ Approved+Active | guardrail ใน answering |

---

## Implementation
### Artifacts
```
SharePoint:
- KnowledgeGaps: เพิ่ม views (New by System/Frequency)
- KnowledgeBase: ตั้ง choice Review_Status/Is_Active + permission ผู้ดูแล
(option) HelpMe Agent/workflows/CompileGap/   # normalize + frequency
```
### Conventions
- รายการใหม่เริ่ม `Review Required`; agent ใช้เฉพาะ Approved+Active (บังคับใน knowledge-answering)

---

## Non-Functional Requirements
- Governance เป็นงานเป็นงวด (ไม่เรียลไทม์); ความปลอดภัย = จำกัดสิทธิ์อนุมัติ

---

## Correctness Properties (Invariants)
| Property | Description | Validates |
|----------|-------------|-----------|
| INV-KG1 | agent ตอบจากรายการ Approved + Active เท่านั้น | US-004, US-015 |
| INV-KG2 | รายการ KB ใหม่/แก้ไข เริ่มที่ `Review Required` | US-015 |
| INV-KG3 | gap ที่ถูกเติมเป็น KB → `Status = Added to KB` | US-014 |
| INV-KG4 | gap ซ้ำเพิ่ม `Frequency` ไม่สร้างซ้ำ | US-014 |

---

## Traceability
| Requirement | Component |
|-------------|-----------|
| US-014 gap report | Gap Report views + (option) CompileGap |
| US-015 KB governance | Approval lifecycle + Gap→KB linkage |
