# D3 Design Decisions — unit: knowledge-answering

## Context Summary
- **Unit**: `knowledge-answering` — US-001, US-002, US-003, US-004 (ตอบจาก KB, required-info, disambiguation, guardrails)
- **ฐานเดิม**: topic `Search` (`SearchAndSummarizeContent`), agent instructions (guardrails), KB `AI_KnowledgeBase_Helpdesk` (74 รายการ)
- **Settled by foundation**: guardrail baseline ใน `agent.mcs.yml`, handoff → `OpenCase`, `KnowledgeGaps` list
- **D3 นี้โฟกัส**: พฤติกรรมการตอบและ guardrails

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### D3-1: กลไกการตอบแบบ grounded (US-001)
**Question**: จะให้ agent ตอบจาก KB อย่างไร?
- 1) คง `SearchAndSummarizeContent` (generative grounded) + instruction ยึด `Approved_Answer` + แสดง `KB_ID` **(Recommended)**
- 2) เปลี่ยนเป็น structured lookup (query KB list ตรง ๆ ด้วย System/Category)
- 3) Hybrid (lookup ก่อน ถ้าไม่ชัดใช้ generative)
- 4) Other: _______

**Answer**: 1

---

### D3-2: การแยกแยะหลายรายการ (Disambiguation) — US-003
**Question**: เมื่อ match หลายรายการจะทำอย่างไร?
- 1) ถามให้เลือก System/อาการก่อน (ใช้ตัวเลือกจาก System/Category) แล้วตอบรายการเดียว **(Recommended)**
- 2) เดาอันที่มั่นใจสุด
- 3) Other: _______

**Answer**: 1

---

### D3-3: การบังคับเก็บ Required Info ก่อนตอบ/เปิดเคส (US-002)
**Question**: จะตรวจข้อมูลที่จำเป็นอย่างไร?
- 1) ตรวจ `Required_Information` ของรายการที่ match → ถามให้ครบก่อนสรุป/เปิดเคส **(Recommended)**
- 2) ตอบทันทีไม่ตรวจ
- 3) Other: _______

**Answer**: 1

---

### D3-4: การบังคับ Guardrails (US-004)
**Question**: จะบังคับ guardrails ที่ไหน?
- 1) รวมใน agent instruction (baseline จาก foundation) + ย้ำในบริบท answering; ไม่ตอบจากรายการ Review Required/ไม่ Active; ไม่เก็บ secret **(Recommended)**
- 2) แยก topic ตรวจสอบเฉพาะ
- 3) Other: _______

**Answer**: 1

---

### D3-5: การกรองสถานะ KB (Freshness) — US-004
**Question**: จะมั่นใจได้อย่างไรว่าใช้เฉพาะรายการที่อนุมัติ/Active?
- 1) พึ่ง governance (`kb-governance`) รักษา `Is_Active`/`Review_Status` + instruction ห้ามใช้ที่ไม่ Active **(Recommended)**
- 2) เพิ่ม filter ในการ query (กรณี structured/hybrid)
- 3) Other: _______

**Answer**: 1

---

### D3-6: การจัดการเมื่อไม่พบคำตอบ (US-001 AC3)
**Question**: เมื่อไม่พบคำตอบที่ยืนยันได้จะทำอย่างไร?
- 1) แจ้งว่าไม่พบข้อมูลที่ยืนยันได้ → เสนอเปิดเคส (handoff → `OpenCase`) + เขียน `KnowledgeGaps` **(Recommended)**
- 2) แจ้งอย่างเดียว (ไม่เปิดเคส)
- 3) Other: _______

**Answer**: 1

---

### D3-7: Correctness (Invariants) — บังคับถาม
**Question**: จะยืนยันความถูกต้องอย่างไร?
- 1) Invariants checklist: "ตอบเฉพาะ Approved_Answer + แสดง KB_ID", "ไม่ตอบจากรายการไม่ Active", "ไม่เดา", "ไม่พบ → เปิดเคส + log gap", "ไม่เก็บ secret" **(Recommended)**
- 2) ใช้ PBT (harness ภายนอก)
- 3) Other: _______

**Answer**: 1

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
- D3-1 Grounding: คง `SearchAndSummarizeContent` (generative grounded) + ยึด Approved_Answer + แสดง KB_ID
- D3-2 Disambiguation: ถามเลือก System/อาการก่อน แล้วตอบรายการเดียว
- D3-3 Required Info: ตรวจ `Required_Information` → ถามให้ครบก่อนสรุป/เปิดเคส
- D3-4 Guardrails: agent instruction baseline + ย้ำใน answering; ไม่ใช้ Review Required/ไม่ Active; ไม่เก็บ secret
- D3-5 KB Freshness: พึ่ง kb-governance รักษา Is_Active/Review_Status + instruction ห้ามใช้ที่ไม่ Active
- D3-6 No-answer: แจ้งไม่พบ → เสนอเปิดเคส (handoff OpenCase) + เขียน KnowledgeGaps
- D3-7 Correctness: invariants checklist (Approved_Answer+KB_ID, ไม่ Active=ไม่ตอบ, ไม่เดา, ไม่พบ→เคส+gap, no secret)

---

**Instructions**: Fill in your answers above and respond with "design decisions complete" (หรือ "done" / "use recommendations")
