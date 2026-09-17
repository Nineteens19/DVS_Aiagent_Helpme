# Components Specification — Monitor_case_Helpdesk

## Overview
แอปพลิเคชันได้รับการออกแบบสถาปัตยกรรม UI เป็น **Single-Screen Master-Detail with Collapsible Side Drawer** บนหน้าจอ `Home_incident` โดยแบ่งเป็น 5 คอมโพเนนต์หลักที่จัดวางตาม 4-Tier Auto-Layout Container Hierarchy เพื่อให้รองรับการทำงานความหนาแน่นข้อมูลสูง (High Data Density) บนจอ Laptop 16:9

---

## Component Breakdown

### 1. cmp_AppHeader (Top Navigation & Context Bar)
**Purpose**: แสดงส่วนหัวของระบบ บ่งบอกตัวตนองค์กร บัญชีผู้ใช้งาน และสถานะการซิงค์ข้อมูลเคสล่าสุด
**Technology**: Power Apps Container + Fluent Label / Icon
**Tier**: Tier 1 (Fixed Height: 56px, Width: Parent.Width)

**Responsibilities**:
- แสดงชื่อระบบภาษาทางการ: `ระบบบริหารจัดการเคสไอที (IT Helpdesk Case Monitor)` (ปราศจาก Emoji 100%)
- แสดงโลโก้และสัญลักษณ์องค์กรในโทนสี Deves Deep Navy (`#012169`)
- แสดงชื่อและรูปโปรไฟล์ผู้ใช้งานปัจจุบัน (`User().FullName`, `User().Image`)
- แสดงเวลาอัปเดตข้อมูลล่าสุด (`varLastRefreshedTime`)
- ปุ่มกดโหลดข้อมูลใหม่ (Manual Refresh) เรียก `Refresh(Cases)`

**Exposes**:
- `OnRefreshClick`: อัปเดต `varLastRefreshedTime = Now()` และ `Refresh(Cases)`

**Internal Structure**:
```
con_Header/
  ├── img_Logo
  ├── lbl_AppTitle ("ระบบบริหารจัดการเคสไอที")
  ├── con_HeaderRight/
  │     ├── icn_Refresh
  │     ├── lbl_LastRefresh ("อัปเดตล่าสุด: ...")
  │     ├── img_UserProfile
  │     └── lbl_UserName
```

---

### 2. cmp_KpiSummaryBar (Metric Summary Cards)
**Purpose**: แสดงภาพรวมสถิติเคสที่สำคัญ 5 ตัวชี้วัดในรูปแบบ Card แนวนอน ช่วยให้ผู้ดูแลระบบมองเห็นสถานการณ์ภาพรวมได้ทันที
**Technology**: Power Apps Horizontal Layout Container + KPI Cards
**Tier**: Tier 2 (Fixed Height: 84px, Width: Parent.Width)

**Responsibilities**:
- คำนวณและแสดงผล 5 KPI Cards:
  1. เคสทั้งหมด (Total Cases)
  2. เคสใหม่/รอดำเนินการ (Open)
  3. กำลังดำเนินการ (In Progress)
  4. ปิดเคสสำเร็จวันนี้ (Resolved Today)
  5. เกินกำหนดเวลา SLA (SLA Breached - ค้างเกิน 48 ชม.)
- กดที่ Card เพื่อทำ Quick Filter ไปยังสถานะนั้นๆ ได้ทันที

**Exposes**:
- `OnSelectKpiCard(status)`: ตั้งค่า `varSelectedStatus = status` เพื่อกรองข้อมูลตารางทันที

**Design Tokens**:
- การ์ดพื้นหลังสีขาว กรอบ `#E2E8F0` รัศมีขอบมน 6px
- ตัวเลขสถิติขนาด 24px Font SemiBold, Label หัวการ์ดขนาด 11px เทา Slate `#64748B`

---

### 3. cmp_ControlFilterBar (Filter & Search Control Bar)
**Purpose**: แถบควบคุมตัวกรองข้อมูลหลายมิติที่ผูกตรงกับการประมวลผล Delegable บน SharePoint Server
**Technology**: Power Apps Horizontal Container + Status Buttons + ComboBox + TextInput
**Tier**: Tier 3 (Fixed Height: 52px, Width: Parent.Width)

**Responsibilities**:
- **Status Filter Segment**: ปุ่มกดสลับสถานะ (ทั้งหมด / รอดำเนินการ / กำลังดำเนินการ / ปิดงานแล้ว) ไร้ Emoji
- **System Dropdown Filter**: `cmb_SystemFilter` ดึงรายชื่อระบบจาก SharePoint List `Systems`
- **Keyword Search Input**: `txt_Search` ค้นหารหัสเคส (`CaseID`) หรือหัวเรื่อง (`Title`)
- **Clear All Filter**: `btn_ClearFilters` รีเซ็ตตัวกรองทั้งหมดกลับสู่ค่าเริ่มต้น

**State Variables**:
- `varSelectedStatus`: ค่าสถานะที่เลือก (`"All"`, `"Open"`, `"In Progress"`, `"Resolved"`)
- `cmb_SystemFilter.Selected.Value`: ระบบที่เลือก
- `txt_Search.Text`: คำค้นหา

---

### 4. cmp_CaseTableGallery (Dense Case Grid Gallery)
**Purpose**: ตารางแสดงรายการเคสแบบความหนาแน่นสูง (High Data Density) ปรับแต่งให้เหมาะสมกับจอ Laptop
**Technology**: Power Apps Flexible Height / Fixed Row Gallery (TemplateHeight: 44px)
**Tier**: Tier 4 Left Pane (Width: `If(varShowDrawer, Parent.Width - 480, Parent.Width)`)

**Responsibilities**:
- แสดงรายการเคสด้วยสูตร Delegable Filter (รองรับเกิน 2,000 แถว ไม่มี Delegation Warning)
- หัวตาราง (Table Header) ชัดเจน: รหัสเคส, ระบบงาน, หัวเรื่อง, ผู้รับผิดชอบ, วันที่แจ้ง, สถานะ, การจัดการ
- แถวตารางสูง 44px (Compact Row) รองรับการแสดงผล 12-15 แถวต่อหน้าจอ Laptop
- แสดง Status Badge เป็นทรง Pill Shape ตาม Deves Fluent Design Tokens:
  - `Open`: พื้นหลัง `#F1F5F9`, ตัวอักษร `#475569`
  - `In Progress`: พื้นหลัง `#FEF3C7`, ตัวอักษร `#B45309`
  - `Resolved`: พื้นหลัง `#D1FAE5`, ตัวอักษร `#047857`
  - `SLA Breached`: พื้นหลัง `#FFE4E6`, ตัวอักษร `#BE123C`
- Hover state เปลี่ยนสีแถวเพื่อให้อ่านง่าย
- ปุ่ม "ดูรายละเอียด / ปิดเคส" เพื่อเลือกเคสและเปิด Side Drawer

**Exposes**:
- `OnSelectRow`: `Set(varSelectedCase, ThisItem); Set(varShowDrawer, true); ViewForm(frm_CaseDetail); EditForm(frm_CaseResolution);`

---

### 5. cmp_ResolutionSideDrawer (Collapsible Resolution Drawer)
**Purpose**: หน้าต่างสไลด์ด้านข้างสำหรับตรวจสอบรายละเอียดและดำเนินการบันทึกปิดเคสพร้อมแนบหลักฐาน
**Technology**: Power Apps Vertical Container (Width: 480px, Height: Parent.Height - 192px)
**Tier**: Tier 4 Right Pane (Visible: `varShowDrawer`)

**Responsibilities**:
- สลับเปิด-ปิดอย่างนุ่มนวล โดยไม่ทำให้หน้าจอหลักสูญเสียบริบทหรือตัวกรองที่เลือกไว้
- แสดงข้อมูลสรุปของเคสที่เลือก (รหัสเคส, ผู้แจ้ง, รายละเอียดปัญหา, เวลาที่บันทึก)
- ฟอร์มปิดงานเคส (`frm_CaseResolution`) เชื่อมต่อ Native กับ SharePoint List `Cases`:
  - เลือกประเภทการปิดเคส (`ResolutionCategory`)
  - กรอกสรุปการแก้ไขปัญหา (`ResolutionSummary`) แบบหลายบรรทัด
  - กล่องแนบไฟล์หลักฐาน (`Attachments` DataCard) รองรับการลากวางไฟล์รูปภาพ/เอกสาร (PDF, PNG, JPG, XLSX)
- การตรวจสอบความถูกต้องก่อนส่ง (Strict Validation):
  - บังคับเลือกหมวดหมู่วิธีแก้ปัญหา
  - บังคับระบุคำอธิบายสรุปอย่างน้อย 10 ตัวอักษร
  - บังคับแนบไฟล์หลักฐานอย่างน้อย 1 ไฟล์ (`CountRows(DataCardValue_Attachments.Attachments) > 0`)
- บันทึกการปิดเคสด้วย `SubmitForm(frm_CaseResolution)` โดยปรับสถานะเป็น `"Resolved"` และระบุเวลา `ResolvedAt = Now()`

---

## Component Interactions & Data Flow

```
+-----------------------------------------------------------------------------------+
| cmp_AppHeader (Tier 1: Global Context & Manual Refresh)                           |
+-----------------------------------------------------------------------------------+
| cmp_KpiSummaryBar (Tier 2: Aggregate Metrics & Quick Status Select)               |
+-----------------------------------------------------------------------------------+
| cmp_ControlFilterBar (Tier 3: Multi-Filter Parameters)                             |
+---------------------------------------------------------+-------------------------+
| cmp_CaseTableGallery (Tier 4 Left)                      | cmp_ResolutionSideDrawer|
|                                                         | (Tier 4 Right: 480px)   |
| Items = SortByColumns(Filter(Cases, ...), "Created")   |                         |
|                                                         | [Read Case Details]     |
| [Row 1: CASE-001 | Core Ins | Claim Error | Open ] ---> |                         |
| [Row 2: CASE-002 | Portal   | Login Bug   | In Prog]    | [Resolution Form]       |
| [Row 3: CASE-003 | Payment  | Slip Issue  | Resolved]   | - Category Dropdown     |
|                                                         | - Resolution Summary    |
|                                                         | - Attachments Control   |
|                                                         |                         |
|                                                         | [Submit Resolution]     |
+---------------------------------------------------------+-------------------------+
```

1. ผู้ใช้เลือกตัวกรองใน `cmp_ControlFilterBar` หรือคลิกที่การ์ดใน `cmp_KpiSummaryBar`
2. ตัวแปรสถานะ `varSelectedStatus` และคำค้นหาถูกส่งเข้าเป็นเงื่อนไขในสูตร Delegable ของ `cmp_CaseTableGallery`
3. ผู้ใช้คลิกเลือกแถวใน `cmp_CaseTableGallery` -> ตัวแปร `varSelectedCase` ถูกกำหนด และ `varShowDrawer` เปลี่ยนเป็น `true`
4. `cmp_ResolutionSideDrawer` ปรากฏขึ้นพร้อมโหลดข้อมูลเคสเข้า `frm_CaseResolution`
5. เมื่อผู้ใช้แนบไฟล์และกรอกข้อความครบถ้วน กดปุ่ม "บันทึกการปิดเคส" -> ระบบรัน `SubmitForm(frm_CaseResolution)`
6. เมื่อ Submit สำเร็จ (`OnSuccess`) -> Drawer ปิดลง (`varShowDrawer = false`), แสดงการแจ้งเตือน Toast สำเร็จ และตารางอัปเดตข้อมูลอัตโนมัติ
