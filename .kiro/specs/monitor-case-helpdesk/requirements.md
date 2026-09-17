# ข้อกำหนดความต้องการ (Requirements) — Monitor_case_Helpdesk

## สรุปภาพรวม (Summary)
- **Total Stories**: 8 Stories แบ่งออกเป็น 4 Functional Areas
- **Priority**: 6 High, 2 Medium, 0 Low
- **User Types**: IT Helpdesk Operator (สมชาย), Helpdesk Lead/Supervisor (วิภา)
- **Key Entities**: `Cases` (SharePoint List), `CaseAttachments` (SPListItemAttachment), `Routing` (Team Master), `SLAConfig` (SLA Thresholds)
- **Integrations**: SharePoint Online OData Connector, Office 365 Outlook, Power Automate Cloud Flows, Copilot Studio
- **Core Flows**:
  1. การเข้าสู่แดชบอร์ด ดูสรุป KPI และกรองเคสแบบ Delegable บนหน้าจอ Laptop
  2. การเปิด Side Drawer ตรวจสอบรายละเอียดเคสและกดรับงาน (Assign to Me)
  3. การแนบไฟล์หลักฐาน (Screenshot/Log) บันทึกสรุปแนวทางแก้ไข และยืนยันปิดเคส (Resolve Case)
  4. การสืบค้นเคสย้อนหลังปริมาณมากผ่าน Indexed Columns ใน SharePoint

---

## ภาพรวม (Overview)
เอกสารนี้กำหนดข้อกำหนดฟังก์ชันการทำงานของระบบ **`Monitor_case_Helpdesk`** ที่ได้รับการปรับปรุงใหม่ โดยเขียนเกณฑ์การยอมรับ (Acceptance Criteria) ตามมาตรฐาน **EARS (Easy Approach to Requirements Syntax)** เพื่อให้สามารถนำไปออกแบบ Component, Data Contract และทดสอบระบบได้อย่างแม่นยำ

---

## Functional Area 1: Modern Enterprise UI & Laptop Layout (UI และการจัดวางหน้าจอ)

### US-001: Modern Enterprise Theme & Emoji Removal
**As an** IT Helpdesk Operator / Supervisor  
**I want** หน้าจอระบบที่ใช้โทนสีและไอคอนมาตรฐานทางการระดับ Enterprise ปราศจาก Emoji  
**So that** ระบบมีความเป็นมืออาชีพ สบายตา และพร้อมใช้งานต่อหน้าผู้ใช้หรือผู้บริหาร  

**Priority**: High  

**Acceptance Criteria**:
1. **The system shall** แสดงผลข้อความ ป้ายชื่อ (Labels), หัวเรื่อง (Headers), และปุ่มคำสั่ง (Buttons) ทั้งหมดโดยไม่มีสัญลักษณ์ Emoji ใดๆ
2. **WHEN** ผู้ใช้เปิดหน้าจอระบบ, **THEN** ระบบจะต้องแสดงผลด้วยชุดสีทางการ (Fluent Enterprise Slate / Deves Deep Blue `#012169` / Neutral Gray `#F3F4F6`)
3. **WHEN** แสดงสถานะของเคส (`Open`, `In Progress`, `Resolved`, `Reopened`, `Closed`), **THEN** ระบบจะต้องแสดงผลด้วย Pill Badge ขอบมนพร้อมสีมาตรฐาน (เช่น Open = ฟ้า/เทา, In Progress = ส้ม, Resolved = เขียว, Breached = แดง)
4. **WHERE** มีการใช้ไอคอนสื่อความหมาย, **THEN** ระบบจะต้องใช้ไอคอนเวกเตอร์มาตรฐานของ Power Apps หรือ SVG ไอคอนที่เรียบง่ายแทนการใช้ Emoji

**Dependencies**: None  

---

### US-002: Master-Detail Split Grid & Side Drawer on Laptop
**As an** IT Helpdesk Operator  
**I want** ตารางแสดงรายการเคสแบบหนาแน่น (Dense Grid) ทางฝั่งซ้าย ควบคู่กับแผงดูรายละเอียด/จัดการเคสด้านขวา (Side Drawer)  
**So that** ฉันสามารถตรวจดูข้อมูลและกดปิดเคสได้ทันทีโดยไม่ต้องสลับหน้าจอไปมา และไม่ต้องเลื่อน Scroll บ่อยบนหน้าจอ Laptop  

**Priority**: High  

**Acceptance Criteria**:
1. **The system shall** จัดวางเลย์เอาต์หน้าจอแนวนอน (16:9 Landscape) ให้ตารางรายการเคสแสดงผลได้ไม่น้อยกว่า 15 แถวในหนึ่งหน้าจอบนความละเอียด Laptop มาตรฐาน (1366x768 หรือ 1920x1080)
2. **WHEN** ผู้ใช้คลิกเลือกเคสในตารางรายการ, **THEN** ระบบจะต้องเปิด Side Drawer ทางฝั่งขวาเพื่อแสดงรายละเอียดเคสและฟอร์มการจัดการสถานะทันที
3. **WHILE** Side Drawer กำลังเปิดอยู่, **IF** ผู้ใช้คลิกปุ่มย่อ/ปิด Drawer หรือคลิกพื้นที่ภายนอก, **THEN** Side Drawer จะต้องพับเก็บ และขยายตารางรายการเคสให้เต็มพื้นที่หน้าจอ
4. **WHEN** มีการเปลี่ยนแปลงข้อมูลเคสใน Side Drawer สำเร็จ, **THEN** ระบบจะต้องอัปเดตข้อมูลแถวในตารางฝั่งซ้ายโดยไม่ต้อง Refresh ทั้งหน้าจอ

**Dependencies**: US-001  

---

## Functional Area 2: High-Volume Search, Filter & Delegation (การค้นหาและกรองข้อมูลปริมาณมาก)

### US-003: Delegable Multi-Criteria Filtering
**As an** IT Helpdesk Operator / Supervisor  
**I want** กรองข้อมูลเคสตามสถานะ, ระบบงาน, และช่วงเวลา โดยไม่ติดข้อจำกัด Delegation Limit 2,000 แถวของ SharePoint  
**So that** ฉันสามารถเรียกดูเคสทั้งหมดในอดีตได้อย่างครบถ้วน ถูกต้อง และรวดเร็ว  

**Priority**: High  

**Acceptance Criteria**:
1. **The system shall** ประมวลผลสูตรการกรองข้อมูล (`Filter`) ด้วยฟังก์ชันที่รองรับ Server-Side Delegation บน SharePoint 100%
2. **WHEN** ผู้ใช้คลิกเลือกแท็บสถานะเคส (เช่น "รอรับเรื่อง", "กำลังดำเนินการ", "แก้ไขเสร็จสิ้น", "ทั้งหมด"), **THEN** ระบบจะต้องส่งคำสั่ง Query ไปดึงข้อมูลที่ตรงเงื่อนไขจาก SharePoint ทันที
3. **WHERE** ผู้ใช้เลือกตัวกรองระบบงาน (SystemName Dropdown), **WHEN** มีการเลือกชื่อระบบ, **THEN** ระบบจะต้องกรองเคสเฉพาะระบบนั้นร่วมกับสถานะที่เลือกผ่านเงื่อนไข `And` ที่เป็น Delegable
4. **IF** ข้อมูลใน SharePoint มีปริมาณมากกว่า 2,000 รายการ, **THEN** ระบบจะต้องสามารถเลื่อนตาราง (Scroll) เพื่อโหลดข้อมูลเคสเพิ่มเติมแบบ On-demand ต่อเนื่องได้โดยข้อมูลไม่ตกหล่น

**Dependencies**: US-002  

---

### US-004: Fast Keyword Search with Index Delegation
**As an** IT Helpdesk Operator  
**I want** ค้นหาเคสด้วย CaseID, หัวข้อเรื่อง หรือชื่อผู้แจ้งปัญหา ได้อย่างแม่นยำ  
**So that** ฉันสามารถค้นหาประวัติเคสที่ผู้ใช้โทรหรือส่งข้อความเข้ามาสอบถามได้ในเวลาไม่กี่วินาที  

**Priority**: High  

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้พิมพ์รหัสเคส (CaseID) หรือคำค้นหาในช่องค้นหา, **THEN** ระบบจะต้องใช้ฟังก์ชัน `StartsWith` ในการค้นหากับคอลัมน์ที่เป็น Indexed เพื่อให้รองรับ Delegation
2. **IF** ช่องค้นหาว่างเปล่า, **THEN** ระบบจะต้องแสดงผลเคสตามเงื่อนไขตัวกรองสถานะและระบบงานปกติ
3. **WHEN** ผู้ใช้คลิกปุ่ม "ล้างตัวกรอง" (Clear Filters), **THEN** ระบบจะต้องล้างคำค้นหาและรีเซ็ตตัวกรองทั้งหมดกลับสู่ค่าเริ่มต้น (Default: เคสที่ยังไม่ปิด)

**Dependencies**: US-003  

---

## Functional Area 3: Case Resolution & Evidence Attachment (การปิดเคสและแนบหลักฐาน)

### US-005: Resolution Evidence Attachment & File Management
**As an** IT Helpdesk Operator  
**I want** แนบไฟล์ภาพหน้าจอ (Screenshot), ไฟล์ Log หรือเอกสารยืนยันการแก้ไขปัญหาลงในเคส  
**So that** มีหลักฐานอ้างอิงที่โปร่งใส ตรวจสอบได้ว่าปัญหาได้รับการแก้ไขจริง  

**Priority**: High  

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้เข้าสู่ส่วนการจัดการปิดเคสใน Side Drawer, **THEN** ระบบจะต้องแสดงพื้นที่สำหรับแนบไฟล์หลักฐาน (Attachment Control) พร้อมแสดงรายชื่อไฟล์ ขนาดไฟล์ และปุ่มลบไฟล์
2. **WHEN** ผู้ใช้เลือกไฟล์จากเครื่อง (รองรับ `.png`, `.jpg`, `.pdf`, `.txt`, `.docx`, `.xlsx`), **THEN** ระบบจะต้องแสดงรายการไฟล์ในกล่องแนบไฟล์ทันที
3. **IF** ผู้ใช้พยายามอัปโหลดไฟล์ที่มีขนาดเกิน 15 MB, **THEN** ระบบจะต้องปฏิเสธไฟล์และแจ้งเตือนข้อความเตือนขนาดไฟล์
4. **WHEN** การบันทึกปิดเคสเสร็จสมบูรณ์, **THEN** ระบบจะต้องอัปโหลดไฟล์หลักฐานไปยัง SharePoint List Item Attachments ของเคสนั้นๆ โดยอัตโนมัติ

**Dependencies**: US-002  

---

### US-006: Resolution Validation & Status Progression
**As a** Helpdesk Lead & Supervisor  
**I want** ให้ระบบบังคับให้เจ้าหน้าที่ต้องกรอกสรุปแนวทางแก้ไขและแนบไฟล์หลักฐานก่อนกดปิดเคส  
**So that** ป้องกันการกดปิดงานลอยๆ โดยไม่มีรายละเอียดหรือหลักฐานยืนยัน  

**Priority**: High  

**Acceptance Criteria**:
1. **WHILE** เคสมีสถานะเป็น `Open` หรือ `In Progress`, **IF** ผู้ใช้กดปุ่ม "ปิดงาน" (Resolve), **THEN** ระบบจะต้องตรวจสอบว่ามีการกรอก `ResolutionSummary` และมีไฟล์แนบอย่างน้อย 1 ไฟล์
2. **IF** ช่อง `ResolutionSummary` ว่างเปล่า หรือไม่มีไฟล์แนบหลักฐาน, **THEN** ระบบจะต้องปิดการทำงานของปุ่มบันทึก (Disabled) หรือแสดงข้อความแจ้งเตือนสีแดงระบุสิ่งที่ต้องกรอก/แนบให้ครบถ้วน
3. **WHEN** ข้อมูลครบถ้วนและผู้ใช้กดยืนยันปิดงาน, **THEN** ระบบจะต้องอัปเดตสถานะ `Statuscase` เป็น `Resolved`, บันทึกเวลาปัจจุบันลง `ResolvedAt`, บันทึกข้อความลง `ResolutionSummary`, และส่งอีเมลแจ้งผู้แจ้งปัญหาผ่าน Flow อัตโนมัติ
4. **WHEN** ผู้ใช้คลิกปุ่ม "รับเคส" (Assign to Me), **THEN** ระบบจะต้องอัปเดต `AssignedOwner` เป็นชื่อของผู้ใช้งานปัจจุบัน และเปลี่ยนสถานะเป็น `In Progress` โดยไม่ต้องบังคับแนบไฟล์

**Dependencies**: US-005  

---

## Functional Area 4: Analytics, SLA Tracking & SharePoint Schema (การวิเคราะห์และโครงสร้างข้อมูล)

### US-007: Real-Time KPI Metrics Bar & SLA Breach Indicator
**As a** Helpdesk Lead / Operator  
**I want** แถบสรุปตัวชี้วัดจำนวนเคสและตัวเตือนเคสใกล้/เกินกำหนด SLA ที่ด้านบนสุดของหน้าจอ  
**So that** ฉันสามารถเห็นภาระงานทั้งหมดและจัดลำดับความสำคัญของเคสเร่งด่วนได้อย่างทันท่วงที  

**Priority**: Medium  

**Acceptance Criteria**:
1. **The system shall** แสดงการ์ด KPI สรุปผลด้านบนของแดชบอร์ด ประกอบด้วย:
   - เคสทั้งหมด (Total Active Cases)
   - รอรับเรื่อง (Pending / Open)
   - กำลังแก้ไข (In Progress)
   - ปิดงานแล้ววันนี้ (Resolved Today)
   - เกินกำหนด SLA (SLA Breached)
2. **WHEN** มีเคสที่เวลาปัจจุบันเกิน `SlaDueDate` และสถานะยังไม่เป็น `Resolved`/`Closed`, **THEN** ระบบจะต้องแสดงแถบสีเตือน (SLA Alert Indicator) บนการ์ดเคสนั้นอย่างชัดเจน
3. **WHEN** ผู้ใช้คลิกที่การ์ด KPI ใดๆ, **THEN** ตารางรายการด้านล่างจะต้องกรองข้อมูลตามเงื่อนไขของการ์ดนั้นทันที (เช่น คลิกการ์ด "เกินกำหนด SLA" → แสดงเฉพาะเคสที่หลุด SLA)

**Dependencies**: US-001, US-003  

---

### US-008: SharePoint Schema Enhancement & Indexing Configuration
**As a** System Architect / Developer  
**I want** แนะนำและจัดเตรียมโครงสร้างฟิลด์ใน SharePoint List `Cases` ให้รองรับข้อมูลสรุปการแก้ไขและการทำ Index  
**So that** ฐานข้อมูลมีความพร้อม รองรับการสืบค้นข้อมูลขนาดใหญ่ และพร้อมเชื่อมต่อไปยังระบบออกรายงาน Power BI ในอนาคต  

**Priority**: High  

**Acceptance Criteria**:
1. **The system shall** จัดเตรียมเอกสารและแนวทางตั้งค่า SharePoint List `Cases` สำหรับเพิ่ม 2 คอลัมน์ใหม่:
   - `ResolutionSummary`: Multiple lines of text (Plain text) สำหรับสรุปแนวทางแก้ปัญหา
   - `ResolutionCategory`: Choice (เช่น แก้ไขข้อมูล, ปรับแต่งสิทธิ์, แก้ไขบั๊กโปรแกรม, สอนการใช้งาน, ประสานงานภายนอก)
2. **The system shall** จัดเตรียมแนวทางตั้งค่า Indexed Columns ใน SharePoint สำหรับ 5 คอลัมน์หลัก:
   - `Statuscase`
   - `CaseID`
   - `SystemName`
   - `AssignedOwner`
   - `Created`
3. **WHEN** มีการเพิ่มคอลัมน์และ Index ใน SharePoint เรียบร้อย, **THEN** Power Apps Connector จะสามารถ Query และบันทึกข้อมูลฟิลด์ใหม่ได้โดยไม่มี Schema Error

**Dependencies**: None  

---

## สรุปภาพรวม User Stories (Story Summary)

| Story ID | ชื่อเรื่อง (Title) | กลุ่มฟังก์ชัน (Area) | ความสำคัญ (Priority) | สิ่งที่ต้องทำก่อน (Dependencies) |
|---|---|---|---|---|
| **US-001** | Modern Enterprise Theme & Emoji Removal | Area 1: UI & Laptop Layout | High | None |
| **US-002** | Master-Detail Split Grid & Side Drawer on Laptop | Area 1: UI & Laptop Layout | High | US-001 |
| **US-003** | Delegable Multi-Criteria Filtering | Area 2: Search & Filter | High | US-002 |
| **US-004** | Fast Keyword Search with Index Delegation | Area 2: Search & Filter | High | US-003 |
| **US-005** | Resolution Evidence Attachment & File Management | Area 3: Resolution & Evidence | High | US-002 |
| **US-006** | Resolution Validation & Status Progression | Area 3: Resolution & Evidence | High | US-005 |
| **US-007** | Real-Time KPI Metrics Bar & SLA Breach Indicator | Area 4: Analytics & Schema | Medium | US-001, US-003 |
| **US-008** | SharePoint Schema Enhancement & Indexing Configuration | Area 4: Analytics & Schema | High | None |

---

## เมทริกซ์ความสัมพันธ์ Story กับ Persona (Story-Persona Matrix)

| Story ID | สมชาย (IT Support Operator) | วิภา (Helpdesk Lead Supervisor) |
|---|---|---|
| **US-001** (Modern Theme / No Emoji) | ✓ Primary | ✓ Primary |
| **US-002** (Master-Detail Split View) | ✓ Primary | ✓ Secondary |
| **US-003** (Delegable Filtering) | ✓ Primary | ✓ Primary |
| **US-004** (Fast Keyword Search) | ✓ Primary | ✓ Secondary |
| **US-005** (Evidence Attachment) | ✓ Primary | ✓ Primary |
| **US-006** (Resolution Validation) | ✓ Secondary | ✓ Primary |
| **US-007** (KPI Metrics & SLA Alert) | ✓ Secondary | ✓ Primary |
| **US-008** (SharePoint Schema & Indexing) | - | ✓ Primary |

---

## ข้อพิจารณาที่ไม่ใช่ฟังก์ชันหลัก (Non-Functional Considerations)

1. **ประสิทธิภาพ (Performance & Delegation)**:
   - ตารางเคสใน `Home_incident` ต้องไม่แสดง Delegation Warning ไอคอนสีเหลืองใดๆ ใน Power Apps Studio
   - การสลับแท็บสถานะหรือเปลี่ยนเงื่อนไขกรองต้องตอบสนองภายในไม่เกิน 1.5 วินาที
2. **ความเข้ากันได้และการแสดงผล (Viewport Compatibility)**:
   - ทดสอบและรองรับความละเอียดหน้าจอ Laptop 16:9 มาตรฐาน (1366x768 และ 1920x1080) โดยไม่มีแถบเลื่อนแนวนอน (No horizontal overflow)
3. **ความปลอดภัยและการจัดเก็บข้อมูล (Data Security & Integrity)**:
   - ไฟล์แนบหลักฐานจะต้องจัดเก็บอยู่ภายใต้ SharePoint Site `PowerAppPRD` ที่มีสิทธิ์ตามระบบของ Deves Insurance เท่านั้น
   - การปิดเคสและการแก้ไขต้องผูกกับ `varCurrentUser` ป้องกันการสวมรอย
