# Phase 4: Design Decisions (D3) — Monitor_case_Helpdesk

## Context Summary
- **ระบบเป้าหมาย**: Power Apps Canvas App `Monitor_case_Helpdesk`
- **สถาปัตยกรรมที่เลือกจาก D2**: Single-Screen Master-Detail with Collapsible Side Drawer บนหน้าจอ `Home_incident`
- **Units**: Unit 1 (`dashboard-filter`) และ Unit 2 (`case-resolution`)
- **โจทย์เทคนิค**: ปรับ UI เป็น Modern Enterprise ไร้ Emoji, สูตรกรองต้อง Delegable 100%, ระบบแนบหลักฐานปิดเคสผ่าน Native Attachment, และกำหนด Schema/Indexing ให้กับ SharePoint List `Cases`

---

## Decision Questions

### D3-1: Container Layout & Laptop Grid Architecture (โครงสร้าง Container และ Layout)
**Question**: โครงสร้าง Container ภายในหน้าจอ `Home_incident` ควรจัดวาง Layout อย่างไรเพื่อรองรับหน้าจอ Laptop (16:9 Landscape)?
- 1) **4-Tier Auto-Layout Container Hierarchy**  
  - Tier 1 (Header): Navigation, User Info, Last Refresh Time  
  - Tier 2 (KPI Summary Bar): 5 Metric Cards เรียงแนวนอน (Total, Open, In Progress, Resolved Today, SLA Breached)  
  - Tier 3 (Control Bar): Status Filter Tabs + System ComboBox + Search Box + Clear Button  
  - Tier 4 (Workspace Split): ฝั่งซ้ายเป็น Dense Table Gallery (ความสูงแถว 44px) + ฝั่งขวาเป็น Side Drawer Container (กว้าง 480px, Visible สลับตามตัวแปร `varShowDrawer`) **(Recommended)**
- 2) **Fixed Absolute Coordinates Layout** — กำหนดตำแหน่ง X, Y, Width, Height แบบตัวเลขคงที่ตามความละเอียด 1366x768
- 3) **Multi-Tab Dashboard** — แยกหน้าจอเป็นแท็บ Overview, แท็บ Active Cases และแท็บ Closed Cases
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (4-Tier Auto-Layout Container Hierarchy — Header, KPI Bar, Control Bar, Dense Gallery 44px + 480px Collapsible Side Drawer)

---

### D3-2: Design Tokens & Modern Color Palette (ชุดสีและ Design Tokens)
**Question**: กำหนดชุดสีทางการ (Corporate Design Tokens) สำหรับสถานะและองค์ประกอบต่างๆ ในแอปพลิเคชันอย่างไร?
- 1) **Fluent Slate & Deves Corporate Palette**  
  - Header & Primary Action: Deves Deep Navy (`#012169`)  
  - Neutral Background: Soft Light Gray (`#F8F9FA`), Surface White (`#FFFFFF`), Border (`#E2E8F0`)  
  - Status Badges (Pill shape):  
    - `Open`: พื้นหลัง `#F1F5F9` / ตัวอักษร `#475569` (Slate)  
    - `In Progress`: พื้นหลัง `#FEF3C7` / ตัวอักษร `#B45309` (Amber)  
    - `Resolved`: พื้นหลัง `#D1FAE5` / ตัวอักษร `#047857` (Emerald)  
    - `SLA Breached`: พื้นหลัง `#FFE4E6` / ตัวอักษร `#BE123C` (Rose) **(Recommended)**
- 2) **Vibrant Material Palette** — ใช้สีสดสไตล์ Material Design (Primary Blue `#1976D2`, Green `#388E3C`, Red `#D32F2F`)
- 3) **Monochrome Enterprise** — ใช้เฉพาะโทนสีขาว-เทา-ดำ และใช้เส้นขอบเน้นสถานะ
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Fluent Slate & Deves Corporate Palette — Deep Navy #012169, Neutral Slate, Semantic Pills for Statuses)

---

### D3-3: Power Fx Delegable Filter Implementation (การออกแบบสูตรกรองข้อมูลแบบ Delegable)
**Question**: การออกแบบสูตร Power Fx สำหรับ Items ใน Gallery เพื่อให้ SharePoint สามารถประมวลผลแบบ Server-Side โดยไม่ติดขีดจำกัด Delegation Limit 2,000 แถว ควรเป็นแบบใด?
- 1) **Direct Boolean Formula with `StartsWith` & Single-Column Sort**  
  - ใช้สูตร:  
    ```powerfx
    SortByColumns(
        Filter(
            Cases,
            (varSelectedStatus = "All" || Statuscase.Value = varSelectedStatus) &&
            (IsBlank(cmb_SystemFilter.Selected.Value) || SystemName = cmb_SystemFilter.Selected.Value) &&
            (IsBlank(txt_Search.Text) || StartsWith(CaseID, txt_Search.Text) || StartsWith(Title, txt_Search.Text))
        ),
        "Created",
        SortOrder.Descending
    )
    ```  
  - ปราศจาก Delegation Warning ไอคอนสีเหลือง 100% **(Recommended)**
- 2) **Pre-Filter Collection on App Start** — โหลดข้อมูลเคส 30 วันย้อนหลังเก็บเข้า Collection แล้วกรองด้วยสูตร In-Memory
- 3) **Search Function with Delegable Fallback** — ใช้ `Search()` เป็นหลัก และถ้าติดคำเตือนให้สลับเป็น `Filter()`
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Direct Boolean Formula with StartsWith & Single-Column Sort — 100% Server-Side Delegable, No 2,000 limit)

---

### D3-4: Resolution Evidence Attachment Implementation (เทคนิคการแนบไฟล์หลักฐานปิดงาน)
**Question**: ในหน้าต่าง Side Drawer จะผูกระบบการแนบไฟล์หลักฐานเข้ากับ SharePoint List `Cases` ด้วยกลไกใดใน Power Apps?
- 1) **Native EditForm Attachment Control with `SubmitForm`** — ใช้ EditForm ผูกกับ `Cases` และดึง DataCard ของ `Attachments` เข้ามาในฟอร์ม ร่วมกับฟิลด์ `ResolutionSummary`, `ResolutionCategory`, `ResolvedAt` เมื่อกด SubmitForm ตัวคอนเนคเตอร์ SharePoint จะอัปโหลดไฟล์แนบและอัปเดตข้อมูลแถวพร้อมกันใน Transaction เดียว **(Recommended)**
- 2) **Patch with Custom Attachment Upload Flow** — ใช้ Power Automate Flow ในการรับ Base64 ของไฟล์แนบไปเขียนลง SharePoint
- 3) **Separate SharePoint Document Library with Metadata Tag** — อัปโหลดไฟล์ไปยัง Document Library แยก แล้วนำ Link URL มาเก็บในคอลัมน์ของ Cases
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Native EditForm Attachment Control with SubmitForm — Direct SharePoint Transaction, Low-Code Native)

---

### D3-5: SharePoint List Schema Enhancement & Indexing (สเปกฟิลด์และการทำ Index ใน SharePoint)
**Question**: ข้อมูลจำเพาะของคอลัมน์ใหม่และการตั้งค่า Indexed Columns ใน SharePoint List `Cases` ที่ต้องส่งมอบเป็นคู่มือควรมีรายละเอียดอย่างไร?
- 1) **2 New Columns + 5 Indexed Columns**  
  - คอลัมน์ใหม่:  
    1. `ResolutionSummary`: Multiple lines of text (Plain text, 6 บรรทัด)  
    2. `ResolutionCategory`: Choice (แก้ไขข้อมูล, ปรับแต่งสิทธิ์, แก้ไขบั๊กโปรแกรม, สอนการใช้งาน, ประสานงานภายนอก, อื่นๆ)  
  - Indexed Columns (ตั้งค่าใน List Settings):  
    `Statuscase`, `CaseID`, `SystemName`, `AssignedOwner`, `Created` **(Recommended)**
- 2) **1 New Column + 3 Indexed Columns** — เพิ่มเฉพาะ `ResolutionSummary` และทำ Index เฉพาะ `Statuscase`, `CaseID`, `Created`
- 3) **No New Columns (Use StatusNote)** — ใช้ฟิลด์ `StatusNote` เดิม และทำ Index เฉพาะ `Statuscase`
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (2 New Columns: ResolutionSummary, ResolutionCategory + 5 Indexed Columns: Statuscase, CaseID, SystemName, AssignedOwner, Created)

---

### D3-6: Correctness Verification & Testing Approach (แนวทางการตรวจสอบความถูกต้อง - MANDATORY)
**Question**: แนวทางในการตรวจสอบความถูกต้อง (Verification) ของระบบหลังการปรับปรุงซอร์สโค้ด YAML ควรใช้วิธีใด?
- 1) **Comprehensive 4-Pillar Verification**  
  1. *Delegation Audit*: ตรวจสอบผ่าน Power Apps App Checker ต้องมีคำเตือน Delegation = 0  
  2. *Validation Rules*: ทดสอบการกดปิดเคสโดยไม่มีไฟล์แนบ/ไม่มีข้อความ ต้องถูกบล็อกไม่ให้ส่ง  
  3. *Responsive Visual Inspection*: ตรวจสอบ Layout บนความละเอียด Laptop (1366x768 / 1920x1080) ไม่ล้นกรอบ  
  4. *Package Integrity*: ตรวจสอบการคอมไพล์ผ่าน `pac canvas pack` และแตกไฟล์ `pac canvas unpack` ต้องไม่มี Syntax Error **(Recommended)**
- 2) **Basic Functional Smoke Test** — ทดสอบเปิดแอป ค้นหาเคส และทดลองปิดเคส 1 รายการ
- 3) **Automated TestEngine / Playwright Test Script** — เขียนสคริปต์ Playwright อัตโนมัติสำหรับ Power Apps
- 4) Other (โปรดระบุ): _______

**Answer**: Option 1 (Comprehensive 4-Pillar Verification — Delegation Audit, Form Validation, Laptop Layout Check, PAC Pack/Unpack Integrity)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D3-1 Container Layout: Option 1 (4-Tier Auto-Layout Container Hierarchy with 44px Dense Table and 480px Side Drawer)
- D3-2 Design Tokens: Option 1 (Fluent Slate & Deves Corporate Navy #012169 with Semantic Status Badges)
- D3-3 Delegable Formula: Option 1 (Direct Boolean Server-Side Formula with StartsWith and Single-Column Sort)
- D3-4 Attachment Implementation: Option 1 (Native EditForm Attachment Control with SubmitForm Transaction)
- D3-5 SharePoint Schema & Indexing: Option 1 (2 New Columns: ResolutionSummary, ResolutionCategory and 5 Indexed Columns)
- D3-6 Verification Approach: Option 1 (Comprehensive 4-Pillar Verification including PAC Canvas Pack/Unpack Integrity)

---

**Instructions**: Decisions populated from recommended choices.

