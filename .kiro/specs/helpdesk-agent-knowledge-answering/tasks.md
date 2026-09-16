# Implementation Tasks — unit: knowledge-answering

## Overview
Tasks จัดตาม behavior: guardrails → grounded answer → required-info → disambiguation → no-answer handoff

**Derived From**: US-001, US-002, US-003, US-004; design `.kiro/specs/helpdesk-agent-knowledge-answering/design.md`
**Strategy**: Behavior-ordered — Standard, Test-after
**Depends on unit**: `foundation` (guardrail baseline, `KnowledgeGaps`, handoff `OpenCase`), `case-management` (`OpenCase` topic สำหรับ handoff)

---

- [ ] 1. Guardrails & Instructions
  - [ ] 1.1 อัปเดต `agent.mcs.yml` guardrails (answering-specific)
    - **Deps**: None (ต่อยอด foundation 5.4) | **Ref**: `design.md` — Guardrails (US-004, INV-KA1/2/6)
    - ย้ำ: ตอบเฉพาะ `Approved_Answer` + แสดง `KB_ID`; ไม่ใช้ `Review Required`/ไม่ `Active`; ไม่เดา; ไม่ขอ/เก็บ secret

- [ ] 2. Grounded Answering
  - [ ] 2.1 Search topic — ยึด Approved_Answer + KB_ID
    - **Deps**: 1.1 | **Ref**: `design.md` — Search (US-001, INV-KA1)
    - ปรับ `Search`/instruction ให้แสดง KB_ID ท้ายคำตอบ
  - [ ] 2.2 Required-info check ก่อนสรุป
    - **Deps**: 2.1 | **Ref**: `design.md` — required-info (US-002, INV-KA4)
    - ถ้า `Required_Information` ไม่ครบ → ถามตาม `Followup_Question` จนครบ

- [ ] 3. Disambiguation & No-answer
  - [ ] 3.1 Disambiguation (หลายรายการ)
    - **Deps**: 2.1 | **Ref**: `design.md` — Disambiguation (US-003, INV-KA3)
    - match หลาย System/อาการ → ถามเลือกก่อน → ตอบรายการเดียว
  - [ ] 3.2 No-answer handoff + log gap
    - **Deps**: 2.1 | **Ref**: `design.md` — No-answer handoff (US-001 AC3, INV-KA5)
    - ไม่พบคำตอบยืนยันได้ → แจ้ง + `BeginDialog OpenCase` + เขียน `KnowledgeGaps`

- [ ] 4. Test & Deploy (UAT)
  - [ ] 4.1 UAT checklist INV-KA1~6 + ชุดคำถามตัวอย่าง
    - **Deps**: 2.2, 3.1, 3.2 | **Ref**: `design.md` — Correctness
    - กรณีทดสอบ: (ก) ตอบได้จาก KB, (ข) หลายรายการ, (ค) ตอบไม่ได้ → เปิดเคส+gap, (ง) รายการไม่ Active → ไม่ตอบ
  - [ ] 4.2 Deploy UAT
    - **Deps**: 4.1 | **Ref**: `foundation.md` — deployment
    - publish ผ่าน pac

---

## Task Summary
| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | Guardrails instructions | None | [ ] |
| 2.1 | Grounded answer + KB_ID | 1.1 | [ ] |
| 2.2 | Required-info check | 2.1 | [ ] |
| 3.1 | Disambiguation | 2.1 | [ ] |
| 3.2 | No-answer handoff + gap | 2.1 | [ ] |
| 4.1 | UAT checklist + ชุดคำถาม | 2.2,3.1,3.2 | [ ] |
| 4.2 | Deploy UAT | 4.1 | [ ] |

---

## Requirements Coverage
| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-001 ตอบจาก KB | 2.1, 3.2 | [ ] |
| US-002 required-info | 2.2 | [ ] |
| US-003 disambiguation | 3.1 | [ ] |
| US-004 guardrails | 1.1 | [ ] |

---

## Design Coverage
**Components**: Search/answer → 2.1; required-info → 2.2; disambiguation → 3.1; guardrails → 1.1; no-answer → 3.2
**Entities**: KnowledgeBase (read), KnowledgeGaps (write via 3.2)

---

## Definition of Done
- [ ] ผ่าน INV-KA1~6
- [ ] ชุดคำถามตัวอย่าง 4 กรณีผ่าน
- [ ] publish ผ่าน pac

---

## Execution Waves
| Wave | Tasks | Dependencies Resolved | Parallel |
|------|-------|-----------------------|----------|
| 1 | 1.1 | None | No |
| 2 | 2.1 | Wave 1 | No |
| 3 | 2.2, 3.1, 3.2 | Wave 2 | Yes |
| 4 | 4.1 | Wave 3 | No |
| 5 | 4.2 | Wave 4 | No |

### File / Artifact Ownership Per Wave
**Wave 3**: 2.2/3.1/3.2 อยู่ใน `topics/Search.mcs.yml` (+ handoff) — Standard ทำตามลำดับ; 1.1 อยู่ `agent.mcs.yml`

---

## Notes
**Cross-unit**: no-answer handoff (3.2) พึ่ง `OpenCase` (case-management) และ `KnowledgeGaps` (foundation); guardrail baseline มาจาก foundation 5.4
