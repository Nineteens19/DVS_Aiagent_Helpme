# D3 Design Decisions — unit: kb-governance

## Context Summary
- **Unit**: `kb-governance` — US-014 (gap report), US-015 (จัดการ/อนุมัติเนื้อหา KB)
- **Settled by foundation**: `KnowledgeGaps` list, `KnowledgeBase` (Review_Status/Is_Active)
- **D3 นี้โฟกัส**: การรายงาน gap + วงจรอนุมัติ KB (ส่วนใหญ่เป็นงานบน SharePoint + สิทธิ์)

> วิธีตอบ: เติมช่อง **Answer:** แล้วพิมพ์ **"done"** — หรือ **"use recommendations"**

---

## Decision Questions

### D3-1: กลไก Gap Report (US-014)
**Question**: จะให้ผู้ดูแลเห็นคำถามที่ตอบไม่ได้อย่างไร?
- 1) SharePoint views บน `KnowledgeGaps` (group by System/ความถี่, filter Status=New) **(Recommended)**
- 2) Power BI dashboard
- 3) รายงานส่งอีเมลเป็นงวด
- 4) Other: _______

**Answer**: 1

---

### D3-2: การรวม Gap ซ้ำ (Dedup/Frequency)
**Question**: จะจัดการคำถามซ้ำอย่างไร?
- 1) normalize (System + คำถามคล้าย) แล้วเพิ่ม `Frequency` แทนสร้างใหม่ **(Recommended)**
- 2) เก็บทุกครั้งแยกกัน
- 3) Other: _______

**Answer**: 1

---

### D3-3: วงจรอนุมัติเนื้อหา KB (US-015)
**Question**: จะจัดการเพิ่ม/แก้/อนุมัติ KB อย่างไร?
- 1) ใช้ `KnowledgeBase` list + `Review_Status` (Draft → Review Required → Approved) + `Is_Active`; อนุมัติ = เปลี่ยนสถานะ **(Recommended)**
- 2) แก้ผ่าน CSV import เป็นงวด
- 3) Other: _______

**Answer**: 1

---

### D3-4: สิทธิ์การอนุมัติ (Roles)
**Question**: ใครอนุมัติ/activate ได้?
- 1) ผู้ดูแล KB (จำกัดด้วย SharePoint permission บน `KnowledgeBase`) **(Recommended)**
- 2) ทุกคนที่เข้าถึงได้
- 3) Other: _______

**Answer**: 1

---

### D3-5: การเชื่อม Gap → KB
**Question**: เมื่อเติม KB จาก gap จะทำอย่างไร?
- 1) สร้าง KB draft จาก gap แล้วอัปเดต `KnowledgeGaps.Status = Added to KB` **(Recommended)**
- 2) ไม่เชื่อม (จัดการแยก)
- 3) Other: _______

**Answer**: 1

---

### D3-6: Correctness (Invariants) — บังคับถาม
**Question**: จะยืนยันความถูกต้องอย่างไร?
- 1) Invariants checklist: "agent ใช้เฉพาะรายการ Approved+Active", "รายการใหม่เริ่มที่ Review Required", "gap ที่กลายเป็น KB ถูกปิด (Added to KB)" **(Recommended)**
- 2) ใช้ PBT
- 3) Other: _______

**Answer**: 1

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
- D3-1 Gap Report: SharePoint views บน `KnowledgeGaps` (group by System/frequency, filter New)
- D3-2 Dedup: normalize (System + คำถามคล้าย) → เพิ่ม `Frequency`
- D3-3 Approval Lifecycle: `KnowledgeBase` + `Review_Status` (Draft→Review Required→Approved) + `Is_Active`
- D3-4 Roles: ผู้ดูแล KB (SharePoint permission)
- D3-5 Gap→KB: สร้าง KB draft จาก gap → `KnowledgeGaps.Status = Added to KB`
- D3-6 Correctness: invariants (Approved+Active เท่านั้น, ใหม่=Review Required, gap ปิดเมื่อ Added)

---

**Instructions**: Fill in your answers above and respond with "design decisions complete" (หรือ "done" / "use recommendations")
