# Implementation Tasks: Monitor_case_Helpdesk

## Overview
แผนงานพัฒนาและปรับปรุงซอร์สโค้ด Power Apps Canvas App `Monitor_case_Helpdesk` จัดลำดับตามยุทธศาสตร์ 4 Dependency Waves โดยอ้างอิงจากข้อกำหนดใน `requirements.md` และสถาปัตยกรรมทางเทคนิคใน `design.md`

**Derived From**:
- Requirements: 8 User Stories (US-1 ถึง US-8) จาก `requirements.md`
- Design: 5 Components, 2 Data Entities, 2 External Integrations จาก `design/`
- Target Codebase: `Monitor_case_Helpdesk/Src/*.pa.yaml` + `SHAREPOINT-SETUP-GUIDE.md`

**Strategy**: 4 Dependency Waves (Foundation -> Unit 1 Read/Filter -> Unit 2 Resolution/Drawer -> Packaging/Docs)  
**Rationale**: เพื่อให้สามารถทดสอบความถูกต้องและการรวมแพ็กเกจผ่าน PAC CLI ได้อย่างเป็นระบบในแต่ละขั้นตอน

---

- [x] 1. Foundation & Global Theme Variables (Wave 1)
  - [x] 1.1 Setup Deves Corporate Theme Tokens and App Variables
    - **Deps**: None | **Ref**: `design/implementation.md` — Section 1 & 2
    - ปรับปรุง `App.pa.yaml`: กำหนด `OnStart` กำหนดค่าเริ่มต้น `varSelectedStatus = "All"`, `varShowDrawer = false`, `varSelectedCase = Blank()`
    - ประกาศตัวแปรชุดสีทางการ: `gblColorPrimary = ColorValue("#012169")`, `gblColorBg = ColorValue("#F8F9FA")`, `gblColorSurface = ColorValue("#FFFFFF")`, `gblColorBorder = ColorValue("#E2E8F0")`
    - ประกาศตัวแปรสี Semantic Status Badges: Open (Slate), In Progress (Amber), Resolved (Emerald), SLA Breached (Rose)
  - [x] 1.2 Setup 4-Tier Auto-Layout Container Hierarchy on Home_incident
    - **Deps**: 1.1 | **Ref**: `design/components.md` — Section 1-5, `design/implementation.md`
    - ปรับแต่ง `Home_incident.pa.yaml`: สร้างโครงสร้างคอนเทนเนอร์หลัก `con_Root` (Vertical Auto-Layout)
    - กำหนด 4 Tiers: `con_Header` (56px), `con_KpiBar` (84px), `con_ControlBar` (52px), และ `con_Workspace` (Fill Remaining)
    - แบ่งพื้นที่ `con_Workspace` แนวนอนเป็น `con_LeftPane` (ตารางเคส) และ `con_SideDrawer` (กว้าง 480px, Visible = `varShowDrawer`)

- [x] 2. Unit 1: Filter, Dashboard & High-Volume Dense Table (Wave 2)
  - [x] 2.1 Implement cmp_AppHeader and cmp_KpiSummaryBar
    - **Deps**: 1.2 | **Ref**: `design/components.md` — Section 1 & 2, US-1, US-8
    - สร้าง Header: ชื่อระบบทางการ "ระบบบริหารจัดการเคสไอที (IT Helpdesk Case Monitor)" ปราศจาก Emoji 100%, โลโก้, รูปโปรไฟล์ผู้ใช้, เวลาอัปเดตล่าสุด และปุ่มรีเฟรชข้อมูล
    - สร้าง KPI Summary Bar: การ์ดตัวชี้วัด 5 ใบ (เคสทั้งหมด, เคสใหม่, กำลังดำเนินการ, ปิดงานวันนี้, เกินกำหนดเวลา SLA) พร้อม OnSelect กรองข้อมูลด่วน
  - [x] 2.2 Implement cmp_ControlFilterBar
    - **Deps**: 1.2 | **Ref**: `design/components.md` — Section 3, US-3, US-4
    - สร้างแท็บตัวกรองสถานะ: ปุ่มกดแบบ Segmented Pill (ทั้งหมด, รอดำเนินการ, กำลังดำเนินการ, ปิดงานแล้ว) ไร้ Emoji
    - เชื่อมต่อ ComboBox ระบบงาน `cmb_SystemFilter` ดึงข้อมูลจาก List `Systems`
    - กล่องค้นหาคำสำคัญ `txt_Search` ค้นหารหัสเคสหรือหัวเรื่อง
    - ปุ่มรีเซ็ตตัวกรองทั้งหมด `btn_ClearFilters`
  - [x] 2.3 Implement cmp_CaseTableGallery with 100% Server-Side Delegable Filter
    - **Deps**: 2.2 | **Ref**: `design/components.md` — Section 4, `design/data-model.md`, US-2, US-3, US-4
    - สร้างหัวตาราง (Grid Header) จัดแนวคอลัมน์: รหัสเคส, ระบบงาน, หัวเรื่อง, ผู้รับผิดชอบ, วันที่แจ้ง, สถานะ, การจัดการ
    - สร้าง Gallery แถวกระชับความสูง 44px (Compact Row) เหมาะกับหน้าจอ Laptop 16:9
    - กำหนดสูตร `Items` กรองแบบ Boolean ตรง Server-Side Delegable 100% ด้วย `StartsWith()` และ `SortByColumns("Created", Descending)`
    - จัดวาง Status Badge เป็นทรงมน (Pill Badge) ตาม Design Tokens
    - กำหนดปุ่มแถวเคส "ดูรายละเอียด / ปิดเคส" กำหนดค่า `varSelectedCase = ThisItem` และ `varShowDrawer = true`

- [x] 3. Unit 2: Collapsible Side Drawer & Resolution Evidence (Wave 3)
  - [x] 3.1 Implement cmp_ResolutionSideDrawer Layout & Summary Card
    - **Deps**: 2.3 | **Ref**: `design/components.md` — Section 5, US-1, US-5
    - สร้างคอนเทนเนอร์ Side Drawer กว้าง 480px ฝั่งขวาของหน้าจอ มีปุ่มกากบาท `btn_CloseDrawer`
    - สร้าง Card สรุปข้อมูลเคสอ่านอย่างเดียว (Read-only Summary): รหัสเคส, ผู้แจ้ง, ระบบ, รายละเอียดปัญหา, เวลาที่บันทึก
  - [x] 3.2 Implement Resolution EditForm with Native Attachments Control
    - **Deps**: 3.1 | **Ref**: `design/data-model.md`, `design/implementation.md`, US-5, US-6
    - สร้าง EditForm `frm_CaseResolution` ผูกกับ SharePoint List `Cases` (Item = `varSelectedCase`)
    - เพิ่ม DataCard `ResolutionCategory` (Choice Dropdown)
    - เพิ่ม DataCard `ResolutionSummary` (TextInput หลายบรรทัด 6 บรรทัด)
    - เพิ่ม DataCard `Attachments` (Native SharePoint Attachment Control รองรับลากวางไฟล์ภาพ/PDF)
  - [x] 3.3 Implement Strict Validation, Submit Transaction & Feedback
    - **Deps**: 3.2 | **Ref**: `design/implementation.md` — Section 5, US-5, US-6
    - กำหนด `DisplayMode` ของปุ่ม "ยืนยันการปิดเคส": เปิดใช้งานเฉพาะเมื่อเลือกหมวดหมู่, กรอกสรุป >= 10 ตัวอักษร และแนบไฟล์อย่างน้อย 1 ไฟล์
    - กำหนด `OnSelect` รัน `SubmitForm(frm_CaseResolution)` ปรับสถานะเป็น `Resolved` และบันทึกเวลา `ResolvedAt = Now()`
    - กำหนด `OnSuccess` แสดง Toast สำเร็จ, ปิด Drawer (`varShowDrawer = false`) และสั่ง `Refresh(Cases)`

- [x] 4. Verification, Modernization, Packaging & Deployment Guide (Wave 4)
  - [x] 4.1 Modernize and Clean Emoji in updateincident Screen
    - **Deps**: 3.3 | **Ref**: `design/implementation.md`, US-1
    - ปรับปรุงซอร์สโค้ด `updateincident.pa.yaml` ให้ใช้ Design Tokens เดียวกันและกำจัด Emoji 100% เพื่อรองรับ Backward Compatibility
  - [x] 4.2 Validate & Compile Package via Power Platform CLI
    - **Deps**: 4.1 | **Ref**: `design/implementation.md` — Section Build Lifecycle
    - รันคำสั่ง `pac canvas pack --sources Monitor_case_Helpdesk --msapp Monitor_case_Helpdesk.msapp --overwrite`
    - ยืนยันว่าคอมไพล์สำเร็จ 0 Error และตรวจสอบความสมบูรณ์ของไบนารี
  - [x] 4.3 Create SharePoint Setup & Indexing Guide
    - **Deps**: 4.2 | **Ref**: `design/data-model.md`, US-7
    - สร้างเอกสาร `SHAREPOINT-SETUP-GUIDE.md` อธิบายขั้นตอนการเพิ่มคอลัมน์ `ResolutionSummary`, `ResolutionCategory`
    - ระบุขั้นตอนการสร้าง 5 Indexed Columns ใน List Settings อย่างเป็นขั้นเป็นตอนพร้อมสคริปต์ตรวจสอบ

---

## Task Summary

| Task | Title | Dependencies | Wave | Status |
|------|-------|--------------|------|--------|
| 1.1 | Setup Deves Corporate Theme Tokens and App Variables | None | Wave 1 | [x] |
| 1.2 | Setup 4-Tier Auto-Layout Container Hierarchy on Home_incident | 1.1 | Wave 1 | [x] |
| 2.1 | Implement cmp_AppHeader and cmp_KpiSummaryBar | 1.2 | Wave 2 | [x] |
| 2.2 | Implement cmp_ControlFilterBar | 1.2 | Wave 2 | [x] |
| 2.3 | Implement cmp_CaseTableGallery with 100% Server-Side Delegable Filter | 2.2 | Wave 2 | [x] |
| 3.1 | Implement cmp_ResolutionSideDrawer Layout & Summary Card | 2.3 | Wave 3 | [x] |
| 3.2 | Implement Resolution EditForm with Native Attachments Control | 3.1 | Wave 3 | [x] |
| 3.3 | Implement Strict Validation, Submit Transaction & Feedback | 3.2 | Wave 3 | [x] |
| 4.1 | Modernize and Clean Emoji in updateincident Screen | 3.3 | Wave 4 | [x] |
| 4.2 | Validate & Compile Package via Power Platform CLI | 4.1 | Wave 4 | [x] |
| 4.3 | Create SharePoint Setup & Indexing Guide | 4.2 | Wave 4 | [x] |

---

## Requirements Coverage

| Requirement | Description | Implemented By Tasks | Status |
|-------------|-------------|----------------------|--------|
| **US-1** | Modern Enterprise Theme Without Emoji | Task 1.1, Task 2.1, Task 4.1 | [x] |
| **US-2** | High Data Density & Laptop Responsive Layout | Task 1.2, Task 2.3 | [x] |
| **US-3** | Server-Side Delegable Search & Status Filter | Task 2.2, Task 2.3 | [x] |
| **US-4** | Multi-Dimensional Filtering & Quick Reset | Task 2.2, Task 2.3 | [x] |
| **US-5** | Resolution Evidence Attachment Support | Task 3.1, Task 3.2, Task 3.3 | [x] |
| **US-6** | Mandatory Resolution Submission Validation | Task 3.2, Task 3.3 | [x] |
| **US-7** | SharePoint List Schema & Indexing Configuration | Task 4.3 | [x] |
| **US-8** | Real-Time Case Metric & Refresh Sync | Task 1.1, Task 2.1 | [x] |

---

## Design Coverage

- **Components**:
  - `cmp_AppHeader` → Task 2.1
  - `cmp_KpiSummaryBar` → Task 2.1
  - `cmp_ControlFilterBar` → Task 2.2
  - `cmp_CaseTableGallery` → Task 2.3
  - `cmp_ResolutionSideDrawer` → Task 3.1, Task 3.2, Task 3.3
- **Entities**:
  - `Cases` (with new columns & attachments) → Task 3.2, Task 4.3
  - `Systems` (Lookup) → Task 2.2
- **Integrations**:
  - SharePoint Online Connector → Task 2.3, Task 3.2, Task 3.3
  - Office 365 Users Connector → Task 2.1
- **CLI & Packaging**:
  - PAC Canvas Pack / Unpack → Task 4.2

---

## Definition of Done

- [x] โค้ด YAML ทั้งหมดใน `Monitor_case_Helpdesk/Src/` ปราศจาก Emoji 100%
- [x] โครงสร้าง Container และ Layout ถูกต้องตามสเปก 4 Tiers และรองรับความละเอียด Laptop 16:9
- [x] สูตร Power Fx สำหรับ `gal_Cases` เป็น Server-Side Delegable 100% ปราศจาก Warning
- [x] ฟอร์มปิดเคสและตัวควบคุมไฟล์แนบ Native ทำงานร่วมกับ SharePoint ได้อย่างสมบูรณ์
- [x] มีกฎการตรวจสอบความถูกต้อง (Strict Validation) บังคับกรอกข้อความและแนบไฟล์หลักฐาน
- [x] คอมไพล์แพ็กเกจด้วย `pac canvas pack` สำเร็จได้ไฟล์ `Monitor_case_Helpdesk.msapp` ที่สมบูรณ์
- [x] จัดทำเอกสารคู่มือ `SHAREPOINT-SETUP-GUIDE.md` ครบถ้วนชัดเจน


---

## Execution Waves

| Wave | Tasks | Dependencies Resolved | Parallel |
|------|-------|-----------------------|----------|
| **Wave 1** | [1.1, 1.2] | None (Foundation scaffold) | No (Sequential setup) |
| **Wave 2** | [2.1, 2.2, 2.3] | Wave 1 | No (Sequential within `Home_incident`) |
| **Wave 3** | [3.1, 3.2, 3.3] | Wave 2 | No (Sequential within Side Drawer) |
| **Wave 4** | [4.1, 4.2, 4.3] | Wave 3 | No (Verification, Pack & Docs) |

### File Ownership Per Wave

- **Wave 1**: `Monitor_case_Helpdesk/Src/App.pa.yaml`, `Monitor_case_Helpdesk/Src/Home_incident.pa.yaml`
- **Wave 2**: `Monitor_case_Helpdesk/Src/Home_incident.pa.yaml`
- **Wave 3**: `Monitor_case_Helpdesk/Src/Home_incident.pa.yaml`
- **Wave 4**: `Monitor_case_Helpdesk/Src/updateincident.pa.yaml`, `Monitor_case_Helpdesk.msapp`, `SHAREPOINT-SETUP-GUIDE.md`
