# Tasks & Implementation Decisions (D4)

## Context Summary
- **Feature**: `helpdesk-kb-management`
- **Scope**:
  - Storage & Governance: Document Library `SystemManuals` และ SharePoint List `AI_KnowledgeBase` (นำเข้า Q&A 74 ข้อแล้ว)
  - Conversational AI UX: ปรับคอนฟิก Copilot Studio Knowledge Sources ชี้มายัง PowerAppPRD, ปรับ System Instructions และเพิ่มการเสนอ 2 คำถามต่อยอดท้ายคำตอบ
  - Deployment & Verification: เผยแพร่ผ่าน `pac copilot publish` และทดสอบ Golden Benchmark
- **Current Progress**:
  - ข้อมูล Q&A 74 ข้อนำเข้าเรียบร้อย
  - YAML configs ได้รับการ Re-point ชี้ `PowerAppPRD` และ Publish ผ่าน `pac` เรียบร้อยแล้ว

---

## Decision Questions

### D4-1: Task Packaging & Delivery Breakdown Strategy
**Question**: ควรแบ่งแพ็กเกจของ Tasks การพัฒนาและการส่งมอบตามแนวทางใด?
- 1) **Foundation-to-Feature Progressive Delivery**: แบ่งงานเป็น 3 ระยะ:
     - Phase 1: Storage Layer & Data Governance (ตรวจสอบ Library, List Schema, ข้อมูล 74 ข้อ, สิทธิ์ RBAC)
     - Phase 2: Conversational AI & Prompt Engineering (Knowledge Sources YAML, System Instructions, Follow-up Prompts, Topic v4K Quick Replies)
     - Phase 3: Verification, Operational SOP & Rollout (Golden Q&A Testing, Admin Guide, Production Handoff) **(Recommended)**
     - *ข้อดี*: เป็นขั้นตอนชัดเจน สอดคล้องกับระเบียบวิธี AIDLC และตรวจสอบผลได้เป็นขั้นๆ
     - *ข้อเสีย*: ต้องส่งมอบเรียงตามลำดับ
- 2) **Single Big-Bang Release Task**: รวมงานทั้งหมดเป็น Task เดียวและทดสอบภาพรวมครั้งเดียว
     - *ข้อดี*: เอกสารน้อย
     - *ข้อเสีย*: ติดตามสถานะและแยกตรวจสอบยาก
- 3) Other (please specify): _______

**Answer**: 1) Foundation-to-Feature Progressive Delivery (Recommended)

---

### D4-2: Verification Execution Approach
**Question**: วิธีการดำเนินการทดสอบ Golden Benchmark 15-20 คำถามตามมติ D3-5 ควรใช้รูปแบบใด?
- 1) **Interactive Studio Test Pane + Structured Verification Matrix**: ทดสอบถามจริงใน Copilot Studio Test Pane และ Microsoft Teams แชนแนล บันทึกผลลัพธ์ลงใน Verification Matrix ตรวจสอบทั้งคำตอบ, ลิงก์ Citations, และคำถามแนะนำ 2 ข้อ **(Recommended)**
     - *ข้อดี*: สะท้อนประสบการณ์ใช้งานจริงของ End-User 100%, เห็นการแสดงผล Markdown Bullets และ Citation Card จริง
     - *ข้อเสีย*: เป็นการทดสอบแบบ Semi-automated / Manual verification
- 2) **Headless Bot Framework Direct API Automation**: เขียนสคริปต์ยิงข้อความผ่าน Direct Line API เพื่อเช็คข้อความตอบกลับ
     - *ข้อดี*: รันอัตโนมัติได้
     - *ข้อเสีย*: ต้องเปิด Direct Line Token เพิ่มเติม และไม่สะท้อน Client UI Rendering บน Teams
- 3) Other (please specify): _______

**Answer**: 1) Interactive Studio Test Pane + Structured Verification Matrix (Recommended)

---

### D4-3: Rollout & Target Audience Deployment
**Question**: กลยุทธ์การเปิดใช้งาน Agent ให้พนักงานในองค์กรใช้งาน (Rollout Strategy) ควรเป็นอย่างไร?
- 1) **Immediate Enterprise-Wide Live Release (UAT -> Production)**: เนื่องจาก Bot เดิมมีผู้ใช้งานอยู่แล้ว และการย้ายแหล่งข้อมูลมายัง `PowerAppPRD` ช่วยเพิ่มความเสถียรและความถูกต้อง เมื่อ Publish แล้วให้เปิดรับการใช้งานของพนักงานทั่วไปได้ทันที โดยมี IT Helpdesk คอย Monitor เคส **(Recommended)**
     - *ข้อดี*: พนักงานได้คำตอบที่ถูกต้องจากฐานข้อมูลใหม่ทันที ไม่เกิดความล่าช้า
     - *ข้อเสีย*: ต้องคอยเฝ้าระวังคำถามใหม่ๆ ในช่วงแรก
- 2) **Phased Pilot Group Rollout**: เปิดให้เฉพาะทีม IT Helpdesk และ BA ทดสอบใช้งาน 1 สัปดาห์ก่อนเปิดให้พนักงานทั้งองค์กร
     - *ข้อดี*: มีช่วงเวลาทดสอบในกลุ่มปิด
     - *ข้อเสีย*: ชะลอการได้รับประโยชน์จากคลังความรู้ใหม่
- 3) Other (please specify): _______

**Answer**: 1) Immediate Enterprise-Wide Live Release (Recommended)

---

### D4-4: Operational Documentation & Knowledge Handover
**Question**: เอกสารส่งมอบการปฏิบัติงาน (Runbook & SOP) สำหรับทีมงาน IT Helpdesk ควรจัดทำในรูปแบบใด?
- 1) **Comprehensive Markdown SOP & Maintenance Runbook**: จัดทำคู่มือปฏิบัติงานรวมศูนย์ในโปรเจกต์ (`KNOWLEDGE-BASE-SETUP-GUIDE.md` และ `design/implementation.md`) อธิบายขั้นตอนการเพิ่ม/แก้ไขไฟล์คู่มือ, การจัดการ Q&A ใน SharePoint, ขั้นตอน Force Indexing, และการ Monitor ผ่าน Copilot Studio Analytics **(Recommended)**
     - *ข้อดี*: เป็นเอกสาร Living Documentation บำรุงรักษาและแชร์ในทีมได้สะดวก
     - *ข้อเสีย*: ต้องอัปเดตเมื่อมีการเปลี่ยนขั้นตอน
- 2) **Quick Reference Cheat-sheet Only**: ทำเอกสารสรุป 1 หน้ากระดาษเฉพาะลิงก์และคอลัมน์ที่ต้องกรอก
     - *ข้อดี*: สั้นกระชับ
     - *ข้อเสีย*: ขาดรายละเอียดเชิงลึกในการแก้ไขปัญหาดัชนีไม่อัปเดต
- 3) Other (please specify): _______

**Answer**: 1) Comprehensive Markdown SOP & Maintenance Runbook (Recommended)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D4-1 Task Breakdown Strategy: Foundation-to-Feature Progressive Delivery (Recommended)
- D4-2 Verification Execution: Interactive Studio Test Pane + Structured Verification Matrix (Recommended)
- D4-3 Rollout Strategy: Immediate Enterprise-Wide Live Release (Recommended)
- D4-4 Documentation Handover: Comprehensive Markdown SOP & Maintenance Runbook (Recommended)

---

**Instructions**: Fill in your answers above and respond with "tasks decisions complete" or "use recommendations"
