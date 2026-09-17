# Requirements Specification: Helpdesk Knowledge Base Management Portal

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Total Stories**: 8 user stories across 5 functional areas
- **Priority**: 8 High, 0 Medium, 0 Low
- **User Types**: IT Helpdesk Admin (สมชาย), Business Analyst / System Owner (กัญญา), General Employee (นารี)
- **Key Entities**: `ManualDocument` (SystemManuals), `QnAEntry` (AI_KnowledgeBase), `KnowledgeGap` (KnowledgeGaps), `MasterSystem` (Systems)
- **Integrations**: SharePoint Online OData Connector, Power Automate Cloud Flows, Copilot Studio Knowledge Index
- **Core Flows**: 1) อัปโหลดคู่มือและกำหนดสถานะ Approved 2) จัดการและสลับสถานะ Q&A ในคลิกเดียว 3) แปลงคำถามที่ AI ตอบไม่ได้เป็น Q&A ในคลิกเดียว 4) บริหาร Master Systems

---

## Functional Area 1: Desktop Shell & KPI Overview

### US-PORTAL-001: 4-Tier Desktop 16:9 Shell & Module Tab Navigation
**As an** IT Helpdesk Admin หรือ Business Analyst  
**I want** หน้าจอแอปพลิเคชันรูปแบบมาตรฐาน Desktop Layout 16:9 ที่มีแถบนำทาง 3 แท็บหลัก (คลังคู่มือระบบ, ฐานข้อมูล Q&A, และคำถามที่ AI ตอบไม่ได้)  
**So that** สามารถสลับการทำงานระหว่างการจัดการเอกสารและข้อคำถามได้อย่างรวดเร็วในหน้าจอเดียวโดยไม่ต้องสลับหน้าจอ (No Screen Switch Latency)

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้เปิดแอปพลิเคชันบนหน้าจอคอมพิวเตอร์ Desktop/Laptop (ความละเอียด 1366x768 ถึง 1920x1080), **THEN** ระบบต้องแสดงผลหน้าจอแบบ 4-Tier Auto-layout เต็มความกว้าง ปราศจากแถบเลื่อนแนวนอน (Horizontal Scrollbar)
2. **WHEN** ผู้ใช้คลิกเลือกแท็บโมดูลบนแถบ Header Bar, **THEN** ระบบต้องสลับการแสดงผลระหว่าง 3 แท็บหลักได้ทันที:
   - แท็บที่ 1: `คลังคู่มือระบบ (System Manuals)`
   - แท็บที่ 2: `ฐานข้อมูลคำถาม-คำตอบ (Q&A Knowledge Base)`
   - แท็บที่ 3: `คำถามที่ AI ตอบไม่ได้ (Knowledge Gaps & Learning Loop)`
3. **WHILE** มีการสลับแท็บโมดูล, **THEN** แถบ Header, ข้อมูลผู้ใช้, และสถานะการเชื่อมต่อต้องคงอยู่คงที่และตอบสนองภายใน 0.2 วินาที

**Dependencies**: None

---

### US-PORTAL-002: Real-Time Knowledge Base KPI Metrics Bar
**As a** Business Analyst หรือ IT Helpdesk Admin  
**I want** แถบสรุปตัวชี้วัดความพร้อมของคลังความรู้ (KPI Summary Cards) ใน Tier 2  
**So that** สามารถมองเห็นภาพรวมของจำนวนคู่มือ, จำนวน Q&A ที่เปิดใช้งาน, และคำถามที่รอการเติมเต็มได้ในทันที

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** เข้าสู่แอปพลิเคชันหรือกดปุ่มรีเฟรชข้อมูล, **THEN** ระบบต้องคำนวณและแสดงผลการ์ด KPI 5 ใบอย่างถูกต้อง:
   - การ์ดที่ 1: `คู่มือทั้งหมด (Total Manuals)`
   - การ์ดที่ 2: `คู่มือที่อนุมัติแล้ว (Approved Manuals)`
   - การ์ดที่ 3: `Q&A ทั้งหมด (Total Q&A)`
   - การ์ดที่ 4: `Q&A ที่พร้อมใช้งาน (Active Q&A)`
   - การ์ดที่ 5: `คำถามที่รอเพิ่มคำตอบ (Pending Gaps)`
2. **WHEN** ผู้ใช้คลิกที่การ์ด KPI ใดๆ, **THEN** ระบบต้องกรองข้อมูลในตารางหลักด้านล่างให้ตรงกับเงื่อนไขของการ์ดนั้นโดยอัตโนมัติ (Quick Filter)

**Dependencies**: US-PORTAL-001

---

## Functional Area 2: Document Library Management (`SystemManuals`)

### US-PORTAL-003: System Folder Tree & New Folder Creation
**As an** IT Helpdesk Admin  
**I want** เรียกดูโครงสร้างโฟลเดอร์แยกตามระบบงาน และสามารถกดปุ่มสร้างโฟลเดอร์สำหรับระบบงานใหม่ได้  
**So that** ไฟล์คู่มือระบบถูกจัดเก็บอย่างเป็นระเบียบตามระบบงาน ไม่ปะปนกัน

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** เข้าสู่แท็บ "คลังคู่มือระบบ", **THEN** ระบบต้องแสดงรายการโฟลเดอร์ระบบงาน (เช่น `DSS`, `Renewal_Motor`, `PCS`, `Polisy_400`, `CMI`, `General`) พร้อมจำนวนไฟล์ในแต่ละโฟลเดอร์
2. **WHEN** ผู้ใช้คลิกปุ่ม `+ สร้างโฟลเดอร์ระบบใหม่`, **THEN** ระบบต้องแสดงกล่องข้อความให้ระบุชื่อระบบ (โดยมี Dropdown แนะนำจาก Master List `Systems`)
3. **WHEN** ผู้ใช้ยืนยันการสร้างโฟลเดอร์, **IF** ชื่อโฟลเดอร์ไม่ซ้ำกับที่มีอยู่เดิม, **THEN** ระบบต้องสร้างโฟลเดอร์ใหม่ใน `SystemManuals` บน SharePoint และรีเฟรชรายการโฟลเดอร์ทันที, **ELSE** แจ้งเตือนข้อผิดพลาดว่าโฟลเดอร์ชื่อนี้มีอยู่แล้ว

**Dependencies**: US-PORTAL-001

---

### US-PORTAL-004: Manual File Upload, Metadata Tagging & Status Governance
**As an** IT Helpdesk Admin หรือ Business Analyst  
**I want** อัปโหลดไฟล์คู่มือใหม่ พร้อมระบุชื่อระบบ, ประเภทเอกสาร, คำสำคัญ, และควบคุมสถานะความถูกต้อง (Approved/Draft/Archived)  
**So that** AI สามารถดึงเฉพาะเอกสารคู่มือที่ผ่านการรับรองแล้วไปใช้ตอบผู้ใช้งานได้อย่างแม่นยำ

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้คลิกปุ่ม `+ อัปโหลดคู่มือใหม่`, **THEN** ระบบต้องเปิดแบบฟอร์มให้เลือกไฟล์ (PDF, Word, Excel, PPTX ขนาดไม่เกิน 50MB) และกรอก Metadata:
   - `Title`: ชื่อทางการของเอกสาร (บังคับ)
   - `SystemName`: เลือกจาก Dropdown ของ Master List `Systems` (บังคับ)
   - `DocType`: ตัวเลือก `User Manual`, `Admin Guide`, `SOP`, `FAQ Document`
   - `Status`: ตัวเลือก `Draft`, `Approved`, `Archived` (Default: `Approved`)
   - `Keywords`: คำค้นหาหรือคำพ้องความหมาย
2. **WHEN** บันทึกการอัปโหลดสำเร็จ, **THEN** ไฟล์ต้องถูกบันทึกลงใน Document Library `SystemManuals` พร้อม Metadata ครบถ้วน และแสดงในรายการไฟล์ทันที
3. **WHEN** ผู้ใช้คลิกที่รายการไฟล์คู่มือ, **THEN** มีปุ่ม `เปิดดูเอกสาร (View File)` เพื่อเปิดไฟล์ฉบับเต็มผ่าน SharePoint Web Viewer และมีปุ่ม `เปลี่ยนสถานะเป็น Archived` เพื่อระงับไม่ให้ AI นำไปใช้

**Dependencies**: US-PORTAL-003

---

## Functional Area 3: Q&A Knowledge Base Management (`AI_KnowledgeBase`)

### US-PORTAL-005: High-Density Q&A Grid, Instant Delegable Search & Quick Active Toggle
**As an** IT Helpdesk Admin  
**I want** ตารางแสดงรายการ Q&A ความสูงแถว 44px ที่มีกล่องค้นหาทันใจ และมีสวิตช์เปิด/ปิดการใช้งาน (Active/Inactive) ในแถวตาราง  
**So that** สามารถค้นหา ตรวจสอบ และระงับคำถามที่ล้าสมัยได้ทันทีในคลิกเดียวโดยไม่ต้องเปิดฟอร์มแก้ไข

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้พิมพ์คำค้นหาในกล่องค้นหา (Search Box) หรือเลือก Dropdown กรองตามระบบ (`System`), **THEN** ระบบต้องกรองรายการ Q&A แบบ Server-Side Delegable แสดงผลลัพธ์ภายใน 0.3 วินาที
2. **WHEN** ผู้ใช้คลิกปุ่มสลับสถานะ (Toggle Switch) บนแถวของข้อคำถามใดๆ, **THEN** ระบบต้องอัปเดตสถานะของเรคอร์ดนั้นใน SharePoint List `AI_KnowledgeBase` สลับระหว่าง `Active` และ `Inactive` ทันที และแสดงแถบข้อความยืนยันความสำเร็จ
3. **WHILE** ข้อคำถามมีสถานะ `Inactive`, **THEN** AI Chatbot ต้องไม่นำข้อคำถามนี้ไปใช้ในการสังเคราะห์คำตอบ

**Dependencies**: US-PORTAL-001

---

### US-PORTAL-006: Sliding Side Drawer for Q&A Creation, Rich Details & Editing
**As an** IT Helpdesk Admin  
**I want** หน้าต่าง Slide-out Side Drawer ทางด้านขวาสำหรับ เพิ่ม หรือ แก้ไข ข้อคำถาม-คำตอบ  
**So that** สามารถพิมพ์ปรับแต่งเนื้อหาคำถามและคำตอบได้อย่างสะดวก โดยไม่ต้องเปลี่ยนหน้าจอและยังคงมองเห็นตารางรายการเดิม

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้คลิกปุ่ม `+ เพิ่ม Q&A ใหม่` หรือคลิกเลือกแถวในตาราง Q&A, **THEN** ระบบต้องเลื่อนหน้าต่าง Side Drawer ออกมาจากทางขวา พร้อมโหลดข้อมูลเข้าสู่แบบฟอร์ม
2. **WHEN** ทำการบันทึกข้อมูล, **IF** ฟิลด์ `Title`, `Answer` และ `System` ถูกกรอกครบถ้วน, **THEN** ระบบต้องบันทึกลง SharePoint List `AI_KnowledgeBase` ปิด Drawer และอัปเดตข้อมูลในตารางทันที, **ELSE** ไฮไลต์ฟิลด์สีแดงที่ยังไม่ได้กรอก
3. **WHEN** ผู้ใช้คลิกปุ่ม `ลบรายการ (Delete)`, **THEN** ระบบต้องแสดงกล่องยืนยันการลบ (Delete Confirmation Dialog) เพื่อป้องกันการลบผิดพลาด ก่อนสั่งลบออกจาก SharePoint

**Dependencies**: US-PORTAL-005

---

## Functional Area 4: AI Continuous Learning Loop (Gap-to-KB)

### US-PORTAL-007: 1-Click Gap-to-Q&A Converter & Knowledge Gaps Resolver
**As an** IT Helpdesk Admin หรือ Business Analyst  
**I want** ตรวจดูรายการคำถามที่บอทตอบไม่ได้ (จาก `KnowledgeGaps`) และมีปุ่มแปลงคำถามนั้นเป็นข้อคำถาม-คำตอบ (Q&A) ได้ใน 1 คลิก  
**So that** สามารถเติมเต็มองค์ความรู้ให้ AI ได้อย่างต่อเนื่องและรวดเร็ว ไม่ต้องพิมพ์คำถามซ้ำ

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** เข้าสู่แท็บ "คำถามที่ AI ตอบไม่ได้ (Knowledge Gaps)", **THEN** ระบบต้องดึงรายการคำถามจาก List `KnowledgeGaps` ที่มีสถานะรอดำเนินการมาแสดง โดยเรียงลำดับจากคำถามที่มีการถามบ่อยที่สุด
2. **WHEN** ผู้ใช้คลิกปุ่ม `แปลงเป็น Q&A (Create Q&A)` บนแถวคำถามที่ต้องการ, **THEN** ระบบต้องเปิด Side Drawer เพิ่ม Q&A ให้อัตโนมัติ โดยคัดลอกข้อความคำถาม และชื่อระบบลงในฟอร์มให้ทันที
3. **WHEN** ผู้ใช้กรอกคำตอบที่ถูกต้องและกดบันทึกสำเร็จ, **THEN** ระบบต้องเพิ่มรายการใหม่ลงใน `AI_KnowledgeBase` ด้วยสถานะ `Active` และอัปเดตสถานะของรายการใน `KnowledgeGaps` เป็น `Resolved` โดยอัตโนมัติ

**Dependencies**: US-PORTAL-001, US-PORTAL-006

---

## Functional Area 5: Master Systems & Admin Governance

### US-PORTAL-008: Master Systems Dynamic Synchronization & Role-Based Access Control
**As an** IT Helpdesk Admin หรือ Business Analyst  
**I want** ให้ตัวเลือกระบบงานทั้งหมดในแอปพลิเคชันผูกตรงกับ Master List `Systems` และมีการควบคุมสิทธิ์การแก้ไข (RBAC)  
**So that** ข้อมูลชื่อระบบมีความสอดคล้องกันทั้งองค์กร และป้องกันผู้ใช้ทั่วไปแก้ไขข้อมูลโดยไม่ได้รับอนุญาต

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** ฟอร์มอัปโหลดคู่มือ หรือฟอร์ม Q&A เรียกแสดงตัวเลือกระบบงาน, **THEN** ตัวเลือกทั้งหมดต้องดึงมาจาก Master List `Systems` ที่มีสถานะ `IsActive = Yes` เสมอ
2. **WHEN** พนักงานทั่วไปที่ไม่ได้อยู่ในกลุ่ม IT Helpdesk หรือ BA เข้าใช้งานแอป, **THEN** ระบบต้องเปิดใช้งานในโหมด Read-only (ซ่อนหรือปิดการใช้งานปุ่ม `+ อัปโหลด`, `+ เพิ่ม Q&A`, ปุ่มลบ, และสวิตช์ Toggle สถานะ)
3. **WHILE** แอดมินทำการเพิ่มหรือแก้ไขชื่อระบบใน Master List `Systems`, **THEN** รายการตัวเลือกในแอปพลิเคชันต้องสะท้อนชื่อระบบใหม่ได้ทันทีโดยไม่ต้องแก้ไขโค้ด

**Dependencies**: US-PORTAL-001

---

## Story Summary

| ID | Title | Area | Priority | Dependencies |
|----|-------|------|----------|--------------|
| **US-PORTAL-001** | 4-Tier Desktop 16:9 Shell & Module Tab Navigation | Desktop Shell & KPI | High | None |
| **US-PORTAL-002** | Real-Time Knowledge Base KPI Metrics Bar | Desktop Shell & KPI | High | US-PORTAL-001 |
| **US-PORTAL-003** | System Folder Tree & New Folder Creation | Document Library | High | US-PORTAL-001 |
| **US-PORTAL-004** | Manual File Upload, Metadata & Status Governance | Document Library | High | US-PORTAL-003 |
| **US-PORTAL-005** | High-Density Q&A Grid with Quick Toggle | Q&A Management | High | US-PORTAL-001 |
| **US-PORTAL-006** | Sliding Side Drawer for Q&A Full Editor | Q&A Management | High | US-PORTAL-005 |
| **US-PORTAL-007** | 1-Click Gap-to-Q&A Converter Loop | AI Continuous Learning | High | US-PORTAL-001, US-PORTAL-006 |
| **US-PORTAL-008** | Master Systems Dynamic Sync & RBAC Guard | Governance & Security | High | US-PORTAL-001 |

---

## Story-Persona Matrix

| Story | สมชาย (Helpdesk Admin) | กัญญา (BA/System Owner) | นารี (General Employee) |
|-------|------------------------|-------------------------|-------------------------|
| **US-PORTAL-001** | ✓ Primary | ✓ Primary | ✓ Secondary |
| **US-PORTAL-002** | ✓ Secondary | ✓ Primary | - |
| **US-PORTAL-003** | ✓ Primary | ✓ Secondary | - |
| **US-PORTAL-004** | ✓ Primary | ✓ Primary | ✓ Secondary (Read) |
| **US-PORTAL-005** | ✓ Primary | ✓ Secondary | ✓ Secondary (Read) |
| **US-PORTAL-006** | ✓ Primary | ✓ Primary | - |
| **US-PORTAL-007** | ✓ Primary | ✓ Secondary | - |
| **US-PORTAL-008** | ✓ Secondary | ✓ Primary | ✓ Primary (Guard) |

---

## Non-Functional Considerations
- **Screen Ratio & Ergonomics**: ออกแบบสำหรับ Laptop/Desktop 16:9 (1366x768 ถึง 1920x1080) แถวตารางสูง 44px ให้ความหนาแน่นของข้อมูลสูง
- **Delegation Compliance**: การค้นหาและกรองข้อมูลทั้งใน Library และ List ต้องใช้สูตร Delegable 100% ปราศจากคำเตือน Delegation Warning
- **Enterprise Aesthetics**: ใช้ชุดสี Deves Deep Navy (`#012169`) และห้ามมี Emoji ในข้อความหรือปุ่ม 100% ตามมาตรฐานองค์กร
