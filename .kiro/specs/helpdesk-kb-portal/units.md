# Units of Work: Helpdesk Knowledge Base Management Portal

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Units**: 2 units — `portal-shell-manuals`, `portal-qna-gaps`
- **Strategy**: Module-Based Decomposition (Desktop 16:9 Shell & Document Library Layer vs Q&A Knowledge & Gap-to-KB Learning Layer)
- **Architecture**: Power Apps Canvas App (Desktop 16:9 Widescreen) connected to SharePoint Online (`SystemManuals`, `AI_KnowledgeBase`, `Systems`, `KnowledgeGaps`) via OData & Power Automate
- **Story Distribution**: Unit 1 (portal-shell-manuals): 5 stories | Unit 2 (portal-qna-gaps): 3 stories (Total 8 stories)
- **Key Dependencies**: Unit 2 (`portal-qna-gaps`) → Unit 1 (`portal-shell-manuals`) [UI Shell & Role Context Dependency]
- **Development Sequence**: Phase 1: Unit 1 (`portal-shell-manuals`), Phase 2: Unit 2 (`portal-qna-gaps`)

---

## Overview
แอปพลิเคชัน **Helpdesk Knowledge Base Management Portal** ถูกแบ่งการส่งมอบออกเป็น 2 หน่วยงาน (Units of Work) เพื่อให้สามารถพัฒนาและทดสอบรากฐานของหน้าจอ Desktop 16:9 และระบบไฟล์คู่มือก่อน จากนั้นจึงนำโมดูลการจัดการข้อคำถาม-คำตอบและกระบวนการเรียนรู้ของ AI เข้ามาประกอบอย่างไร้รอยต่อ

**Strategy**: Module-Based Decomposition  
**Rationale**:
1. **Separation of Concerns**: แยกการบริหารจัดการไฟล์เอกสารไบนารีและโฟลเดอร์ (Document Library Layer) ออกจากการจัดการตารางข้อมูลข้อความคำถาม-คำตอบ (Structured Q&A Grid)
2. **Reusability of Foundation**: Unit 1 สร้างโครงสร้างหน้าจอหลัก 4-Tier, การตรวจจับสิทธิ์ผู้ใช้ (RBAC Context), และการ์ดตัวชี้วัด KPI รวมศูนย์ ซึ่งเป็นโครงสร้างที่ Unit 2 ต้องนำไปใช้แสดงผล
3. **Low Complexity & Predictable Delivery**: การแบ่ง 2 Units สอดคล้องกับขนาดทีม Low-Code และง่ายต่อการทดสอบทีละโมดูล

---

## Unit 1: `portal-shell-manuals`

**Purpose**: พัฒนาโครงสร้างหน้าจอหลัก 4-Tier Desktop 16:9, แถบ Header นำทาง, KPI Summary Cards, การตรวจสอบสิทธิ์ RBAC, และโมดูลบริหารจัดการคลังคู่มือระบบ `SystemManuals` (โฟลเดอร์ระบบ, การสร้างโฟลเดอร์ใหม่, การอัปโหลดคู่มือพร้อม Metadata และการคุมสถานะ)  
**Priority**: High  
**Complexity**: Medium  
**Stories**: 5 stories — `US-PORTAL-001`, `US-PORTAL-002`, `US-PORTAL-003`, `US-PORTAL-004`, `US-PORTAL-008`  

### Commands & Operations
| Command / Operation | Description | Actor |
|---------------------|-------------|-------|
| `SwitchPortalTab` | สลับการแสดงผลระหว่าง 3 แท็บโมดูลหลักบน Header Bar | All Personas |
| `CalculateKPISummary` | คำนวณยอดรวมคู่มือ, ยอด Approved, ยอด Q&A และ Gaps แบบเรียลไทม์ | System / App.OnStart |
| `CreateSystemFolder` | เรียก Flow เพื่อสร้างโฟลเดอร์ระบบใหม่ใน Document Library `SystemManuals` | IT Helpdesk Admin |
| `UploadManualDocument` | อัปโหลดไฟล์คู่มือใหม่ (PDF/Word) พร้อมระบุ Metadata และคุมสถานะ Approved | IT Helpdesk Admin / BA |
| `ArchiveManualDocument` | ปรับสถานะคู่มือเป็น `Archived` เพื่อระงับไม่ให้ AI นำไปตอบ | IT Helpdesk Admin / BA |
| `EnforceRBACSecurity` | ตรวจสอบสิทธิ์ผู้ใช้ ซ่อนปุ่มแก้ไข/ลบ สำหรับพนักงานทั่วไป | System |

### Domain Model
- **Aggregates**:
  - `ManualDocument` (Root: `SystemManuals` Item): `Title`, `FileLeafRef`, `SystemName`, `DocType`, `Status`, `Keywords`, `Version`
  - `MasterSystem` (Root: `Systems` Item): `Title`, `Code`, `IsActive`, `DisplayOrder`
  - `UserSecurityContext`: `CurrentUserEmail`, `IsAdmin`, `CanEdit`, `CanApprove`

### Domain Events
- **Publishes**:
  - `SystemFolderCreated`: แจ้งเตือนเมื่อโฟลเดอร์ระบบใหม่ถูกสร้างขึ้นสำเร็จ เพื่อรีเฟรชตารางโฟลเดอร์
  - `ManualUploaded`: ส่งสัญญาณเมื่อมีคู่มือใหม่ถูกอัปโหลด เพื่อให้คำนวณ KPI Bar ใหม่
- **Subscribes**: ไม่มี (เป็นหน่วยงานรากฐาน)

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| Master List `Systems` | Reference Data | ใช้อ้างอิงรายชื่อระบบมาตรฐาน 31 ระบบสำหรับ Dropdown ในฟอร์ม |
| SharePoint `SystemManuals` | Data Store | Document Library เป้าหมายสำหรับการจัดเก็บไฟล์ |
| CreateFolder Flow | Power Automate | Cloud Flow สำหรับสั่งสร้างโฟลเดอร์บน SharePoint |

---

## Unit 2: `portal-qna-gaps`

**Purpose**: พัฒนาโมดูลบริหารจัดการข้อคำถาม-คำตอบ (`AI_KnowledgeBase`) ในรูปแบบตาราง High-Density ความสูงแถว 44px, กล่องค้นหาทันใจ, ปุ่ม Quick Toggle สลับ Active/Inactive, Sliding Side Drawer สำหรับเพิ่ม/แก้ไข Q&A, และโมดูลแปลงคำถามที่ AI ตอบไม่ได้ (`KnowledgeGaps`) เข้าสู่ Q&A ใน 1 คลิก  
**Priority**: High  
**Complexity**: Medium  
**Stories**: 3 stories — `US-PORTAL-005`, `US-PORTAL-006`, `US-PORTAL-007`  

### Commands & Operations
| Command / Operation | Description | Actor |
|---------------------|-------------|-------|
| `SearchFilterQnA` | ค้นหาข้อคำถาม-คำตอบและกรองตามระบบ/สถานะแบบ Server-Side Delegable | All Personas |
| `ToggleQnAStatus` | สลับสถานะข้อคำถามระหว่าง `Active` และ `Inactive` ทันทีในแถวตาราง | IT Helpdesk Admin |
| `OpenQnADrawer` | เปิดหน้าต่าง Side Drawer ด้านขวาสำหรับ เพิ่ม หรือ แก้ไข รายการ Q&A | IT Helpdesk Admin / BA |
| `SaveQnAEntry` | บันทึกข้อมูลคำถาม-คำตอบ (Title, Question, Answer, System, Category, Keywords) | IT Helpdesk Admin / BA |
| `DeleteQnAEntry` | แสดงกล่องยืนยันและสั่งลบข้อคำถามออกจาก SharePoint List | IT Helpdesk Admin |
| `ConvertGapToQnA` | ดึงคำถามจาก `KnowledgeGaps` เข้าสู่แบบฟอร์ม Q&A ทันที และมาร์กเป็น Resolved เมื่อบันทึก | IT Helpdesk Admin |

### Domain Model
- **Aggregates**:
  - `QnAEntry` (Root: `AI_KnowledgeBase` Item): `Title`, `Question`, `Answer`, `System`, `Category`, `Keywords`, `Status`
  - `KnowledgeGap` (Root: `KnowledgeGaps` Item): `UserQuery`, `Frequency`, `LastAsked`, `Status` (Pending/Resolved)

### Domain Events
- **Publishes**:
  - `QnAStatusToggled`: ส่งสัญญาณเมื่อมีการเปิด/ปิดคำถาม เพื่อรีเฟรช KPI Cards Bar
  - `GapResolved`: ส่งสัญญาณเมื่อมีการแปลง Gap สำเร็จ เพื่อลดจำนวน Pending Gaps บน KPI Bar
- **Subscribes**:
  - `UserSecurityContext` จาก Unit 1: ใช้อ้างอิงสิทธิ์ในการแสดงหรือซ่อนปุ่มแก้ไข/ลบ

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| Unit 1 (`portal-shell-manuals`) | UI Shell & Context | ต้องการโครงสร้าง Layout 16:9, Header Tab Navigation, และตัวแปรสิทธิ์กลาง |
| SharePoint `AI_KnowledgeBase` | Data Store | SharePoint List สำหรับจัดเก็บ Q&A 74 รายการ |
| SharePoint `KnowledgeGaps` | Data Store | SharePoint List สำหรับดึงคำถามที่ตอบไม่ได้ |

---

## Context Map

### Relationships
| Upstream (Supplier) | Downstream (Customer) | Pattern | Description |
|---------------------|-----------------------|---------|-------------|
| Unit 1: `portal-shell-manuals` | Unit 2: `portal-qna-gaps` | Shared Kernel / Customer | Unit 1 ส่งมอบ Global State (`varCurrentTab`, `varUserRole`, KPI Collections) ให้ Unit 2 ใช้ร่วมกัน |
| Master List `Systems` | Unit 1 & Unit 2 | Reference Data | ทั้ง 2 หน่วยงานใช้รายชื่อระบบชุดเดียวกันเพื่อความสอดคล้อง |

---

## Development Sequence

### Phase 1: Shell & Manuals Foundation (Unit 1)
- [ ] 1.1 สร้างโครงสร้างหน้าจอหลัก Desktop 16:9 (4-Tier Container Layout)
- [ ] 1.2 พัฒนา Header Bar และระบบสลับแท็บโมดูล (Tabs Navigation)
- [ ] 1.3 พัฒนาแถบ KPI Summary Bar ดึงข้อมูลสถิติแบบเรียลไทม์
- [ ] 1.4 พัฒนาระบบตรวจสอบสิทธิ์ RBAC (Admin vs Read-only Viewer)
- [ ] 1.5 พัฒนาแท็บแสดงโฟลเดอร์ระบบงานและปุ่มสร้างโฟลเดอร์ใหม่ผ่าน Flow
- [ ] 1.6 พัฒนาระบบอัปโหลดคู่มือใหม่ พร้อม Metadata Tagging และการควบคุมสถานะ Approved

### Phase 2: Q&A Management & Gap-to-KB Learning Loop (Unit 2)
- [ ] 2.1 พัฒนาตาราง High-Density Q&A Grid (ความสูงแถว 44px) และกล่องค้นหา Delegable
- [ ] 2.2 พัฒนาปุ่ม Quick Toggle สลับสถานะ `Active`/`Inactive` ในแถวตาราง
- [ ] 2.3 พัฒนา Sliding Side Drawer สำหรับการเพิ่ม/แก้ไข Q&A พร้อมกล่องยืนยันการลบ
- [ ] 2.4 พัฒนาแท็บ Knowledge Gaps และระบบปุ่ม 1-Click "Convert to Q&A"
- [ ] 2.5 เชื่อมโยงการอัปเดตสถานะของ Gaps เป็น `Resolved` เมื่อบันทึกสำเร็จ

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| SharePoint Folder Creation Limitations | Medium | ใช้ Instant Cloud Flow สั้นๆ ช่วยสร้างโฟลเดอร์ แทนการเขียน Power Fx โดยตรง |
| Delegation Warnings on Large Datasets | Medium | ใช้เฉพาะฟังก์ชันที่ Delegable 100% (`Filter`, `SortByColumns`, `StartsWith`) และทำ Index ให้คอลัมน์สำคัญ |
| File Upload Size Overload | Low | กำหนดขีดจำกัดขนาดไฟล์ไม่เกิน 50MB และรองรับเฉพาะนามสกุลเอกสารที่ปลอดภัย (PDF, Word, Excel, PPTX) |
