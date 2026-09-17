# Context Assessment: Helpdesk Knowledge Base Management Portal (`helpdesk-kb-portal`)

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Type**: Brownfield (ต่อยอดโครงสร้าง Power Apps & SharePoint บนไซต์ `PowerAppPRD`)
- **Stack**: Microsoft Power Apps (Canvas App Desktop 16:9) / Power Fx / SharePoint Online / Power Automate / Copilot Studio
- **Architecture**: Low-Code Multi-Tier Enterprise Architecture with 4-Tier High Data Density Layout
- **Feature**: ระบบบริหารจัดการคลังความรู้ไอที (Helpdesk KB Portal) หน้าจอ Desktop Layout สำหรับจัดการคู่มือระบบ (อัปโหลด/สร้างโฟลเดอร์/คุมสถานะ) และข้อคำถาม-คำตอบ Q&A (เพิ่ม/ลด/แก้ไข/เปิด-ปิดการใช้งาน)
- **Impact**: New Admin Application (เพิ่มพอร์ทัลแอดมินใหม่ เชื่อมโยงกับ `SystemManuals`, `AI_KnowledgeBase`, `Systems` และ `KnowledgeGaps`)
- **Complexity**: Medium — ประมาณ 6-8 user stories, 2 functional areas, 2 user types
- **Recommendations**: Personas [Yes], Units [Yes], NFR [Yes]

---

## Project Overview
- **Feature Name**: `helpdesk-kb-portal`
- **Assessment Date**: 2026-09-17
- **Business Need**: เพื่อให้ HelpMe AI Agent ตอบคำถามพนักงานได้อย่างแม่นยำ 100% ปราศจากข้อมูลคลาดเคลื่อน ผู้ดูแลระบบ (IT Helpdesk และ Business Analyst) จำเป็นต้องมีระบบหน้าจอ Desktop Layout ที่ได้มาตรฐาน ใช้งานง่าย สวยงาม สำหรับ:
  1. การจัดการไฟล์คู่มือระบบใน Document Library `SystemManuals` (อัปโหลดไฟล์ PDF/DOCX, สร้างโฟลเดอร์แยกตามระบบใหม่, กำหนด Metadata และสถานะ Approved)
  2. การจัดการฐานข้อมูลข้อคำถาม-คำตอบใน SharePoint List `AI_KnowledgeBase` (เพิ่ม, แก้ไข, ลบ, ค้นหา, กรองตามระบบ, เปิด/ปิดสถานะ Active)
  3. การบริหารรายชื่อระบบมาตรฐานผ่าน Master List `Systems` เพื่อให้ข้อมูลชื่อระบบตรงกันทั้งองค์กร
  4. การนำข้อคำถามที่บอทตอบไม่ได้ (จาก List `KnowledgeGaps`) มาสร้างเป็นข้อคำถาม-คำตอบใหม่ได้ทันที

---

## Technology Stack & Environment
- **Platform**: Microsoft Power Platform / SharePoint Online
- **Client Frontend**: Microsoft Power Apps Canvas App (Desktop 16:9 Layout, 1366x768 ถึง 1920x1080)
- **Design System**: Modern Enterprise Design System (Deves Deep Navy `#012169`, Slate Gray, 4-Tier Container Auto-layout, ปราศจาก Emoji 100% ตามมาตรฐานองค์กร)
- **Data Layer (SharePoint Online Site `https://dvsins.sharepoint.com/sites/PowerAppPRD`)**:
  - `SystemManuals`: Document Library สำหรับจัดเก็บไฟล์คู่มือระบบ
  - `AI_KnowledgeBase`: SharePoint List (ID: `95e5e09d-6d20-4811-8833-820cef88fe98`) สำหรับข้อคำถาม-คำตอบ Q&A 74 รายการเดิมและรายการใหม่
  - `Systems`: Master SharePoint List (ID: `37a7b3db-d9ef-4cf8-b3f7-920f0ee3ee9a`) รายชื่อระบบ 31 ระบบ
  - `KnowledgeGaps`: SharePoint List (ID: `9beb45a0-08e2-4717-8eee-5b80bd218005`) สำหรับเก็บคำถามที่ AI ตอบไม่ได้
- **Integration Engine**: Power Automate Cloud Flows (สำหรับงานอัปโหลดไฟล์ข้าม Library, สร้างโฟลเดอร์ และ Trigger Force Sync)
- **Tooling & Packaging**: Power Platform CLI (`pac.exe`) สำหรับการ Build, Unpack และ Pack ซอร์สโค้ด YAML

---

## Codebase & Architectural Analysis
- **Existing Asset Alignment**:
  - ใน Workspace มีโปรเจกต์ [`Monitor_case_Helpdesk`](file:///e:/DVS/Project/Aiagent_Helpme/Monitor_case_Helpdesk) ซึ่งสร้างสถาปัตยกรรมหน้าจอ Desktop Layout 4 ระดับ (Header -> KPI Bar -> Filter Bar -> Workspace Split) ที่ได้มาตรฐาน พร้อม Server-Side Delegable Queries
  - ระบบใหม่สามารถใช้ Design Pattern และชุดสี Enterprise Theme เดียวกัน เพื่อให้ประสบการณ์ผู้ใช้ (UX) เป็นอันหนึ่งอันเดียวกัน
- **Data Source Relationships**:
  - คอลัมน์ `SystemName` ใน `SystemManuals` และ `System` ใน `AI_KnowledgeBase` ถูกกำหนดเป็น `Single line of text` ซึ่งอ้างอิงตรงกับฟิลด์ `Title` ใน Master List `Systems`
  - ในหน้าจอแอปพลิเคชัน จะสามารถผูก Dropdown เข้ากับ `Systems` ได้โดยตรง เพื่อให้แอดมินคลิกเลือกชื่อระบบได้ทันทีโดยไม่ต้องพิมพ์เอง ป้องกันข้อผิดพลาดจากการสะกดชื่อระบบผิด

---

## Feature Scope & Capabilities

### 1. Document Library Management (`SystemManuals`)
- **Folder Navigation & Creation**: แสดงโครงสร้างโฟลเดอร์แยกตามระบบงาน (DSS, Renewal_Motor, PCS, Polisy_400, CMI, General) พร้อมปุ่ม "+ สร้างโฟลเดอร์ระบบใหม่"
- **File Upload & Attachment**: อัปโหลดไฟล์คู่มือใหม่ (PDF, DOCX, XLSX, PPTX) พร้อมกำหนด Metadata:
  - `Title`: ชื่อทางการของคู่มือ
  - `SystemName`: เลือกระบบจาก Master List `Systems`
  - `DocType`: `User Manual`, `Admin Guide`, `SOP`, `FAQ Document`
  - `Status`: `Draft`, `Approved`, `Archived` (Default: `Approved`)
  - `Keywords`: คำค้นหาสำคัญสำหรับ AI
- **File Preview & Download**: ดูตัวอย่างเอกสารหรือเปิดลิงก์ไปยัง SharePoint ทันที
- **Delete / Archive**: ลบไฟล์หรือเปลี่ยนสถานะเป็น `Archived` เพื่อไม่ให้ AI นำไปตอบ

### 2. Q&A Knowledge Management (`AI_KnowledgeBase`)
- **Q&A Data Table (High Density)**: ตารางรายการคำถาม-คำตอบ ปรับแต่งความสูงแถว 44px แสดงสถานะ `Active`/`Inactive`, ชื่อระบบ, หมวดหมู่, หัวข้อคำถาม
- **Interactive Search & Filter**:
  - กล่องค้นหาคำถามหรือคำตอบแบบ Instant Filter
  - Dropdown กรองตามระบบ (`System`) และสถานะ (`Status`)
- **Side Drawer Editor (Quick Edit & Create)**:
  - Drawer สไลด์ด้านข้างสำหรับ เพิ่ม (`+ New Q&A`) หรือ แก้ไข รายการ Q&A
  - ฟิลด์: `Title`, `Question`, `Answer`, `System`, `Category`, `Keywords`, `Status`
  - ปุ่ม Quick Toggle: เปิด/ปิดการใช้งาน (`Active`/`Inactive`) ทันทีใน 1 คลิก
- **Delete with Confirmation**: ปุ่มลบคำถามพร้อมกล่องยืนยันป้องกันการลบผิดพลาด

### 3. Knowledge Gaps to Q&A Pipeline (AI Quality Loop)
- ดึงข้อมูลจาก List `KnowledgeGaps` ที่ HelpMe Agent บันทึกไว้เมื่อตอบคำถามไม่ได้
- แสดงรายการคำถามที่พนักงานถามบ่อยแต่ยังไม่มีคำตอบ
- ปุ่ม **"Convert to Q&A" (แปลงเป็นคำถาม-คำตอบ)**: คัดลอกคำถามไปยังแบบฟอร์มเพิ่ม Q&A ทันที เพื่อให้แอดมินพิมพ์คำตอบและอนุมัติเข้าสู่ระบบ ช่วยยกระดับความฉลาดของ AI อย่างต่อเนื่อง

### 4. Admin Tools & AI Sync Status
- ปุ่ม **"Check Index Status"**: แนะนำสถานะการ Sync ของ Copilot Studio
- ลิงก์ลัดไปยัง Copilot Studio Knowledge Portal สำหรับ Force Re-index

---

## Recommendations

**Complexity Indicators**:
- Story Count: Medium (6-8 user stories)
- Domain Boundaries: 2 โดเมนหลัก (Document Library Management, Q&A Management) + Gap-to-KB Integration
- User Types: 2 กลุ่ม (IT Helpdesk Admin, Business Analyst / Application Lead)
- Integration Points: SharePoint Online (3 Lists + 1 Library), Power Platform CLI, Copilot Studio

**Decision Gate Recommendations**:
- **Personas**: [Yes] — แนะนำสร้าง Personas เพื่อจำแนกบทบาทระหว่าง IT Helpdesk ผู้ดูแลไฟล์/Q&A รายวัน กับ BA ผู้อนุมัติ SOP
- **Units**: [Yes] — แนะนำแบ่งออกเป็น 2 Units:
  - Unit 1: `kb-manuals-module` (การบริหารจัดการคลังเอกสารและโฟลเดอร์)
  - Unit 2: `kb-qna-gap-module` (การบริหารจัดการ Q&A และกระบวนการแปลง Gap เป็นความรู้)
- **NFR**: [Yes] — Desktop 16:9 Layout responsiveness (1366x768 - 1920x1080), Delegable Querying, 100% No Emoji

---

## Next Steps
เข้าสู่ Phase 2: Requirements & Personas (สร้าง Decision Gate D1)
