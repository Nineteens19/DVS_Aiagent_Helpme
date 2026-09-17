# Phase 3: Units Decisions (D2) — Monitor_case_Helpdesk

## Context Summary
- **ระบบเป้าหมาย**: Power Apps Canvas App `Monitor_case_Helpdesk`
- **ขอบเขตความต้องการ**: 8 User Stories ใน 4 กลุ่มงาน (UI/Laptop Layout, Delegable Filter, Evidence Attachment, Analytics/Schema)
- **ผู้ใช้งานหลัก**: IT Helpdesk Operator (สมชาย) และ Helpdesk Lead/Supervisor (วิภา)
- **โจทย์หลัก**: ปรับโฉมหน้าจอเป็น Modern ปราศจาก Emoji, หน้าจอหนาแน่นกระชับบน Laptop, ระบบแนบหลักฐานปิดเคส, และรองรับข้อมูลขนาดใหญ่แบบ Delegable

---

## Decision Questions

### D2-1: Decomposition Strategy (กลยุทธ์การแบ่ง Units of Work)
**Question**: ควรแบ่งขอบเขตงานการพัฒนา `Monitor_case_Helpdesk` ออกเป็นกี่ Unit เพื่อให้การพัฒนา ทดสอบ และ Rollout เกิดประสิทธิภาพสูงสุด?
- 1) **2 Domain-Based Units: Dashboard-Filter & Case-Resolution**  
  - `Unit 1 (Dashboard & Filter)`: หน้าจอหลัก Modern UI, ปราศจาก Emoji, KPI Cards, Delegable Multi-Criteria Filter, Dense Laptop Grid (ครอบคลุม US-001, US-002, US-003, US-004, US-007)  
  - `Unit 2 (Resolution & Evidence)`: Side Drawer รายละเอียดเคส, ส่วนควบคุมแนบหลักฐาน (Attachments), กฎการปิดงาน (Strict Validation), และ SharePoint Schema Support (ครอบคลุม US-005, US-006, US-008) **(Recommended)**
- 2) **3 Layer-Based Units**: แบ่งเป็น 1. Data/SharePoint Schema, 2. Modern Grid & Search, 3. Resolution & Attachment Form
- 3) **Single Comprehensive Unit**: พัฒนาทุกส่วนรวมเป็นก้อนเดียว
- 4) Other (โปรดระบุ): _______

**Answer**: 1) 2 Domain-Based Units (Unit 1: Dashboard-Filter, Unit 2: Case-Resolution)

---

### D2-2: Canvas App Screen Architecture (สถาปัตยกรรมหน้าจอของ Power Apps)
**Question**: โครงสร้างหน้าจอและ Navigation ภายใน Canvas App ควรจัดสถาปัตยกรรมอย่างไรเพื่อให้เหมาะสมที่สุดกับ Laptop?
- 1) **Single-Screen Master-Detail with Collapsible Side Drawer** — รวมการทำงานหลักไว้ที่หน้า `Home_incident` เดียว โดยแบ่งเป็นตารางรายการเคสฝั่งซ้าย และ Side Drawer เลื่อนเปิด-ปิดฝั่งขวาสำหรับดูรายละเอียด/ปิดเคส/แนบไฟล์ (ลดเวลาโหลดหน้าจอ, ใช้งานบน Laptop ได้รวดเร็วที่สุดโดยไม่ต้องกดสลับหน้า) **(Recommended)**
- 2) **Two-Screen Optimized Navigation** — คงหน้า `Home_incident` (ตาราง) และ `updateincident` (ฟอร์มปิดงาน) ไว้ 2 หน้าจอเหมือนเดิม แต่ปรับปรุง Layout และ Transition ให้เร็วขึ้น
- 3) **Modal Dialog Popup Architecture** — แสดงตารางเต็มจอ และเปิดฟอร์มแก้ไข/ปิดงานในรูปแบบ Popup Modal กึ่งกลางหน้าจอ
- 4) Other (โปรดระบุ): _______

**Answer**: 1) Single-Screen Master-Detail with Collapsible Side Drawer (ตารางด้านซ้าย และ Side Drawer ทางด้านขวาบนหน้าจอ Home_incident)

---

### D2-3: SharePoint Schema Deployment & Migration Sequence (ลำดับการตั้งค่า SharePoint)
**Question**: ขั้นตอนและลำดับในการเพิ่มคอลัมน์ใหม่ (`ResolutionSummary`, `ResolutionCategory`) และการทำ Indexed Columns บน SharePoint List `Cases` ควรทำในจังหวะใด?
- 1) **Schema First (ตั้งค่า SharePoint ก่อน)** — จัดทำขั้นตอนให้ผู้ใช้/แอดมินเข้าไปเพิ่ม 2 คอลัมน์และกด Index ใน SharePoint List Settings ให้เรียบร้อยก่อน แล้วจึงเริ่มพัฒนา Power Apps เพื่อให้ Connector ผูกข้อมูลได้สมบูรณ์ตั้งแต่รอบแรก **(Recommended)**
- 2) **Parallel Development with Fallback to StatusNote** — พัฒนาหน้าจอ Power Apps ไปพร้อมกัน โดยเขียนสูตรเผื่อไว้ให้บันทึกลง `StatusNote` ก่อน หากยังไม่พบคอลัมน์ใหม่
- 3) **Post-Implementation Configuration** — พัฒนาหน้าจอให้เสร็จก่อน แล้วค่อยแจ้งให้ผู้ใช้ไปเพิ่มคอลัมน์ใน SharePoint ภายหลัง
- 4) Other (โปรดระบุ): _______

**Answer**: 1) Schema First (ตั้งค่าคอลัมน์และ Index ใน SharePoint ให้เรียบร้อยก่อนพัฒนาแอป)

---

### D2-4: Development Sequence (ลำดับการส่งมอบงาน)
**Question**: ควรเริ่มพัฒนาและส่งมอบ Unit ใดก่อนเพื่อสร้างมูลค่าให้กับทีมงานได้เร็วที่สุด?
- 1) **Unit 1 (Dashboard & Delegable Filter) ก่อน** — เพื่อให้ทีมได้หน้าจอมอนิเตอร์ใหม่ที่สะอาด ปราศจาก Emoji และค้นหาข้อมูลเร็วไม่ติดเพดาน Delegation 2,000 แถวทันที แล้วจึงส่งมอบ Unit 2 (ระบบแนบหลักฐานปิดงาน) **(Recommended)**
- 2) **Unit 2 (Resolution & Evidence) ก่อน** — เน้นส่งมอบฟังก์ชันแนบไฟล์และปิดเคสก่อนเพราะเป็นกระบวนการใหม่ที่ยังไม่เคยมีในระบบ
- 3) **Deploy Both Units Simultaneously** — รวมส่งมอบพร้อมกันในเวอร์ชันเดียว
- 4) Other (โปรดระบุ): _______

**Answer**: 1) Unit 1 (Dashboard & Delegable Filter) ก่อน แล้วตามด้วย Unit 2 (Resolution & Evidence)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D2-1 Decomposition Strategy: 2 Domain-Based Units (Unit 1: Dashboard-Filter, Unit 2: Case-Resolution)
- D2-2 Canvas Screen Architecture: Single-Screen Master-Detail with Collapsible Side Drawer on Home_incident
- D2-3 SharePoint Schema Sequence: Schema First (Configure SharePoint columns and indexing before app development)
- D2-4 Development Sequence: Unit 1 (Dashboard & Filter) first, followed by Unit 2 (Resolution & Evidence)

---

**Instructions**: Fill in your answers above and respond with "units decisions complete" or confirm summary.
