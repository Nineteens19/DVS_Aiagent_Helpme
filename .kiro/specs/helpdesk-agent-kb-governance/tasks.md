# Implementation Tasks — unit: kb-governance

## Overview
Tasks จัดตาม capability: gap views → KB approval lifecycle → gap→KB linkage → (option) CompileGap flow

**Derived From**: US-014, US-015; design `.kiro/specs/helpdesk-agent-kb-governance/design.md`
**Strategy**: Capability-ordered — Standard, Test-after
**Depends on unit**: `foundation` (`KnowledgeGaps`, `KnowledgeBase`)

---

- [ ] 1. Gap Report
  - [ ] 1.1 สร้าง SharePoint views บน `KnowledgeGaps`
    - **Deps**: None | **Ref**: `design.md` — Gap Report (US-014)
    - view: group by `SystemGuess`, sort `Frequency` desc, filter `Status = New`
  - [ ] 1.2 (option) flow `CompileGap` — dedup + frequency
    - **Deps**: 1.1 | **Ref**: `design.md` — Gap Report (US-014, INV-KG4)
    - เมื่อ gap ใหม่ → normalize (System + คำถามคล้าย) → เพิ่ม `Frequency` ถ้ามีอยู่แล้ว

- [ ] 2. KB Approval Lifecycle
  - [ ] 2.1 ตั้งค่า `KnowledgeBase` lifecycle + permission
    - **Deps**: None | **Ref**: `design.md` — KB Approval Lifecycle (US-015, INV-KG2)
    - choice `Review_Status` (Draft/Review Required/Approved) + `Is_Active`; form; permission ผู้ดูแล KB
  - [ ] 2.2 Approval process
    - **Deps**: 2.1 | **Ref**: `design.md` — KB Approval Lifecycle (US-015, INV-KG1)
    - รายการใหม่/แก้ไข → เริ่ม `Review Required`; อนุมัติ = ผู้ดูแลเปลี่ยน Approved + Active

- [ ] 3. Gap → KB Linkage
  - [ ] 3.1 สร้าง KB draft จาก gap + ปิด gap
    - **Deps**: 1.1, 2.1 | **Ref**: `design.md` — Gap→KB Linkage (US-014, INV-KG3)
    - จาก gap → สร้าง KB draft (Review Required) → อัปเดต `KnowledgeGaps.Status = Added to KB`

- [ ] 4. Test & Deploy (UAT)
  - [ ] 4.1 UAT checklist INV-KG1~4
    - **Deps**: 1.2, 2.2, 3.1 | **Ref**: `design.md` — Correctness
    - ทดสอบ: gap ซ้ำ→frequency, อนุมัติ→ agent ใช้ได้, รายการไม่อนุมัติ→ไม่ถูกใช้ (ร่วมกับ knowledge-answering)
  - [ ] 4.2 Config/flow verify + deploy
    - **Deps**: 4.1 | **Ref**: `foundation.md` — deployment

---

## Task Summary
| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | Gap views | None | [ ] |
| 1.2 | CompileGap flow (option) | 1.1 | [ ] |
| 2.1 | KB lifecycle + permission | None | [ ] |
| 2.2 | Approval process | 2.1 | [ ] |
| 3.1 | Gap→KB draft + ปิด gap | 1.1, 2.1 | [ ] |
| 4.1 | UAT checklist INV-KG | 1.2,2.2,3.1 | [ ] |
| 4.2 | Verify + deploy | 4.1 | [ ] |

---

## Requirements Coverage
| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-014 gap report | 1.1, 1.2, 3.1 | [ ] |
| US-015 KB governance | 2.1, 2.2, 3.1 | [ ] |

---

## Design Coverage
**Components**: Gap views → 1.x; KB lifecycle → 2.x; Gap→KB → 3.1
**Entities**: KnowledgeGaps, KnowledgeBase (foundation)

---

## Definition of Done
- [ ] ผ่าน INV-KG1~4
- [ ] gap report ใช้งานได้; approval จำกัดสิทธิ์ถูกต้อง
- [ ] (ร่วมกับ knowledge-answering) รายการไม่อนุมัติไม่ถูกนำมาตอบ

---

## Execution Waves
| Wave | Tasks | Dependencies Resolved | Parallel |
|------|-------|-----------------------|----------|
| 1 | 1.1, 2.1 | None | Yes |
| 2 | 1.2, 2.2, 3.1 | Wave 1 | Yes |
| 3 | 4.1 | Wave 2 | No |
| 4 | 4.2 | Wave 3 | No |

### File / Artifact Ownership Per Wave
**Wave 1**: 1.1 → `KnowledgeGaps` views; 2.1 → `KnowledgeBase` config/permission
**Wave 2**: 1.2 → flow `CompileGap`; 2.2 → `KnowledgeBase` process; 3.1 → gap→KB process

---

## Notes
**Cross-unit**: INV-KG1 (ใช้เฉพาะ Approved+Active) บังคับใช้จริงใน `knowledge-answering` (guardrail); unit นี้ดูแลสถานะ/กระบวนการ
**Option**: CompileGap flow เป็น optional — เริ่มด้วย views ก่อนได้
