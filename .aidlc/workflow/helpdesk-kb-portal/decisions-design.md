# Design & Technology Decisions (D3)

## Context Summary
- **Feature**: `helpdesk-kb-portal` (ระบบ Helpdesk Knowledge Base Management Portal)
- **Scope**: 8 User Stories แบ่งเป็น 2 Units:
  - Unit 1: `portal-shell-manuals` (4-Tier Desktop 16:9 Shell, KPI Cards Bar, Folder Manager, File Upload & Status Governance, RBAC Guard)
  - Unit 2: `portal-qna-gaps` (High-Density Q&A Table, Quick Toggle, Sliding Side Drawer Editor, 1-Click Gap-to-Q&A Converter)
- **Data Stores**:
  - `SystemManuals` (SharePoint Document Library บน `PowerAppPRD`)
  - `AI_KnowledgeBase` (SharePoint List 74 รายการ บน `PowerAppPRD`)
  - `Systems` (Master List 31 รายชื่อระบบ บน `PowerAppPRD`)
  - `KnowledgeGaps` (SharePoint List คำถามที่ AI ตอบไม่ได้ บน `PowerAppPRD`)

---

## Decision Questions

### D3-1: Application Packaging & Screen Architecture
**Question**: ควรจัดโครงสร้างการแพ็กเกจของแอปพลิเคชัน Canvas App นี้อย่างไร?
- 1) **Standalone Dedicated Canvas App (`Helpdesk_KB_Portal`) in YAML**:
     - สร้างแอปพลิเคชันใหม่แยกอิสระใน Workspace ชื่อ `Helpdesk_KB_Portal` โดยใช้ซอร์สโค้ด YAML (`.pa.yaml`) ตามมาตรฐาน Power Platform CLI
     - มีหน้าจอหลัก `Home_KB.pa.yaml` ที่มี 4-Tier Container ครบทั้ง 3 แท็บโมดูล (คลังคู่มือ, Q&A, Knowledge Gaps)
     - คอมไพล์เป็นไฟล์ไบนารี `Helpdesk_KB_Portal.msapp` ผ่าน `pac canvas pack` พร้อมนำเข้า Maker Portal **(Recommended)**
     - *ข้อดี*: เป็นอิสระ ไม่กระทบกับแอป `Monitor_case_Helpdesk` เดิม มีสิทธิ์การเข้าถึงแยกกันอย่างปลอดภัย
     - *ข้อเสีย*: มีไฟล์แอปเพิ่มขึ้น 1 ตัว
- 2) **Embedded Sub-Screen in `Monitor_case_Helpdesk`**: เพิ่มหน้าจอใหม่เข้าไปในแอปพลิเคชัน Monitor เดิม
     - *ข้อดี*: รวมอยู่ในแอปเดียว
     - *ข้อเสีย*: ทำให้ขนาดไฟล์แอปเดิมใหญ่ขึ้น และพนักงานที่ต้องการเพียงแค่จัดการ KB ต้องโหลดหน้าจอเคสทั้งหมด
- 3) Other (please specify): _______

**Answer**: 1) Standalone Dedicated Canvas App (Helpdesk_KB_Portal) in YAML (Recommended)

---

### D3-2: Enterprise Theme, Color Tokens & Visual Ergonomics
**Question**: การกำหนดค่าชุดสี (Design Tokens) และองค์ประกอบทางสายตาสำหรับหน้าจอ Desktop Layout ควรใช้มาตรฐานใด?
- 1) **Deves Modern Enterprise Fluent Design (100% Emoji-Free)**:
     - โทนสีหลัก: **Deves Deep Navy** (`#012169`) สำหรับ Header Bar, Primary Actions และ Active Tabs
     - สีพื้นหลังและคอนเทนเนอร์: **Light Slate Gray** (`#F8FAFC`), ขอบเส้นแบ่ง (`#E2E8F0`), การ์ดสีขาวเงาบาง (`#FFFFFF`)
     - สีสถานะที่เป็นทางการ: `Approved / Active` = Forest Green (`#166534`), `Draft` = Amber (`#D97706`), `Archived / Inactive` = Slate (`#64748B`)
     - ตารางข้อมูล: ความสูงแถว **44px (Compact Desktop Density)** รองรับ 12-15 แถวต่อหน้าจอ Laptop
     - **ปราศจาก Emoji 100%**: ใช้เฉพาะ Fluent Icon และข้อความทางการ **(Recommended)**
     - *ข้อดี*: สวยงาม ทันสมัย ดูเป็นมืออาชีพระดับองค์กร และสอดคล้องกับมาตรฐานของบริษัท 100%
     - *ข้อเสีย*: ต้องกำหนดค่าสีใน YAML อย่างเป็นระเบียบ
- 2) **Default Standard Canvas App Palette**: ใช้สีฟ้าและเทามาตรฐานของ Power Apps ทั่วไป
     - *ข้อดี*: รวดเร็ว
     - *ข้อเสีย*: หน้าตาดูพื้นฐาน ไม่มีความโดดเด่นและไม่สะท้อนแบรนด์องค์กร
- 3) Other (please specify): _______

**Answer**: 1) Deves Modern Enterprise Fluent Design (100% Emoji-Free) (Recommended)

---

### D3-3: Delegable Power Fx Query & Instant Search Architecture
**Question**: สูตรการค้นหาและกรองข้อมูลในตาราง Q&A และคลังคู่มือควรเขียนอย่างไรเพื่อป้องกัน Delegation Warning และตอบสนองเร็ว?
- 1) **Exact-Prefix Delegable Formula with Multi-Condition Nesting**:
     - ใช้สูตร Delegable 100%:
       ```powerfx
       SortByColumns(
           Filter(
               AI_KnowledgeBase,
               (IsBlank(cmb_SystemFilter.Selected.Value) || System = cmb_SystemFilter.Selected.Value) &&
               (varStatusFilter = "All" || Status.Value = varStatusFilter) &&
               (IsBlank(txt_Search.Text) || StartsWith(Title, txt_Search.Text))
           ),
           "Created",
           SortOrder.Descending
       )
       ```
     - กำหนด Indexed Column บน SharePoint สำหรับฟิลด์ `System`, `Status`, `Title`
     - ตอบสนองเร็วทันทีในระดับมิลลิวินาที (Zero Client Latency) **(Recommended)**
     - *ข้อดี*: รองรับข้อมูลเกิน 2,000 แถวในอนาคตได้อย่างปลอดภัย ไร้แถบคำเตือน Delegation Warning 100%
     - *ข้อเสีย*: ต้องใช้ `StartsWith` แทน `in` สำหรับการค้นหาข้อความ
- 2) **Client-Side Cache (ClearCollect) on App.OnStart**: ดึงข้อมูลทั้งหมด 2,000 แถวมาเก็บใน Collection แล้วค้นหาด้วยคำสั่ง `in`
     - *ข้อดี*: ค้นหาคำที่อยู่กลางประโยคได้
     - *ข้อเสีย*: ไม่รองรับข้อมูลที่เกิน 2,000 แถว และข้อมูลจะไม่สดใหม่หากมีแอดมินคนอื่นแก้ไขใน SharePoint
- 3) Other (please specify): _______

**Answer**: 1) Exact-Prefix Delegable Formula with Multi-Condition Nesting (Recommended)

---

### D3-4: Sliding Side Drawer & State Management Architecture
**Question**: การบริหารจัดการสถานะ (State Management) ของ Sliding Side Drawer สำหรับการเพิ่ม/แก้ไข Q&A ควรใช้รูปแบบใด?
- 1) **Contextual Mode Variable with Form Binding & Strict Reset**:
     - ใช้ตัวแปร Local Context:
       - `varShowDrawer` (Boolean): ควบคุมการเปิด/ปิด Drawer
       - `varDrawerMode` ("New" | "Edit" | "GapToQnA"): ควบคุมโหมดของฟอร์ม
       - `varSelectedQnA` (Record): เก็บข้อมูลเรคอร์ดที่กำลังแก้ไข
     - เมื่อเปิดโหมด `GapToQnA` ระบบจะส่งค่า `Title: varSelectedGap.UserQuery` และ `System: varSelectedGap.System` เข้าฟอร์มอัตโนมัติ
     - เมื่อกดบันทึกหรือปิด Drawer ระบบจะสั่ง `ResetForm` และเคลียร์ตัวแปรอย่างหมดจด ป้องกันข้อมูลค้าง **(Recommended)**
     - *ข้อดี*: เสถียรสูง โค้ดอ่านเข้าใจง่าย ไม่เกิดบั๊กข้อมูลข้ามโหมด
     - *ข้อเสีย*: ต้องควบคุมตัวแปรในหลายปุ่ม
- 2) **Separate Screens for New and Edit**: แยกหน้าจอเพิ่มและหน้าจอแก้ไขออกจากกัน
     - *ข้อดี*: แยกฟอร์มชัดเจน
     - *ข้อเสีย*: เสียเวลาสลับหน้าจอ และไม่เป็นไปตามแนวทาง Desktop Side Drawer
- 3) Other (please specify): _______

**Answer**: 1) Contextual Mode Variable with Form Binding & Strict Reset (Recommended)

---

### D3-5: Folder Creation & File Attachment Technical Pattern
**Question**: สถาปัตยกรรมทางเทคนิคสำหรับการสร้างโฟลเดอร์ใน `SystemManuals` และการอัปโหลดไฟล์คู่มือควรใช้กลไกใด?
- 1) **Power Automate Cloud Flow Trigger via Power Fx `Run()` + SharePoint Modern Link for Large Files**:
     - **สร้างโฟลเดอร์ระบบใหม่**: ปุ่มในแอปพลิเคชันเรียก Cloud Flow สั้นๆ `KB_CreateFolder.Run(txt_NewFolderName.Text)` ซึ่งจะไปสร้างโฟลเดอร์ใน `SystemManuals` และตอบกลับผลลัพธ์ทันที
     - **การอัปโหลดคู่มือ**: รองรับการอัปโหลดผ่านฟอร์มแนบไฟล์ หรือมีปุ่ม `เปิดโฟลเดอร์ใน SharePoint` เพื่อให้แอดมินลากไฟล์ขนาดใหญ่ (Drag & Drop) เข้าโฟลเดอร์โดยตรงได้อย่างสะดวกรวดเร็ว **(Recommended)**
     - *ข้อดี*: ผสานความสะดวกรวดเร็วของ Desktop UI เข้ากับความสามารถลากไฟล์ขนาดใหญ่ของ SharePoint โดยตรง
     - *ข้อเสีย*: ต้องเชื่อมโยง Flow 1 ตัว
- 2) **Pure Base64 String Upload via Flow**: แปลงไฟล์ทั้งหมดเป็น Base64 ใน Power Apps แล้วส่งให้ Flow แตกเป็นไฟล์
     - *ข้อดี*: ไม่ต้องเปิด SharePoint
     - *ข้อเสีย*: ช้ามาก และล้มเหลวบ่อยครั้งหากไฟล์มีขนาดใหญ่เกิน 10MB
- 3) Other (please specify): _______

**Answer**: 1) Power Automate Cloud Flow Trigger via Power Fx Run() + SharePoint Modern Link for Large Files (Recommended)

---

### D3-6: Correctness & Verification Testing Strategy (Mandatory)
**Question**: แนวทางการทดสอบความถูกต้องและคุณภาพของระบบ (Verification Strategy) ควรครอบคลุมสิ่งใดบ้าง?
- 1) **Full Multi-Viewport Desktop Benchmark & Complete Data Operations Test**:
     - ทดสอบการแสดงผลบน Viewport Laptop 16:9 (1366x768) และ Full HD (1920x1080) ยืนยันว่า Auto-layout ไม่ล้นจอ
     - ทดสอบ CRUD ครบทุกมิติ: สร้างโฟลเดอร์, อัปโหลดคู่มือ, ค้นหา Q&A จาก 74 รายการ, สลับสถานะ Quick Toggle, แก้ไข Q&A, และทดสอบปุ่ม 1-Click แปลง Gap เป็น Q&A
     - ตรวจสอบความถูกต้องว่า AI Copilot Studio สามารถค้นพบข้อมูลที่เพิ่งเพิ่ม/แก้ไขได้
     - ตรวจสอบสูตรว่าไม่มี Delegation Warning แม้แต่จุดเดียว (100% Clean) **(Recommended)**
     - *ข้อดี*: การันตีคุณภาพของระบบทั้งด้าน UX/UI, ความเสถียรของข้อมูล, และความพร้อมของ AI
     - *ข้อเสีย*: ต้องใช้เวลาในการทดสอบทุกฟังก์ชัน
- 2) **Basic Smoke Test Only**: ตรวจสอบแค่เปิดแอปติดและแสดงตารางได้
     - *ข้อดี*: รวดเร็ว
     - *ข้อเสีย*: อาจพบปัญหาการตัดคำหรือข้อผิดพลาดเรื่องสิทธิ์ในภายหลัง
- 3) Other (please specify): _______

**Answer**: 1) Full Multi-Viewport Desktop Benchmark & Complete Data Operations Test (Recommended)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D3-1 Application Packaging: Standalone Dedicated Canvas App (Helpdesk_KB_Portal) in YAML (Recommended)
- D3-2 Enterprise Theme: Deves Modern Enterprise Fluent Design (100% Emoji-Free) (Recommended)
- D3-3 Delegable Query Strategy: Exact-Prefix Delegable Formula with Multi-Condition Nesting (Recommended)
- D3-4 Drawer State Management: Contextual Mode Variable with Form Binding & Strict Reset (Recommended)
- D3-5 Folder & Upload Pattern: Power Automate Flow Trigger + SharePoint Modern Link for Large Files (Recommended)
- D3-6 Verification Strategy: Full Multi-Viewport Desktop Benchmark & Complete Data Operations Test (Recommended)

---

**Instructions**: Fill in your answers above and respond with "design decisions complete" or "use recommendations"
