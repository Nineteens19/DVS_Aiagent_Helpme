# Implementation Tasks

## Overview
Tasks organized by **Foundation-to-Feature Progressive Wave Delivery** across 4 execution waves, covering all 8 User Stories, 8 Architecture Components, and 4 Data Entities for the Desktop 16:9 Knowledge Base Management Portal.

**Derived From**:
- Requirements: 8 user stories from `.kiro/specs/helpdesk-kb-portal/requirements.md`
- Design: 8 components, 4 entities, 1 integration flow from `design/` folder
- Decisions: D4 decisions from `.aidlc/workflow/helpdesk-kb-portal/decisions-tasks.md`

**Strategy**: Foundation-to-Feature Progressive Wave Delivery
**Rationale**: Enables systematic building from foundation manifests and RBAC authentication to the 4-tier shell, high-density Q&A data grid, sliding drawer, and gap conversion pipeline, concluding with Power Platform CLI packaging into `.msapp`.

---

- [x] 1. Phase 1: Application Scaffold & Master Connections
  - [x] 1.1 Canvas App Project Scaffolding & Manifest Configuration
    - **Deps**: None | **Ref**: `design/implementation.md` — Section 1 & 2
    - สร้างโครงสร้างโฟลเดอร์ `Helpdesk_KB_Portal/` พร้อมไฟล์โครงสร้าง Canvas App
    - สร้าง `CanvasManifest.json` กำหนด FormatVersion, ScreenOrder (`Home_KB`), และ PublishInfo
    - สร้าง `Properties.json` กำหนด Widescreen 16:9 (`1366x768`), AuthoringVersion, และ DocumentType
    - สร้าง `References/DataSources.json` ผูก SharePoint endpoints: `SystemManuals`, `AI_KnowledgeBase`, `Systems`, `KnowledgeGaps`
    - สร้าง `References/Resources.json` และไฟล์โครงสร้างระบบ
  - [x] 1.2 App Definition, RBAC Security & Master Data Initialization
    - **Deps**: 1.1 | **Ref**: `design/components.md` — Component 7, `design/data-model.md` — Section 2
    - สร้าง `Src/App.pa.yaml` กำหนดโครงสร้างคลาส `App as appinfo`
    - เขียนสูตร `OnStart`: กำหนดตัวแปรธีมองค์กร Deves Deep Navy (`varTheme`)
    - เขียนสูตร RBAC: ตรวจสอบอีเมลผู้ใช้เทียบกับ `varAdminGroupEmail` หรือ IT Admin list เพื่อตั้งค่า `varIsKBAdmin`
    - เขียนสูตรโหลด Master Systems เข้าคอลเลกชัน `colMasterSystems` ด้วย Delegable query
    - กำหนดตัวแปรเริ่มต้นหน้าจอ `varActiveTab: "QNA"` และสถานะ Drawer `varDrawerOpen: false`

- [x] 2. Phase 2: 4-Tier Desktop Shell & Manuals Management
  - [x] 2.1 4-Tier Desktop 16:9 Shell, Header, KPI Bar & Module Navigation
    - **Deps**: 1.2 | **Ref**: `design/components.md` — Component 1 & 2, `requirements.md` — US-PORTAL-001, US-PORTAL-008
    - สร้าง `Src/Home_KB.pa.yaml` พร้อม Screen `Home_KB as screen` และคอนเทนเนอร์หลัก `conAppFrame`
    - พัฒนา Tier 1 Header (`conHeader`): โลโก้/ชื่อระบบ "Helpdesk AI Knowledge Portal", Badge แสดงสถานะ Admin/ViewOnly, ข้อมูล User Profile
    - พัฒนา Tier 2 KPI Metric Bar (`conKPIBar`): 4 Metric Cards (Total Approved Manuals, Active Q&A 74 รายการ, Pending Knowledge Gaps, System Coverage) คำนวณแบบ Delegable
    - พัฒนา Tier 3 Navigation Tabs (`conModuleTabs`): 3 แท็บหลัก (คำถาม-คำตอบ Q&A, คู่มือระบบ System Manuals, คำถามที่รอตอบ Knowledge Gaps) พร้อม Active State Indicator
    - พัฒนา Tier 4 Status Footer (`conStatusFooter`): แสดงเวอร์ชันระบบ, วันที่อัปเดตล่าสุด, และสถานะการเชื่อมต่อ
  - [x] 2.2 System Folder Directory & Manuals Document Manager
    - **Deps**: 2.1 | **Ref**: `design/components.md` — Component 3, `requirements.md` — US-PORTAL-002, US-PORTAL-003, US-PORTAL-004
    - พัฒนา `conManualsView` บนหน้าจอ `Home_KB`: แบ่ง Layout แบบ Master-Detail ซ้าย-ขวา
    - พัฒนาแกลเลอรีโฟลเดอร์ระบบ (`galSystemFolders`): ดึงรายชื่อระบบจาก `colMasterSystems` พร้อมแถบค้นหาระบบ และตัวเลขจำนวนคู่มือ
    - พัฒนาแกลเลอรีรายการคู่มือ (`galManualsList`): กรองเอกสารจาก `SystemManuals` ตามโฟลเดอร์ที่เลือกแบบ Delegable Server-Side
    - พัฒนาแถบแสดงสถานะเอกสาร (Approved / Under Review / Draft) และปุ่มเปลี่ยนสถานะ (สงวนสิทธิ์เฉพาะ Admin ผ่าน `varIsKBAdmin`)
    - พัฒนา Modal Dialog สำหรับอัปโหลดเอกสารใหม่ (`conUploadModal`) พร้อมช่องเลือกหมวดหมู่ระบบและเวอร์ชัน

- [x] 3. Phase 3: High-Density Q&A & Sliding Side Drawer
  - [x] 3.1 High-Density 44px Q&A Table & Instant Delegable Search
    - **Deps**: 2.1 | **Ref**: `design/components.md` — Component 4, `requirements.md` — US-PORTAL-005
    - พัฒนา `conQnAView` บนหน้าจอ `Home_KB`: แถบเครื่องมือด้านบนประกอบด้วย ช่องค้นหา Delegable Search, Dropdown กรองตามระบบ, Filter Chips (All, Active, Inactive), และปุ่มสร้างคำถามใหม่
    - พัฒนาแกลเลอรีตาราง Q&A ความหนาแน่นสูง (`galQnAGrid`): กำหนดความสูงแถว 44px พอดีสำหรับการแสดงผล 12-15 แถวบนจอ Laptop 768p
    - จัดคอลัมน์ตาราง: Question, System Name, Answer Preview, Status Badge, Quick Toggle Switch, Action Buttons (Edit, Delete)
    - เขียนสูตร Quick Toggle Switch: อัปเดตฟิลด์ `IsActive` ใน `AI_KnowledgeBase` ทันทีด้วยฟังก์ชัน `Patch()` โดยไม่ต้องเปิดฟอร์ม
  - [x] 3.2 Sliding Side Drawer Editor & Confirmation Dialog
    - **Deps**: 3.1 | **Ref**: `design/components.md` — Component 5 & 8, `requirements.md` — US-PORTAL-006
    - พัฒนาคอนเทนเนอร์ Sliding Drawer ด้านขวา (`conSlideDrawer` กว้าง 420px): แสดงผลด้วยแอนิเมชันเลื่อนจากขวาเมื่อ `varDrawerOpen = true`
    - พัฒนาฟอร์มกรอกข้อมูล Q&A (`conDrawerForm`): ช่องคำถาม (`txtDrawerQuestion`), Dropdown ระบบ (`ddDrawerSystem`), ช่องคำตอบละเอียด (`txtDrawerAnswer`), Checkbox Active (`chkDrawerActive`)
    - เขียนสูตร Validate & Save: ตรวจสอบความครบถ้วนของข้อมูล และบันทึกผ่าน `Patch()` ทั้งโหมด Create New และ Update Existing
    - พัฒนา Corporate Confirmation Modal Dialog (`conConfirmModal`): หน้าต่างยืนยันเมื่อต้องการลบ/ระงับรายการ Q&A ป้องกันการลบโดยไม่ตั้งใจ

- [x] 4. Phase 4: Gap-to-KB Converter Loop & Packaging
  - [x] 4.1 Knowledge Gaps Grid & 1-Click Gap-to-KB Workflow
    - **Deps**: 3.2 | **Ref**: `design/components.md` — Component 6, `requirements.md` — US-PORTAL-007
    - พัฒนา `conGapsView` บนหน้าจอ `Home_KB`: ตารางแสดงรายการคำถามที่ AI ตอบไม่ได้จาก SharePoint List `KnowledgeGaps`
    - แสดงข้อมูลความถี่การถาม (Frequency), คำถามที่พบบ่อย (Unanswered Question), ระบบที่เกี่ยวข้อง, และสถานะการตรวจสอบ (Pending / Resolved)
    - เขียนสูตร 1-Click Convert Action (`btnConvertGap`): เมื่อคลิกปุ่มแปลงคำถาม ระบบจะเปิด Sliding Side Drawer อัตโนมัติ พร้อมกรอก Question และ System ล่วงหน้า
    - เขียนสูตรผูกพันธะเมื่อบันทึก Q&A สำเร็จ: อัปเดตสถานะของ Gap ต้นทางใน `KnowledgeGaps` เป็น `Resolved` โดยอัตโนมัติ
  - [x] 4.2 Power Platform CLI Packaging & Quality Verification
    - **Deps**: 1.1, 1.2, 2.1, 2.2, 3.1, 3.2, 4.1 | **Ref**: `design/nfr.md`, `design/implementation.md` — Section 3
    - คอมไพล์ซอร์สโค้ดจากโฟลเดอร์ `Helpdesk_KB_Portal` เป็นไฟล์ `Helpdesk_KB_Portal.msapp` โดยใช้คำสั่ง `pac canvas pack`
    - ตรวจสอบความถูกต้องของไบนารีและขนาดไฟล์ `.msapp`
    - ดำเนินการตรวจสอบคุณภาพโค้ด (Quality & Delegation Audit): ตรวจสอบว่าไม่มี Delegation Warning, ปราศจาก Emoji 100%, และรองรับ Desktop Widescreen 16:9
    - จัดทำคู่มือและคำแนะนำในการนำเข้าสู่ Power Apps Maker Portal

---

## Task Summary

| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | Canvas App Project Scaffolding & Manifest Configuration | None | [x] |
| 1.2 | App Definition, RBAC Security & Master Data Initialization | 1.1 | [x] |
| 2.1 | 4-Tier Desktop 16:9 Shell, Header, KPI Bar & Module Navigation | 1.2 | [x] |
| 2.2 | System Folder Directory & Manuals Document Manager | 2.1 | [x] |
| 3.1 | High-Density 44px Q&A Table & Instant Delegable Search | 2.1 | [x] |
| 3.2 | Sliding Side Drawer Editor & Confirmation Dialog | 3.1 | [x] |
| 4.1 | Knowledge Gaps Grid & 1-Click Gap-to-KB Workflow | 3.2 | [x] |
| 4.2 | Power Platform CLI Packaging & Quality Verification | 1.1, 1.2, 2.1, 2.2, 3.1, 3.2, 4.1 | [x] |

---

## Requirements Coverage

| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-PORTAL-001 (16:9 Desktop 4-Tier Shell & KPI Summary Bar) | Task 2.1 | [x] |
| US-PORTAL-002 (System Folder Directory & Navigation) | Task 2.2 | [x] |
| US-PORTAL-003 (Document Upload & Metadata Classification) | Task 2.2 | [x] |
| US-PORTAL-004 (Document Status & Lifecycle Control) | Task 2.2 | [x] |
| US-PORTAL-005 (High-Density Q&A Grid & Delegable Search) | Task 3.1 | [x] |
| US-PORTAL-006 (Sliding Side Drawer for Q&A Operations) | Task 3.2 | [x] |
| US-PORTAL-007 (Gap-to-KB Converter Loop) | Task 4.1 | [x] |
| US-PORTAL-008 (Role-Based Access Control & Visual Indicators) | Task 1.2, Task 2.1, Task 2.2, Task 3.1, Task 3.2 | [x] |

---

## Design Coverage

- **Components**:
  - Comp 1: 4-Tier Desktop 16:9 Shell → Task 2.1
  - Comp 2: Module Tab Bar → Task 2.1
  - Comp 3: System Folders & Manuals Manager → Task 2.2
  - Comp 4: High-Density Q&A Table → Task 3.1
  - Comp 5: Sliding Side Drawer → Task 3.2
  - Comp 6: Gap-to-KB Converter → Task 4.1
  - Comp 7: RBAC Access Guard → Task 1.2, Task 2.1
  - Comp 8: Corporate Modal Confirmation Dialog → Task 3.2
- **Entities**:
  - `ManualDocument` (`SystemManuals`) → Task 1.1, Task 2.2
  - `QnAEntry` (`AI_KnowledgeBase`) → Task 1.1, Task 3.1, Task 3.2
  - `KnowledgeGap` (`KnowledgeGaps`) → Task 1.1, Task 4.1
  - `MasterSystem` (`Systems`) → Task 1.1, Task 1.2, Task 2.2, Task 3.2
- **Integrations**:
  - SharePoint Online OData Connector → Task 1.1, Task 1.2
  - Power Automate CreateFolder Trigger → Task 2.2
  - Power Platform CLI (`pac canvas pack`) → Task 4.2
- **NFRs & Constraints**:
  - 16:9 Desktop Widescreen Layout (1366x768 / 1920x1080) → Task 1.1, Task 2.1, Task 4.2
  - High Data Density 44px Row Height → Task 3.1
  - 100% Server-Side Delegable Queries (Zero Delegation Warnings) → Task 1.2, Task 2.2, Task 3.1, Task 4.2
  - 100% Emoji-Free Corporate Theme → All Tasks

---

## Definition of Done

- [ ] โครงสร้างโฟลเดอร์และซอร์สโค้ด YAML ของ Canvas App ถูกต้องตามมาตรฐาน Power Platform CLI
- [ ] ไฟล์ `Helpdesk_KB_Portal.msapp` ถูกคอมไพล์สำเร็จผ่านคำสั่ง `pac canvas pack`
- [ ] ฟังก์ชันค้นหาและกรองข้อมูล Q&A, คู่มือ, และ Gaps ผ่านเกณฑ์ 100% Server-Side Delegable ปราศจาก Warning 2,000 แถว
- [ ] ระบบ RBAC แบ่งสิทธิ์ Admin (Edit/Delete/Upload/Toggle) และ View-Only ชัดเจน
- [ ] หน้าจอ Desktop 16:9 ใช้งานได้ลื่นไหล ไม่พบข้อบกพร่องเรื่องการตัดทอนข้อความบนความละเอียด 1366x768 ขึ้นไป
- [ ] ปราศจาก Emoji ในทุกส่วนของโค้ดและ UI ตามข้อกำหนด Deves Corporate Standard

---

## Execution Waves

Tasks grouped by dependency resolution for progressive delivery.

| Wave | Tasks | Dependencies Resolved | Parallel |
|------|-------|-----------------------|----------|
| 1 | [1.1, 1.2] | None (Foundation Scaffold) | No (Sequential) |
| 2 | [2.1, 2.2] | Wave 1 | Yes (Modular Screen Zones) |
| 3 | [3.1, 3.2] | Wave 2 | Yes (Modular Screen Zones) |
| 4 | [4.1, 4.2] | Wave 3 | Sequential (Feature then Build) |

### File Ownership Per Wave

**Wave 1 (Foundation)**:
- Task 1.1: `Helpdesk_KB_Portal/CanvasManifest.json`, `Helpdesk_KB_Portal/Properties.json`, `Helpdesk_KB_Portal/References/DataSources.json`, `Helpdesk_KB_Portal/References/Resources.json`, `Helpdesk_KB_Portal/Entropy/`
- Task 1.2: `Helpdesk_KB_Portal/Src/App.pa.yaml`

**Wave 2 (Shell & Manuals)**:
- Task 2.1: `Helpdesk_KB_Portal/Src/Home_KB.pa.yaml` (`conAppFrame`, `conHeader`, `conKPIBar`, `conModuleTabs`, `conStatusFooter`)
- Task 2.2: `Helpdesk_KB_Portal/Src/Home_KB.pa.yaml` (`conManualsView`, `galSystemFolders`, `galManualsList`, `conUploadModal`)

**Wave 3 (Q&A & Drawer)**:
- Task 3.1: `Helpdesk_KB_Portal/Src/Home_KB.pa.yaml` (`conQnAView`, `galQnAGrid`, Toolbar & Filters)
- Task 3.2: `Helpdesk_KB_Portal/Src/Home_KB.pa.yaml` (`conSlideDrawer`, `conDrawerForm`, `conConfirmModal`)

**Wave 4 (Gaps & Packaging)**:
- Task 4.1: `Helpdesk_KB_Portal/Src/Home_KB.pa.yaml` (`conGapsView`, `galGapsGrid`, Convert Trigger)
- Task 4.2: Root workspace build output: `Helpdesk_KB_Portal.msapp`

---

## Notes

**Technical Considerations**:
- หน้าจอ `Home_KB.pa.yaml` เป็นไฟล์ Canvas App Screen ขนาดใหญ่ที่รวมคอนเทนเนอร์ 4 ส่วน เพื่อให้แน่ใจว่า Power Platform CLI คอมไพล์ได้ราบรื่น การสร้างไฟล์ซอร์สโค้ด YAML จะเรียบเรียงโครงสร้าง Control Hierarchy ให้ถูกต้องตามมาตรฐาน Canvas Document Object Model
- การคอมไพล์ผ่าน `pac canvas pack` จะต้องใช้ไฟล์ไบนารี `$env:USERPROFILE\pac-cli\extracted\tools\pac.exe` ตามที่ได้ทดสอบและยืนยันไว้ใน Context Assessment
