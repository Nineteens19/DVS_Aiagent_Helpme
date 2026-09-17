# Architecture & Units Decisions (D2)

## Context Summary
- **Feature**: `helpdesk-kb-portal` (Helpdesk Knowledge Base Management Portal)
- **Scope**: 8 User Stories ครอบคลุม 5 ส่วนงาน (Desktop 16:9 4-Tier Shell, Manuals Library & Folder Manager, High-Density Q&A Grid with Quick Toggle, 1-Click Gap-to-KB Converter, Master Systems & RBAC)
- **Personas**: 3 บทบาท (สมชาย - IT Helpdesk Admin, กัญญา - BA / System Owner, นารี - General Employee)
- **Target Tech Stack**: Microsoft Power Apps (Canvas App Desktop 16:9 Layout) + SharePoint Online Connector + Power Automate Flow (สำหรับงาน File/Folder Operations)

---

## Decision Questions

### D2-1: Decomposition Strategy & Units Proposal
**Question**: ควรแบ่งหน่วยงานการพัฒนา (Units of Work) ของแอปพลิเคชันพอร์ทัลนี้ออกเป็นกี่หน่วยงานเพื่อความคล่องตัวในการสร้างและทดสอบ?
- 1) **2 Workstream Units (Module-Based Decomposition)**:
     - **Unit 1: `portal-shell-manuals`** (US-PORTAL-001, US-PORTAL-002, US-PORTAL-003, US-PORTAL-004, US-PORTAL-008):
       - พัฒนาโครงสร้างหน้าจอหลัก Desktop 16:9 (4-Tier Shell), แถบ Header, KPI Cards Bar, การตรวจจับสิทธิ์ผู้ใช้ (RBAC), และแท็บโมดูลจัดการคลังคู่มือระบบ (`SystemManuals`): โฟลเดอร์ระบบ, การสร้างโฟลเดอร์ใหม่, การอัปโหลดไฟล์พร้อม Metadata, และการควบคุมสถานะ Approved
     - **Unit 2: `portal-qna-gaps`** (US-PORTAL-005, US-PORTAL-006, US-PORTAL-007):
       - พัฒนาแท็บโมดูลจัดการข้อคำถาม-คำตอบ (`AI_KnowledgeBase`): ตาราง High-Density ความสูงแถว 44px, กล่องค้นหาทันใจ, สวิตช์ Quick Toggle สลับ Active/Inactive, Sliding Side Drawer สำหรับสร้าง/แก้ไข Q&A, และแท็บโมดูล 1-Click Gap-to-Q&A Converter เชื่อมโยงกับ `KnowledgeGaps` **(Recommended)**
     - *ข้อดี*: แยกขอบเขตงานอย่างชัดเจน Unit 1 ดูแลโครงสร้างหลักและไฟล์คู่มือ Unit 2 ดูแลข้อคำถามและการเรียนรู้ของ AI สามารถแยกทดสอบความสมบูรณ์ได้เป็นอิสระ
     - *ข้อเสีย*: ต้องเชื่อมโยงสไตล์การออกแบบให้ตรงกัน
- 2) **Single Monolithic Unit**: รวมทุกหน้าจอและฟังก์ชันเป็นก้อนเดียว พัฒนาพร้อมกันทั้งหมด
     - *ข้อดี*: ไม่ต้องแบ่งเอกสาร
     - *ข้อเสีย*: ติดตามความคืบหน้ายาก และตรวจสอบความถูกต้องแต่ละส่วนได้ช้า
- 3) Other (please specify): _______

**Answer**: 1) 2 Workstream Units (portal-shell-manuals และ portal-qna-gaps) (Recommended)

---

### D2-2: Execution Sequence & Dependency Strategy
**Question**: ลำดับขั้นตอนการพัฒนาและส่งมอบ (Execution Sequence) ควรเรียงลำดับอย่างไร?
- 1) **Sequential (Shell & Manuals Foundation First)**:
     - ดำเนินการ Unit 1 (`portal-shell-manuals`) ก่อน เพื่อสร้างโครงสร้าง Layout หลัก 4-Tier, การเชื่อมต่อ Master Systems, การ์ด KPI และการจัดการไฟล์คู่มือให้พร้อม จากนั้นจึงเริ่มพัฒนา Unit 2 (`portal-qna-gaps`) โดยนำแท็บ Q&A และ Side Drawer มาประกอบเข้ากับ Shell หลัก **(Recommended)**
     - *ข้อดี*: ปลอดภัยสูงสุด มีโครงสร้าง UI และตัวแปรสิทธิ์กลาง (User Role Context) พร้อมใช้งานก่อนเริ่มสร้างโมดูลที่สอง
     - *ข้อเสีย*: ต้องรอ Unit 1 เสร็จสมบูรณ์
- 2) **Parallel Workstreams**: พัฒนาทั้ง 2 หน่วยงานพร้อมกันในซอร์สโค้ดคนละส่วนแล้วนำมา Merge
     - *ข้อดี*: อาจดูรวดเร็ว
     - *ข้อเสีย*: เสี่ยงต่อการเกิดข้อขัดแย้งของตัวแปรส่วนกลาง (Global App Variables)
- 3) Other (please specify): _______

**Answer**: 1) Sequential (Shell & Manuals Foundation First) (Recommended)

---

### D2-3: Data Integration & Query Delegation Strategy
**Question**: การเชื่อมต่อและดึงข้อมูลระหว่าง Power Apps และ SharePoint Lists/Libraries ควรใช้สถาปัตยกรรมใด?
- 1) **Direct Native Delegable SharePoint Connector with Client-Side Collections**:
     - ใช้ฟังก์ชันมาตรฐานของ Power Fx (`Filter`, `SortByColumns`, `StartsWith`) เชื่อมต่อตรงกับ SharePoint Lists (`AI_KnowledgeBase`, `Systems`, `KnowledgeGaps`) แบบ Server-Side Delegable 100% ปราศจากข้อจำกัด 2,000 แถว
     - โหลดข้อมูล Master `Systems` เข้าสู่ Client Collection ตอน `App.OnStart` เพื่อให้การแสดงผล Dropdown ในฟอร์มต่างๆ ทำงานได้เร็วในเสี้ยววินาที (Zero Latency) **(Recommended)**
     - *ข้อดี*: เร็วที่สุด ตอบสนองทันที ไม่เปลืองโควต้าการรัน Power Automate Flow
     - *ข้อเสีย*: ต้องจัดโครงสร้างสูตร Query ให้ถูกกฎ Delegation อย่างเคร่งครัด
- 2) **Power Automate Flow-Mediated Queries**: ดึงข้อมูลทุกตารางผ่าน Flow ก่อนส่งกลับมาที่หน้าจอ
     - *ข้อดี*: เขียน Query ซับซ้อนใน Flow ได้
     - *ข้อเสีย*: ช้า มีความหน่วง 1-3 วินาทีทุกครั้งที่ค้นหาหรือเปลี่ยนหน้า
- 3) Other (please specify): _______

**Answer**: 1) Direct Native Delegable SharePoint Connector with Client-Side Collections (Recommended)

---

### D2-4: Folder Creation & Document Upload Technical Pattern
**Question**: วิธีการทางเทคนิคสำหรับการสร้างโฟลเดอร์ใหม่ใน Library `SystemManuals` และการอัปโหลดไฟล์คู่มือควรใช้รูปแบบใด?
- 1) **Lightweight Power Automate Instant Flow for Folder/File Creation + Native Form for Metadata**:
     - การสร้างโฟลเดอร์ระบบใหม่: เรียก Instant Cloud Flow สั้นๆ ผ่านปุ่มใน Power Apps เพื่อสร้างโฟลเดอร์บน SharePoint อย่างเสถียร
     - การอัปโหลดไฟล์คู่มือ: ใช้ฟอร์ม Attachments หรือ Flow อัปโหลดไฟล์ไบนารีพร้อมบันทึก Metadata (`SystemName`, `DocType`, `Status`) ครบถ้วน **(Recommended)**
     - *ข้อดี*: แก้ปัญหาข้อจำกัดของ Power Apps ที่ไม่สามารถสร้างโฟลเดอร์ใน Document Library ได้โดยตรงอย่างสมบูรณ์แบบ
     - *ข้อเสีย*: ต้องมี Cloud Flow ช่วยซัพพอร์ต 1 ตัว
- 2) **Direct SharePoint Modern Browser Link**: เมื่อคลิกสร้างโฟลเดอร์ ให้เปิดหน้าต่างใหม่ไปยัง SharePoint Site เพื่อให้ผู้ใช้กดสร้างโฟลเดอร์เอง
     - *ข้อดี*: ไม่ต้องทำ Flow
     - *ข้อเสีย*: ประสบการณ์ผู้ใช้สะดุด ต้องสลับหน้าต่างและอาจพิมพ์ชื่อโฟลเดอร์ไม่ตรงมาตรฐาน
- 3) Other (please specify): _______

**Answer**: 1) Lightweight Power Automate Instant Flow for Folder/File Creation + Native Form for Metadata (Recommended)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D2-1 Decomposition Strategy: 2 Workstream Units (portal-shell-manuals, portal-qna-gaps) (Recommended)
- D2-2 Execution Sequence: Sequential (Shell & Manuals first, then Q&A & Gaps) (Recommended)
- D2-3 Data Integration Strategy: Direct Native Delegable SharePoint Connector with Client-Side Collections (Recommended)
- D2-4 Folder & File Operations: Lightweight Power Automate Instant Flow for Folder/File Creation + Native Form for Metadata (Recommended)

---

**Instructions**: Fill in your answers above and respond with "units decisions complete" or "use recommendations"
