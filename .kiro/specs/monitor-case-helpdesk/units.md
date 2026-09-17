# หน่วยงานสถาปัตยกรรม (Units of Work) — Monitor_case_Helpdesk

## สรุปภาพรวม (Summary)
- **Units**: 2 Units — `dashboard-filter`, `case-resolution`
- **Strategy**: Domain-Driven Decomposition (แยกตามขอบเขตงานการมอนิเตอร์/กรองข้อมูล และการจัดการปิดเคส/หลักฐาน)
- **Architecture**: Single-Screen Master-Detail Canvas App with Server-Side SharePoint Delegation & Native Attachments
- **Story Distribution**:
  - `dashboard-filter`: 5 Stories (`US-001`, `US-002`, `US-003`, `US-004`, `US-007`)
  - `case-resolution`: 3 Stories (`US-005`, `US-006`, `US-008`)
- **Key Dependencies**: `case-resolution` ขึ้นอยู่กับ `dashboard-filter` (รับ `SelectedCase` จากตารางรายการ และแชร์ Container บนหน้าจอ `Home_incident`)
- **Development Sequence**: 
  - Phase 1: `dashboard-filter` (สร้างหน้าตาราง Modern ไร้ Emoji + Delegable Filter + KPI Bar)
  - Phase 2: `case-resolution` (สร้าง Side Drawer + แนบหลักฐาน + กฎการปิดเคส + SharePoint Schema)

---

## ภาพรวมสถาปัตยกรรม (Overview)
ระบบ **Monitor_case_Helpdesk** ได้รับการแบ่งสถาปัตยกรรมออกเป็น 2 หน่วยงานหลัก (Units of Work) เพื่อให้สามารถแยกการพัฒนา ทดสอบประสิทธิภาพการโหลดข้อมูล และส่งมอบให้ผู้ใช้งานได้อย่างเป็นระบบและรวดเร็ว

**Strategy**: Domain-Driven Decomposition  
**Rationale**: 
1. แยกส่วนการสืบค้นข้อมูลจำนวนมาก (High-Volume Read & Filter) ออกจากส่วนการบันทึกแก้ไขและอัปโหลดไฟล์ (Write & Binary Attachment) เพื่อให้แต่ละส่วนมีหน้าที่รับผิดชอบชัดเจน (Single Responsibility)
2. ช่วยให้ทีมปฏิบัติการได้ใช้งานหน้าจอ UI ใหม่ที่ไม่มี Emoji และค้นหาข้อมูลเร็วขึ้นก่อนในเฟสแรก โดยไม่ต้องรอให้การปรับแต่งฟอร์มแนบไฟล์เสร็จทั้งหมด

---

## Unit 1: dashboard-filter (Modern Dashboard & Delegable Filtering)

**Purpose**: จัดการหน้าจอหลัก `Home_incident` ให้เป็น Modern Enterprise UI ปราศจาก Emoji, แสดงตารางเคสแบบ Dense Grid บนหน้าจอ Laptop, แสดงการ์ด KPI Metrics Bar และประมวลผลสูตรการกรองข้อมูลแบบ Server-Side Delegable 100%  
**Priority**: High  
**Complexity**: Medium  
**Stories**: 5 Stories — `US-001`, `US-002`, `US-003`, `US-004`, `US-007`  

### คำสั่งการทำงาน (Commands)
| คำสั่ง (Command) | หน้าที่ | ผู้สั่งการ (Actor) |
|---|---|---|
| `SelectStatusFilter` | กรองเคสตามแท็บสถานะ (Open, In Progress, Resolved, All) | IT Support / Supervisor |
| `SelectSystemFilter` | กรองเคสเฉพาะระบบงานที่เลือกผ่าน Dropdown | IT Support / Supervisor |
| `SearchKeyword` | ค้นหาเคสด้วย CaseID หรือหัวข้อเรื่องผ่าน `StartsWith` | IT Support / Supervisor |
| `ClearAllFilters` | ล้างเงื่อนไขการกรองและคำค้นหาทั้งหมดกลับสู่ค่าเริ่มต้น | IT Support / Supervisor |
| `ClickKPICard` | กรองตารางตามเงื่อนไขของการ์ดตัวชี้วัด (เช่น ดูเฉพาะเคสหลุด SLA) | IT Support / Supervisor |
| `SelectCaseRow` | เลือกเคสในตารางเพื่อส่งสัญญาณเปิด Side Drawer ทางขวา | IT Support |

### โมเดลข้อมูล (Domain Model)
- **Aggregates**: `CaseListAggregate` (Root Entity: `Cases`)
- **Entities**:
  - `CaseHeader`: รหัสเคส (`CaseID`), หัวข้อเรื่อง (`Title`), ระบบ (`SystemName`), สถานะ (`Statuscase`), ระดับความสำคัญ (`Priority`, `Severity`), ผู้รับผิดชอบ (`AssignedOwner`), วันที่สร้าง/กำหนด SLA (`Created`, `SlaDueDate`)
  - `KPISummary`: ข้อมูลสรุปนับจำนวนเคสตามสถานะและ SLA
- **Value Objects**:
  - `CaseStatusPill`: สีและข้อความสถานะตามมาตรฐาน Fluent UI
  - `SLAStatusBadge`: ตัวชี้วัดสถานะ SLA (Normal, Near Breach, Breached)
  - `FilterCriteria`: ชุดตัวแปรเงื่อนไขการกรองปัจจุบัน

### อีเวนต์ของระบบ (Domain Events)
- **Publishes**: 
  - `CaseSelectedForDetail`: เมื่อผู้ใช้คลิกเลือกเคสในตาราง → ส่ง Object เคส (`varSelectedCase`) ไปยัง Unit 2
- **Subscribes**: 
  - `CaseResolved`: เมื่อ Unit 2 บันทึกปิดเคสสำเร็จ → Unit 1 อัปเดตแถวข้อมูลในตารางและรีเฟรช KPI Counter

### การพึ่งพา (Dependencies)
| ขึ้นอยู่กับ (Depends On) | ประเภท | รายละเอียด |
|---|---|---|
| SharePoint List `Cases` | Data / Connector | ใช้เชื่อมต่อและ Query ข้อมูลแบบ Delegable |
| SharePoint List `Routing` | Data / Master | ดึงรายชื่อระบบงาน (`SystemName`) มาใส่ในตัวเลือก Dropdown |

---

## Unit 2: case-resolution (Case Resolution, Evidence Attachment & Schema)

**Purpose**: จัดการ Side Drawer ทางฝั่งขวาสำหรับตรวจสอบรายละเอียดเคส, อัปโหลดและแสดงผลไฟล์หลักฐานประกอบการปิดเคส (SharePoint Native Attachments), ตรวจสอบกฎความสมบูรณ์ก่อนปิดเคส (Strict Validation), และจัดเตรียมโครงสร้างข้อมูล SharePoint (`ResolutionSummary`, `ResolutionCategory`, Indexed Columns)  
**Priority**: High  
**Complexity**: Medium  
**Stories**: 3 Stories — `US-005`, `US-006`, `US-008`  

### คำสั่งการทำงาน (Commands)
| คำสั่ง (Command) | หน้าที่ | ผู้สั่งการ (Actor) |
|---|---|---|
| `AssignCaseToMe` | รับเคสมาเป็นผู้ดูแล (`AssignedOwner = varCurrentUser.FullName`, สถานะ = In Progress) | IT Support |
| `UploadEvidenceFile` | เลือกและแนบไฟล์หลักฐาน (Screenshot/Log/PDF) เข้าสู่ฟอร์ม | IT Support |
| `RemoveEvidenceFile` | ลบไฟล์หลักฐานที่เลือกออกจากรายการก่อนกดบันทึก | IT Support |
| `SubmitCaseResolution` | ตรวจสอบความถูกต้อง บันทึกปิดเคส อัปโหลดไฟล์แนบ และประทับเวลา Resolved | IT Support |
| `CloseSideDrawer` | พับเก็บ Side Drawer เพื่อให้ตารางรายการขยายเต็มจอ | IT Support / Supervisor |

### โมเดลข้อมูล (Domain Model)
- **Aggregates**: `CaseResolutionAggregate` (Root Entity: `Cases`)
- **Entities**:
  - `CaseDetail`: ข้อมูลเชิงลึกของเคส (รายละเอียดปัญหา `ProblemDetail`, บทสนทนา `ConversationSummary`, ผู้แจ้ง `ReporterName`/`ReporterEmail`)
  - `CaseAttachment`: รายการไฟล์หลักฐาน (File Name, File Size, Relative/Absolute URI)
- **Value Objects**:
  - `ResolutionSummary`: ข้อความสรุปแนวทางแก้ไขปัญหา (Multiple lines text)
  - `ResolutionCategory`: ประเภทของแนวทางแก้ไข (Choice)
  - `ResolutionMetadata`: เวลาปิดงาน (`ResolvedAt`), ผู้ปิดงาน (`Editor`)

### อีเวนต์ของระบบ (Domain Events)
- **Publishes**: 
  - `CaseResolved`: เมื่อบันทึกปิดงานสำเร็จ → ส่งสัญญาณแจ้ง Unit 1 รีเฟรชตาราง และทริกเกอร์ Flow แจ้งเตือนผู้แจ้ง
- **Subscribes**: 
  - `CaseSelectedForDetail`: รับข้อมูลเคสจาก Unit 1 เมื่อผู้ใช้คลิกเลือกแถวในตาราง → ผูกข้อมูลเข้ากับ Form และ Attachment Control

### การพึ่งพา (Dependencies)
| ขึ้นอยู่กับ (Depends On) | ประเภท | รายละเอียด |
|---|---|---|
| Unit 1 (`dashboard-filter`) | UI & Context | ใช้พื้นที่ฝั่งขวาของหน้าจอ `Home_incident` และรับ Record Context จากตาราง |
| SharePoint List `Cases` | Data & Storage | บันทึกฟิลด์สถานะและจัดเก็บไฟล์แนบใน SharePoint Item Attachments |

---

## แผนที่บริบท (Context Map)

### ความสัมพันธ์ระหว่าง Units (Relationships)
| หน่วยต้นทาง (Upstream) | หน่วยปลายทาง (Downstream) | รูปแบบความสัมพันธ์ (Pattern) |
|---|---|---|
| Unit 1 (`dashboard-filter`) | Unit 2 (`case-resolution`) | **Customer / Supplier**: Unit 1 ส่ง `varSelectedCase` และควบคุมการแสดงผล Drawer ให้ Unit 2 |
| Unit 2 (`case-resolution`) | Unit 1 (`dashboard-filter`) | **Publisher / Subscriber**: Unit 2 ส่งสัญญาณอีเวนต์ `CaseResolved` ให้ Unit 1 อัปเดตตาราง |

---

## ลำดับขั้นตอนการพัฒนา (Development Sequence)

### เฟสที่ 1: Schema & Foundation Setup
- [ ] ตั้งค่า SharePoint List `Cases`: เพิ่มคอลัมน์ `ResolutionSummary`, `ResolutionCategory` และสร้าง Index (Statuscase, Created, CaseID, SystemName, AssignedOwner) ตาม US-008

### เฟสที่ 2: Unit 1 — Modern Dashboard & Delegable Filtering
- [ ] ปรับ Theme และถอด Emoji ทั้งหมดบนหน้าจอ `Home_incident` (US-001)
- [ ] สร้างตาราง Dense Grid สำหรับ Laptop พร้อมแถบ KPI Metrics Bar (US-002, US-007)
- [ ] ปรับสูตรการค้นหาและตัวกรองให้เป็น Delegable Server-Side Query 100% (US-003, US-004)

### เฟสที่ 3: Unit 2 — Case Resolution & Evidence Attachment
- [ ] สร้าง Side Drawer Component บนหน้าจอ `Home_incident` (US-002)
- [ ] ติดตั้งและปรับแต่งส่วนควบคุมการแนบไฟล์หลักฐาน (Native Attachment Control) (US-005)
- [ ] ใส่เงื่อนไข Strict Validation บังคับระบุแนวทางแก้ไขและแนบไฟล์ก่อนปิดเคส (US-006)
- [ ] ทดสอบกระบวนการปิดเคส บันทึกข้อมูลลง SharePoint และส่งอีเมลแจ้งผู้ใช้ครบวงจร

---

## การบริหารความเสี่ยง (Risks & Mitigation)

| ความเสี่ยง (Risk) | ผลกระทบ | แผนรองรับและแก้ไข (Mitigation) |
|---|---|---|
| **Delegation Warning ใน Power Apps** | สูง | ใช้เฉพาะฟังก์ชันที่ SharePoint รองรับ Delegation (`StartsWith`, `=`, `>=`, `<=`) และห้ามใช้ฟังก์ชันกลุ่มแปลงข้อความที่ซับซ้อนในตัวกรองหลัก |
| **ไฟล์แนบมีขนาดใหญ่เกินไป** | ปานกลาง | ตั้งค่าจำกัดขนาดไฟล์ไม่เกิน 15 MB บนส่วนควบคุม และแนะนำให้แนบไฟล์รูปภาพหรือ PDF ขนาดเหมาะสม |
| **ความกว้างหน้าจอ Laptop ไม่พอ** | ปานกลาง | ออกแบบ Side Drawer ให้สามารถพับเก็บ (Collapse) ได้ และใช้ Auto-layout Container เพื่อให้ยืดหยุ่นตามความละเอียดหน้าจอ |
