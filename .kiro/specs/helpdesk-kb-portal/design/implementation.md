# Design Specification: Implementation & Technical Guide (`helpdesk-kb-portal`)

## Overview
แนวทางการนำไปปฏิบัติจริง (Implementation Architecture) สำหรับแอปพลิเคชัน **Helpdesk Knowledge Base Management Portal** สรุปโครงสร้างไฟล์โปรเจกต์, การสร้างหน้าจอ YAML, แนวทางการคอมไพล์ผ่าน Power Platform CLI, และชุดทดสอบระบบ

---

## 1. Directory Structure

```
e:/DVS/Project/Aiagent_Helpme/
├── Helpdesk_KB_Portal/                         # ซอร์สโค้ด YAML ของ Canvas App
│   ├── CanvasManifest.json                     # กำหนดหน้าจอเริ่มต้นและ Properties
│   ├── Properties.json                         # ข้อมูลแอปและ Display Settings
│   ├── References/
│   │   ├── DataSources.json                    # ผูก AI_KnowledgeBase, SystemManuals, Systems, KnowledgeGaps
│   │   └── Resources.json                      # ไอคอนและ Resource องค์กร
│   └── Src/
│       ├── App.pa.yaml                         # OnStart, ตัวแปรสิทธิ์ RBAC, คอลเลกชัน Master Systems
│       └── Home_KB.pa.yaml                     # หน้าจอหลัก 4-Tier Container Layout
├── Helpdesk_KB_Portal.msapp                    # ไฟล์ไบนารีคอมไพล์แล้ว พร้อมนำเข้า
└── .kiro/specs/helpdesk-kb-portal/             # เอกสารข้อกำหนดและสเปกระบบ AIDLC
```

---

## 2. Technical Implementation Details: `Home_KB.pa.yaml`

หน้าจอหลักถูกสร้างขึ้นด้วยโครงสร้าง 4-Tier Container Auto-Layout:

```
Screen: Home_KB (W: 1366, H: 768, Fill: #F8FAFC)
├── con_MainContainer (Vertical Auto-Layout)
│   ├── con_Header (Tier 1: 64px, Fill: #012169)
│   │   ├── lbl_AppTitle ("ระบบบริหารจัดการคลังความรู้ไอที")
│   │   ├── con_NavTabs (Segmented Pills: คู่มือระบบ | ฐานข้อมูล Q&A | คำถามที่รอตอบ)
│   │   └── con_UserInfo (FullName, Role Tag, Refresh Button)
│   │
│   ├── con_KPIBar (Tier 2: 96px, Fill: #F8FAFC, Space-between)
│   │   ├── card_TotalManuals (KPI Card 1)
│   │   ├── card_ApprovedManuals (KPI Card 2)
│   │   ├── card_TotalQnA (KPI Card 3)
│   │   ├── card_ActiveQnA (KPI Card 4)
│   │   └── card_PendingGaps (KPI Card 5)
│   │
│   ├── con_FilterBar (Tier 3: 56px, Horizontal Auto-Layout)
│   │   ├── txt_SearchBox (Instant Search Box)
│   │   ├── cmb_SystemFilter (Dropdown Systems)
│   │   ├── con_ActionButtons (+ โฟลเดอร์, + อัปโหลด, + Q&A)
│   │   └── btn_ClearFilter
│   │
│   └── con_WorkspaceContainer (Tier 4: Fill remaining height)
│       ├── con_LeftPane (ตารางข้อมูลหลัก ความกว้างยืดหยุ่น)
│       │   ├── gal_ManualsList (แสดงเมื่อ varCurrentTab = "Manuals")
│       │   ├── gal_QnATable (แสดงเมื่อ varCurrentTab = "QnA", ความสูงแถว 44px)
│       │   └── gal_GapsTable (แสดงเมื่อ varCurrentTab = "Gaps")
│       │
│       └── con_SideDrawer (ความกว้าง 480px, Visible: varShowDrawer)
│           ├── con_DrawerHeader (Title & Close button)
│           ├── form_QnAEditor (Scrollable Form Fields)
│           └── con_DrawerFooter (Save & Delete buttons)
```

---

## 3. Power Platform CLI Build & Packaging Workflow

### 3.1 ขั้นตอนการ Build จาก YAML สู่ .msapp
รันคำสั่ง PowerShell:
```powershell
& "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe" canvas pack --sources "Helpdesk_KB_Portal" --msapp "Helpdesk_KB_Portal.msapp"
```

### 3.2 ขั้นตอนการนำเข้าสู่ Power Apps Portal
1. เปิด **Power Apps Maker Portal**: `https://make.powerapps.com`
2. เลือกสภาพแวดล้อม **Deves Insurance**
3. ไปที่เมนู **Apps** > คลิก **Import canvas app**
4. เลือกไฟล์ [`Helpdesk_KB_Portal.msapp`](file:///e:/DVS/Project/Aiagent_Helpme/Helpdesk_KB_Portal.msapp)
5. ตรวจสอบการเชื่อมต่อ SharePoint Connector แล้วกด **Save & Publish**

---

## 4. Verification Test Plan (ตามมติ D3-6)

| ชุดทดสอบ | ขั้นตอนการทดสอบ | เกณฑ์การผ่าน |
|---------|----------------|-------------|
| **1. Viewport Ergonomics** | รันแอปบนจอ 1366x768 และ 1920x1080 | ไม่เกิด Horizontal Scrollbar ตารางแถว 44px อ่านง่ายชัดเจน |
| **2. Q&A Search & Filter** | พิมพ์ค้นหาคำถามใน `txt_SearchBox` และเลือกกรองระบบ | ผลลัพธ์แสดงทันที < 0.3s ปราศจาก Delegation Warning |
| **3. Quick Active Toggle** | คลิกสวิตช์ Active/Inactive บนแถวตาราง | ค่าใน `AI_KnowledgeBase` เปลี่ยนทันที และตัวเลข KPI ปรับเปลี่ยนอัตโนมัติ |
| **4. Side Drawer CRUD** | เพิ่ม Q&A ใหม่ และแก้ไข Q&A เดิม | ข้อมูลถูกบันทึกลง SharePoint ครบทุกฟิลด์ Drawer ปิดเรียบร้อย |
| **5. Gap-to-Q&A Converter** | กดปุ่ม "แปลงเป็น Q&A" ในแท็บ Gaps | ฟอร์มเปิดพร้อมคัดลอกคำถาม เมื่อกดบันทึก สถานะของ Gap กลายเป็น Resolved |
| **6. RBAC Guard** | ทดสอบด้วยบัญชีผู้ใช้ทั่วไป | ปุ่มเพิ่ม/แก้ไข/ลบ ถูกซ่อน/ปิดการใช้งานอย่างถูกต้อง |
