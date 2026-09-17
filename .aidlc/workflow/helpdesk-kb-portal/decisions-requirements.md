# Requirements Scope Decisions (D1)

## Context Summary
- **Feature**: `helpdesk-kb-portal` (ระบบบริหารจัดการคลังความรู้ไอที - Desktop Layout)
- **Problem Space**: พนักงานต้องการคำตอบจาก HelpMe AI Agent ที่แม่นยำ 100% แต่ปัจจุบันการดูแลไฟล์คู่มือใน `SystemManuals` และข้อคำถามใน `AI_KnowledgeBase` ต้องทำผ่าน SharePoint Modern View ซึ่งขาดเครื่องมือเฉพาะทาง การจัดโฟลเดอร์ตามระบบใหม่ทำได้ช้า และการจัดการ Q&A ไม่กระชับ
- **Target Platform**: Microsoft Power Apps Canvas App (Desktop 16:9 High Data Density Layout, 1366x768 - 1920x1080)
- **Connected Assets**:
  - `SystemManuals` (Document Library บน `PowerAppPRD`)
  - `AI_KnowledgeBase` (SharePoint List 74 รายการ บน `PowerAppPRD`)
  - `Systems` (Master List 31 ระบบ บน `PowerAppPRD`)
  - `KnowledgeGaps` (List บันทึกคำถามที่บอทตอบไม่ได้)

---

## Decision Questions

### D1-1: Target Personas & Role Division (Mandatory)
**Question**: ควรแบ่งบทบาทผู้ใช้งาน (User Roles) ภายในระบบพอร์ทัลนี้อย่างไร?
- 1) **Differentiated Roles (Helpdesk Operator & BA Knowledge Champion)**:
     - **สมชาย (IT Helpdesk Admin)**: อัปโหลดคู่มือระบบ, จัดการโฟลเดอร์, เพิ่ม/แก้ไข Q&A รายวัน, สลับสถานะ Active/Inactive, แปลงคำถามจาก Knowledge Gaps
     - **กัญญา (Business Analyst / System Owner)**: ตรวจสอบความถูกต้องของคู่มือ SOP, อนุมัติสถานะ `Approved`, กำหนดมาตรฐานชื่อระบบใน Master `Systems` **(Recommended)**
     - *ข้อดี*: ชัดเจนตามสายงานจริงในองค์กร ช่วยควบคุมคุณภาพ (Quality Governance) ของเนื้อหาก่อน AI นำไปตอบ
     - *ข้อเสีย*: ต้องออกแบบการแสดงผลหรือปุ่มตามระดับสิทธิ์
- 2) **Single Unified Admin Persona**: รวมสิทธิ์แอดมินเป็นบทบาทเดียว ทุกคนที่เข้าแอปทำได้ทุกฟังก์ชัน
     - *ข้อดี*: ง่าย ไม่ต้องเขียนสูตรตรวจสอบสิทธิ์
     - *ข้อเสีย*: เสี่ยงต่อการที่เจ้าหน้าที่ระดับปฏิบัติการแก้ไขหรือลบเอกสาร SOP สำคัญโดยไม่ผ่านการอนุมัติ
- 3) Other (please specify): _______

**Answer**: 1) Differentiated Roles (Helpdesk Operator & BA Knowledge Champion) (Recommended)

---

### D1-2: Desktop Layout & Navigation Architecture
**Question**: รูปแบบการจัดหน้าจอ Desktop Layout 16:9 สำหรับการบริหารคลังความรู้ควรจัดวางโครงสร้างการนำทาง (Navigation Structure) อย่างไร?
- 1) **Single-Screen Tabbed Navigation with Sliding Side Drawer (4-Tier Layout)**:
     - ใช้สถาปัตยกรรมแบบเดียวกับ `Monitor_case_Helpdesk`:
       - **Tier 1**: Header Bar (โลโก้, ชื่อระบบ, สลับแท็บโมดูล, ข้อมูลผู้ใช้)
       - **Tier 2**: KPI Stat Cards (จำนวนคู่มือทั้งหมด, จำนวน Q&A Active/Inactive, จำนวน Gap ที่รอแปลง)
       - **Tier 3**: Filter & Action Bar (กล่องค้นหาแบบพิมพ์ทันที, Dropdown เลือกระบบ, ปุ่ม `+ เพิ่มข้อมูล`)
       - **Tier 4**: Split Workspace (ตารางข้อมูลแถวกระชับ 44px ทางซ้าย + Sliding Side Drawer ทางขวาสำหรับดู/แก้ไข/อัปโหลด)
     - แบ่งเป็น 3 แท็บหลัก:
       - แท็บ 1: **คลังคู่มือระบบ (System Manuals)**
       - แท็บ 2: **ฐานข้อมูล Q&A (Knowledge Base)**
       - แท็บ 3: **คำถามที่ AI ตอบไม่ได้ (Knowledge Gaps & Learning Loop)** **(Recommended)**
     - *ข้อดี*: ทำงานได้ครบจบในหน้าเดียว ไม่ต้องสลับหน้าจอ (No Screen Switch Latency), ใช้ประโยชน์จากหน้าจอ Laptop 16:9 ได้คุ้มค่าที่สุด
     - *ข้อเสีย*: โครงสร้าง Container ในหน้าเดียวมีความซับซ้อน
- 2) **Multi-Screen Wizard**: แยกหน้าจอการจัดการคู่มือ, หน้าจอ Q&A, และหน้าจอดู Gap ออกเป็นคนละหน้า
     - *ข้อดี*: แต่ละหน้าจอโค้ดไม่ซับซ้อน
     - *ข้อเสีย*: ผู้ใช้ต้องกด Navigate ข้ามไปมา เสียเวลาในการสลับทำงาน
- 3) Other (please specify): _______

**Answer**: 1) Single-Screen Tabbed Navigation with Sliding Side Drawer (4-Tier Layout) (Recommended)

---

### D1-3: Document Library Manager Scope & Operations
**Question**: ฟังก์ชันในการบริหารจัดการคลังคู่มือระบบ (`SystemManuals`) ควรครอบคลุมความสามารถใดบ้าง?
- 1) **Full File Lifecycle with Folder System & System Binding**:
     - แสดงรายการโฟลเดอร์แยกตามระบบงาน (DSS, Renewal_Motor, PCS, Polisy_400, CMI, General)
     - ปุ่ม **"+ สร้างโฟลเดอร์ระบบใหม่"**: ให้สร้างโฟลเดอร์ใหม่เพื่อจัดกลุ่มเอกสารระบบใหม่ได้ทันที
     - การอัปโหลดไฟล์คู่มือ (PDF, Word, Excel, PPTX) พร้อมฟอร์มระบุ Metadata:
       - ชื่อเอกสาร (`Title`)
       - ระบบงาน (`SystemName`): ดึง Dropdown จาก Master `Systems`
       - ประเภท (`DocType`): User Manual, SOP, FAQ
       - สถานะ (`Status`): Draft, Approved, Archived
       - คำสำคัญ (`Keywords`): สำหรับช่วย AI Search
     - ปุ่มเปิดดูไฟล์ตัวเต็ม (Direct SharePoint Viewer) และปุ่มเปลี่ยนสถานะเป็น Archived เพื่อหยุดให้ AI นำไปตอบ **(Recommended)**
     - *ข้อดี*: ครบถ้วนทุกมิติ ตอบโจทย์การทำงานของ IT Helpdesk และทำให้ AI ค้นหาเอกสารได้แม่นยำ 100%
     - *ข้อเสีย*: ต้องเชื่อมต่อ Flow หรือ Connector สำหรับการสร้างโฟลเดอร์
- 2) **Flat File List Only**: แสดงรายการไฟล์ทั้งหมดแบบไม่มีโฟลเดอร์ และรองรับแค่อัปโหลด
     - *ข้อดี*: สร้างง่าย
     - *ข้อเสีย*: เมื่อมีไฟล์คู่มือมากกว่า 50 ไฟล์ จะค้นหาและจัดหมวดหมู่ยากมาก
- 3) Other (please specify): _______

**Answer**: 1) Full File Lifecycle with Folder System & System Binding (Recommended)

---

### D1-4: Q&A Management & In-Line Editing UX
**Question**: ประสบการณ์การใช้งาน (UX) ในการจัดการข้อคำถาม-คำตอบ (74 รายการเดิม และรายการใหม่) ควรออกแบบอย่างไร?
- 1) **High-Density Table with Quick Toggle & Slide Drawer Form**:
     - ตารางแสดงรายการ Q&A ความสูงแถว 44px แสดงรหัส, ระบบ, หมวดหมู่, คำถามหลัก, และสถานะ
     - **Quick Active/Inactive Toggle**: สวิตช์เปิด/ปิดการใช้งาน Q&A ในแถวตารางได้ทันที (คลิกเดียวสถานะเปลี่ยน โดยไม่ต้องเปิดฟอร์มเต็ม)
     - **Instant Delegable Filter**: พิมพ์ค้นหาคำถามหรือคำตอบ และกรองตามระบบ (`System`) ได้แบบ Server-Side
     - **Side Drawer Editor**: เมื่อกดเลือกแถว หรือกด `+ New Q&A` จะสไลด์หน้าต่างด้านข้างออกมาให้พิมพ์แก้ไข/เพิ่มข้อคำถาม คำตอบ และคีย์เวิร์ดได้อย่างสะดวก **(Recommended)**
     - *ข้อดี*: ทำงานได้รวดเร็วมาก ปรับปรุงหรือระงับคำถามที่ล้าสมัยได้ในเสี้ยววินาที
     - *ข้อเสีย*: ต้องจัดการตัวแปรสถานะฟอร์มใน Side Drawer อย่างรอบคอบ
- 2) **Standard Full-Screen Form**: เมื่อจะแก้ไขหรือเพิ่ม ให้เปิดเป็นหน้าฟอร์มเต็มจอ
     - *ข้อดี*: พื้นที่ฟอร์มกว้าง
     - *ข้อเสีย*: เสียเวลาสลับหน้าจอ และไม่สามารถดูตารางเปรียบเทียบคำถามข้างเคียงได้
- 3) Other (please specify): _______

**Answer**: 1) High-Density Table with Quick Toggle & Slide Drawer Form (Recommended)

---

### D1-5: Knowledge Gaps to Q&A Conversion Pipeline
**Question**: การจัดการข้อคำถามที่บอทตอบไม่ได้ (จาก List `KnowledgeGaps`) เพื่อนำมาเติมเต็มความรู้ให้ AI ควรมีกระบวนการอย่างไร?
- 1) **1-Click Gap-to-Q&A Converter**:
     - แสดงตารางรายการคำถามที่บอทตอบไม่ได้ เรียงตามจำนวนครั้งที่ถูกถามบ่อย
     - มีปุ่ม **"แปลงเป็นคำถาม-คำตอบ (Create Q&A)"**:
       - เมื่อคลิก ระบบจะเปิด Side Drawer เพิ่ม Q&A ให้อัตโนมัติ พร้อมคัดลอกข้อความคำถาม และชื่อระบบลงในฟอร์มให้ทันที
       - แอดมินเพียงพิมพ์ "คำตอบที่ถูกต้อง" เพิ่มเติม แล้วกดบันทึก
       - ระบบจะบันทึก Q&A เข้าสู่ `AI_KnowledgeBase` และอัปเดตสถานะของ Knowledge Gap นั้นเป็น `Resolved` โดยอัตโนมัติ **(Recommended)**
     - *ข้อดี*: ปิด Loop การเรียนรู้ของ AI (Continuous Learning) ได้อย่างสมบูรณ์แบบ แอดมินทำงานสะดวกมาก
     - *ข้อเสีย*: ต้องเชื่อมโยงความสัมพันธ์ระหว่าง 2 SharePoint Lists
- 2) **Manual Reference Only**: แสดงรายการ Gap ไว้ดูเป็นข้อมูลอ้างอิง แล้วให้แอดมินไปเปิดแท็บ Q&A พิมพ์เอง
     - *ข้อดี*: ไม่ต้องเขียนฟังก์ชันส่งต่อข้อมูล
     - *ข้อเสีย*: แอดมินต้องสลับหน้าและพิมพ์ซ้ำซ้อน
- 3) Other (please specify): _______

**Answer**: 1) 1-Click Gap-to-Q&A Converter (Recommended)

---

### D1-6: Security & Role-Based Access Control (RBAC)
**Question**: การควบคุมสิทธิ์การเข้าใช้งานภายในแอปพลิเคชันควรใช้เกณฑ์ใด?
- 1) **Role-Based Permission Trim with Read-only Fallback**:
     - ตรวจสอบอีเมลของผู้ใช้หรือกลุ่ม M365 Group (เช่น IT Helpdesk & BA Team):
       - ผู้ดูแลระบบ (Admins): มีสิทธิ์ อัปโหลด, สร้างโฟลเดอร์, เพิ่ม/แก้ไข/ลบ Q&A, และเปิด/ปิดสถานะ
       - พนักงานทั่วไป (หากเข้าแอป): สามารถค้นหาและอ่านคู่มือ/คำตอบได้อย่างเดียว (ปุ่มเพิ่ม/แก้ไข/ลบ จะถูกซ่อนหรือ Disable) **(Recommended)**
     - *ข้อดี*: ปลอดภัย ป้องกันข้อมูลคลังความรู้ถูกแก้ไขโดยผู้ไม่มีหน้าที่เกี่ยวข้อง
     - *ข้อเสีย*: ต้องมีตารางหรือกลุ่มระบุรายชื่อแอดมิน
- 2) **Open Internal Access**: พนักงานทุกคนในองค์กรที่เปิดแอปมีสิทธิ์แก้ไขได้ทั้งหมด
     - *ข้อดี*: ไม่ต้องตั้งค่าสิทธิ์
     - *ข้อเสีย*: ไม่ปลอดภัยอย่างยิ่งสำหรับระบบงานองค์กร
- 3) Other (please specify): _______

**Answer**: 1) Role-Based Permission Trim with Read-only Fallback (Recommended)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D1-1 Target Personas: Differentiated Roles (Helpdesk Operator & BA Knowledge Champion) (Recommended)
- D1-2 Desktop Layout: Single-Screen Tabbed Navigation with Sliding Side Drawer (4-Tier Layout) (Recommended)
- D1-3 Document Library Scope: Full File Lifecycle with Folder System & System Binding (Recommended)
- D1-4 Q&A Management UX: High-Density Table with Quick Toggle & Slide Drawer Form (Recommended)
- D1-5 Gap-to-KB Pipeline: 1-Click Gap-to-Q&A Converter (Recommended)
- D1-6 Security & RBAC: Role-Based Permission Trim with Read-only Fallback (Recommended)

---

**Instructions**: Fill in your answers above and respond with "requirements decisions complete" or "use recommendations"
