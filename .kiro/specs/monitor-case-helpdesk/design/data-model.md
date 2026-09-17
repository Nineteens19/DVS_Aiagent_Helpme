# Data Model Specification — Monitor_case_Helpdesk

## Overview
**Database Technology**: Microsoft SharePoint Online Lists (Enterprise M365)  
**List Name (Primary)**: `Cases` (List ID: `b8b22b0d-45c6-43c9-bc66-06e5e45b1237`)  
**Site URL**: `https://devesinsurance.sharepoint.com/sites/PowerAppPRD`  
**Attachment Support**: Native List Item Attachments  
**Access Client**: Power Apps SharePoint Connector (Direct Native Low-Code Binding)

---

## Primary Entity: Cases (รายการแจ้งปัญหาไอที)

### Schema Definition

| Column Internal Name | Display Name (TH) | SharePoint Data Type | Required | Constraints / Values | Purpose |
|----------------------|-------------------|----------------------|----------|----------------------|---------|
| `ID` | รหัสระบบ (System ID) | Counter (Integer) | Yes | Primary Key (Auto-increment) | รหัสอ้างอิงภายในของ SharePoint |
| `CaseID` | รหัสเคส | Single line of text | Yes | Unique Pattern (e.g. `CASE-202609-0012`) | รหัสที่ใช้อ้างอิงและค้นหาเคสสำหรับผู้ใช้ |
| `Title` | หัวข้อปัญหา | Single line of text | Yes | Max 255 chars | สรุปประเด็นปัญหาที่แจ้งเข้ามา |
| `Statuscase` | สถานะเคส | Choice | Yes | Choices: `Open`, `In Progress`, `Resolved`, `Closed` | สถานะวงจรชีวิตของเคส |
| `SystemName` | ระบบงานที่พบปัญหา | Single line of text | Yes | Matches `Systems.Title` | ระบุแอปพลิเคชันหรือระบบไอทีที่เกี่ยวข้อง |
| `AssignedOwner` | เจ้าหน้าที่ผู้ดูแล | Single line of text / Person | No | Default: Blank หรือผู้รับผิดชอบหลัก | เจ้าหน้าที่ไอทีที่รับผิดชอบการแก้ไขเคส |
| `Created` | วันที่และเวลาที่แจ้ง | Date and Time | Yes | System Managed (UTC/Local) | วันที่เริ่มต้นเปิดเคส (ใช้คำนวณ SLA) |
| `Author` | ผู้แจ้งปัญหา | Person or Group | Yes | System Managed | บัญชีผู้ใช้งานที่ส่งเรื่องเข้ามา |
| `StatusNote` | หมายเหตุสถานะเดิม | Multiple lines of text | No | Plain text | บันทึกประวัติการทำงานเดิม |
| `ResolutionSummary` **[NEW]** | สรุปแนวทางแก้ไขปัญหา | Multiple lines of text | Yes (เมื่อปิดเคส) | Plain text (6 lines display) | รายละเอียดสิ่งที่ได้แก้ไขเพื่อปิดงาน |
| `ResolutionCategory` **[NEW]** | หมวดหมู่วิธีแก้ปัญหา | Choice | Yes (เมื่อปิดเคส) | Choices: `แก้ไขข้อมูล`, `ปรับแต่งสิทธิ์`, `แก้ไขบั๊กโปรแกรม`, `สอนการใช้งาน`, `ประสานงานภายนอก`, `อื่นๆ` | จัดกลุ่มสาเหตุและวิธีแก้เพื่อใช้วิเคราะห์ Root Cause |
| `ResolvedAt` **[NEW]** | วันและเวลาที่ปิดเคส | Date and Time | No | DateTime | บันทึกเวลาที่ทำการปิดเคสเสร็จสมบูรณ์ |
| `ResolvedBy` **[NEW]** | ผู้ดำเนินการปิดเคส | Person or Group | No | User Profile | บัญชีผู้ใช้งานที่กดบันทึกปิดเคส |
| `Attachments` | ไฟล์หลักฐานประกอบ | Attachments (Native) | Yes (เมื่อปิดเคส >= 1) | Allowed extensions: PNG, JPG, JPEG, PDF, DOCX, XLSX, TXT (Max 25MB ต่อไฟล์) | หลักฐานยืนยันความสำเร็จของการแก้ไข |

---

## Lookup Entity: Systems (ระบบงานไอที)

### Schema Definition

| Column Name | Display Name | Data Type | Required | Description |
|-------------|--------------|-----------|----------|-------------|
| `ID` | รหัสระบบ | Counter | Yes | PK |
| `Title` | ชื่อระบบงาน | Single line of text | Yes | เช่น Core Insurance, Portal เคลม, ระบบบัญชี ERP, อินทราเน็ต |
| `SystemCode` | รหัสย่อระบบ | Single line of text | No | รหัสย่อ เช่น CORE, CLAIM, ERP |
| `IsActive` | สถานะการใช้งาน | Boolean | Yes | ค่า True/False |

---

## Entity Relationship Diagram

```
+------------------------------------+
|             Systems                |
+------------------------------------+
| PK: ID                             |
|     Title (System Name)            |
|     SystemCode                     |
|     IsActive                       |
+------------------------------------+
                  |
                  | 1:N (Lookup by Name)
                  v
+------------------------------------+          +------------------------------------+
|              Cases                 |          |          Case Attachments          |
+------------------------------------+          |        (SharePoint Native)         |
| PK: ID                             |          +------------------------------------+
|     CaseID                         | 1:N      | PK: Id                             |
|     Title                          |--------->| FK: ItemId (Cases.ID)              |
|     Statuscase (Choice)            | (Native) |     Name (File Name)               |
|     SystemName                     |          |     Value (Download URL / Blob)    |
|     ResolutionCategory [NEW]       |          +------------------------------------+
|     ResolutionSummary [NEW]        |
|     ResolvedAt [NEW]               |
|     ResolvedBy [NEW]               |
|     Created                        |
+------------------------------------+
```

---

## SharePoint List Indexing Specification (สำหรับ List `Cases`)

การเปิดใช้งาน Delegation 100% บน SharePoint List ที่มีข้อมูลเกิน 2,000 แถว ต้องกำหนด **Indexed Columns** ดังต่อไปนี้ในหน้าการตั้งค่า **List Settings > Indexed Columns**:

| # | Column Name | Column Type | Index Purpose & Query Pattern |
|---|-------------|-------------|-------------------------------|
| 1 | `Statuscase` | Choice | กรองสถานะเคส (`Statuscase.Value = "Open"`, `"In Progress"`, `"Resolved"`) |
| 2 | `CaseID` | Single line of text | ค้นหารหัสเคสด้วย `StartsWith(CaseID, ...)` |
| 3 | `SystemName` | Single line of text | กรองเคสตามระบบงาน `SystemName = ...` |
| 4 | `AssignedOwner` | Single line of text | กรองเคสที่มอบหมายให้ตนเอง หรือผู้รับผิดชอบเฉพาะ |
| 5 | `Created` | Date and Time | เรียงลำดับรายการล่าสุด `SortByColumns(..., "Created", Descending)` |

---

## Data Access Patterns & Delegability Validation

| Query Pattern / Operation | Formula Implementation | Delegation Compatibility | Server Index Used |
|---------------------------|------------------------|--------------------------|-------------------|
| กรองตามสถานะ (Choice) | `Statuscase.Value = varSelectedStatus` | 100% Delegable | `Statuscase` Index |
| กรองตามระบบงาน (Text) | `SystemName = cmb_SystemFilter.Selected.Value` | 100% Delegable | `SystemName` Index |
| ค้นหาคำขึ้นต้นรหัสเคส | `StartsWith(CaseID, txt_Search.Text)` | 100% Delegable | `CaseID` Index |
| ค้นหาคำขึ้นต้นหัวเรื่อง | `StartsWith(Title, txt_Search.Text)` | 100% Delegable | Text Prefix Match |
| เรียงลำดับตามวันที่สร้าง | `SortByColumns(..., "Created", Descending)` | 100% Delegable | `Created` Index |
| อัปโหลดไฟล์แนบและปิดเคส | `SubmitForm(frm_CaseResolution)` | Native SharePoint Transaction | Primary Key `ID` |
