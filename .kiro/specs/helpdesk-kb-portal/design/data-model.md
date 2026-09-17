# Design Specification: Data Model & Power Fx Schema

## Overview
โครงสร้างโมเดลข้อมูลสำหรับ **Helpdesk Knowledge Base Management Portal** สรุปแหล่งข้อมูล SharePoint Online 4 แหล่งที่เชื่อมโยงกัน, โครงสร้างคอลัมน์, และรูปแบบการจัดเก็บตัวแปรในหน่วยความจำ (In-Memory Collections) เพื่อความเร็วสูงสุด 0s Latency

---

## 1. Connected SharePoint Data Sources

| แหล่งข้อมูล (Data Source) | ประเภท (Type) | SharePoint Site URL / List GUID | หน้าที่ในระบบ |
|--------------------------|---------------|--------------------------------|---------------|
| `SystemManuals` | Document Library | `https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals` | จัดเก็บไฟล์คู่มือระบบ (PDF/DOCX) พร้อม Metadata คุมสถานะ |
| `AI_KnowledgeBase` | SharePoint List | GUID: `95e5e09d-6d20-4811-8833-820cef88fe98` | จัดเก็บข้อคำถาม-คำตอบ Q&A 74 รายการเดิมและรายการใหม่ |
| `Systems` | Master SharePoint List | GUID: `37a7b3db-d9ef-4cf8-b3f7-920f0ee3ee9a` | ตาราง Master รายชื่อระบบมาตรฐาน 31 ระบบ |
| `KnowledgeGaps` | SharePoint List | GUID: `9beb45a0-08e2-4717-8eee-5b80bd218005` | จัดเก็บคำถามที่ AI ตอบไม่ได้เพื่อนำมาแปลงเป็น Q&A |

---

## 2. Entity Schemas & Delegation Rules

### 2.1 Entity: `AI_KnowledgeBase` (SharePoint List)

| Field Name | Data Type | Indexed? | Required? | Power Fx Usage & Delegation |
|------------|-----------|----------|-----------|------------------------------|
| `ID` | Counter (PK) | Yes | Auto | เลือกระบุเรคอร์ดที่ต้องการแก้ไข/ลบ |
| `Title` | Single line of text | Yes | Yes | หัวข้อคำถาม ใช้สืบค้นด้วย `StartsWith(Title, txt_Search.Text)` |
| `Question` | Multiple lines of text | No | No | รายละเอียดคำถามแบบเต็ม |
| `Answer` | Multiple lines of text | No | Yes | คำตอบและวิธีแก้ไขปัญหา |
| `System` | Single line of text | Yes | Yes | ชื่อระบบ อิงตาม Master `Systems` ใช้กรองด้วย `System = cmb_System.Selected.Value` |
| `Category` | Single line of text | No | No | หมวดหมู่ปัญหา เช่น `การใช้งาน`, `สิทธิ์การเข้าถึง`, `รหัสผ่าน` |
| `Keywords` | Multiple lines of text | No | No | คำค้นหาและคำพ้องความหมาย (Synonyms) |
| `Status` | Choice (`Active`, `Inactive`) | Yes | Yes | กรองด้วย `Status.Value = varStatusFilter` |
| `Created` | Date and Time | Yes | Auto | ใช้เรียงลำดับด้วย `SortByColumns(..., "Created", SortOrder.Descending)` |

### 2.2 Entity: `SystemManuals` (Document Library)

| Field Name | Data Type | Required? | Description & AI Binding |
|------------|-----------|-----------|--------------------------|
| `FileLeafRef` | Text (Filename) | Yes | ชื่อไฟล์เอกสารคู่มือพร้อมนามสกุล (.pdf, .docx) |
| `Title` | Text | Yes | ชื่อทางการของคู่มือ |
| `SystemName` | Text | Yes | ชื่อระบบงาน อิงตาม Master `Systems` |
| `DocType` | Choice | Yes | `User Manual`, `Admin Guide`, `SOP`, `FAQ Document` |
| `Status` | Choice | Yes | `Approved`, `Draft`, `Archived` (AI ดึงเฉพาะ Approved) |
| `Keywords` | Text | No | คำสำคัญสำหรับช่วย Semantic Search |
| `EncodedAbsUrl`| Text | Auto | ลิงก์ตรงสำหรับเปิดดูไฟล์ผ่าน SharePoint Web Viewer |

### 2.3 Entity: `KnowledgeGaps` (SharePoint List)

| Field Name | Data Type | Description |
|------------|-----------|-------------|
| `Title` / `Query` | Text | ข้อความคำถามที่พนักงานพิมพ์ถามแล้ว AI ตอบไม่ได้ |
| `System` | Text | ชื่อระบบที่เกี่ยวข้อง (หากตรวจจับได้) |
| `Frequency` | Number | จำนวนครั้งที่มีการถามคำถามนี้ |
| `Status` | Choice | `Pending`, `Resolved` |

---

## 3. In-Memory State & Power Fx Collections

สำหรับการทำงานที่รวดเร็วและป้องกันความหน่วง ระบบจะกำหนดตัวแปร Global และ Local Context ใน `App.OnStart` และหน้าจอ `Home_KB`:

```powerfx
// 1. ตรวจสอบสิทธิ์ผู้ใช้ (RBAC Context)
Set(varCurrentUser, User());
Set(varIsAdmin, 
    varCurrentUser.Email in ["teerapat.ti@deves.co.th", "helpdesk@deves.co.th"] ||
    User().Email = "teerapat.ti@deves.co.th"
);
Set(varUserRole, If(varIsAdmin, "IT Helpdesk Administrator", "Read-only Viewer"));

// 2. โหลด Master Systems เข้าสู่ Local Collection เพื่อแสดงใน Dropdown ทันที 0s Latency
ClearCollect(
    colMasterSystems,
    Sort(
        Filter(Systems, IsActive = true || IsActive = "Yes"),
        Title,
        SortOrder.Ascending
    )
);

// 3. กำหนดค่าเริ่มต้นของหน้าจอ
Set(varCurrentTab, "Manuals"); // "Manuals" | "QnA" | "Gaps"
Set(varStatusFilter, "All");
UpdateContext({
    varShowDrawer: false,
    varDrawerMode: "New",
    varSelectedQnA: Blank(),
    varShowDeleteDialog: false
});
```
