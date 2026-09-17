# Integration Specification — Monitor_case_Helpdesk

## Overview
แอปพลิเคชันทำงานบนสภาพแวดล้อม Microsoft Power Platform โดยเชื่อมต่อกับบริการภายนอกในระบบนิเวศ Microsoft 365 และมีการสื่อสารแบบไร้รอยต่อระหว่าง Unit 1 (`dashboard-filter`) และ Unit 2 (`case-resolution`) ผ่านตัวแปรสถานะระดับหน้าจอ (Screen Context State)

---

## External Integrations

### 1. Microsoft SharePoint Online Connector
**Purpose**: แหล่งเก็บข้อมูลหลักสำหรับบันทึกรายการเคส ประวัติ และไฟล์แนบหลักฐาน
**Type**: Native Power Apps Connector (RPC over HTTPS / Microsoft Graph API)
**Authentication**: Native Microsoft Entra ID (Azure AD) SSO — สิทธิ์ระดับผู้ใช้ (User-delegated permissions)
**Endpoint / Target Site**:
- Site Collection: `https://devesinsurance.sharepoint.com/sites/PowerAppPRD`
- Target Lists:
  - `Cases` (List ID: `b8b22b0d-45c6-43c9-bc66-06e5e45b1237`)
  - `Systems` (List ID: `37a7b3db-d9ef-4cf8-b3f7-920f0ee3ee9a`)

**Operations**:
- **Read / Query**: ผ่านสูตร `Filter()` และ `SortByColumns()` ส่งคำสั่ง Server-Side Query ไปยัง SharePoint OData endpoint
- **Write / Attachments Upload**: ผ่านคำสั่ง `SubmitForm()` แบบ Transaction เดียว (บันทึกข้อมูลฟิลด์และอัปโหลด Multi-part binary attachments พร้อมกัน)

**Error Handling**:
- หากบันทึกไม่สำเร็จ Event `OnFailure` ของ `frm_CaseResolution` จะตรวจจับข้อผิดพลาดและแจ้งเตือน:
  ```powerfx
  Notify("เกิดข้อผิดพลาดในการบันทึกข้อมูล: " & frm_CaseResolution.ErrorMessage, NotificationType.Error)
  ```

---

### 2. Office 365 Users Connector
**Purpose**: ดึงข้อมูลบริบทของเจ้าหน้าที่ผู้ใช้งานระบบ
**Operations**:
- `User().FullName`: ชื่อ-นามสกุลสำหรับแสดงใน Header และบันทึกใน `ResolvedBy`
- `User().Email`: อีเมลประจำตัว
- `User().Image`: รูปโปรไฟล์ผู้ใช้งาน

---

## Inter-Unit Communication

การทำงานระหว่าง Unit 1 (`dashboard-filter`) และ Unit 2 (`case-resolution`) ถูกเชื่อมโยงผ่าน **In-Screen State Synchronization** โดยไม่มีการเปลี่ยนหน้าจอ (Zero Screen Navigation Overhead):

```
+------------------------------------+                         +------------------------------------+
|     Unit 1: dashboard-filter       |                         |      Unit 2: case-resolution      |
+------------------------------------+                         +------------------------------------+
| [Select Case Row in Gallery]       |                         | [Side Drawer Container]            |
|                                    |                         |                                    |
| Action:                            |                         | Visible = varShowDrawer            |
| - Set(varSelectedCase, ThisItem)   | ----------------------> | Item = varSelectedCase             |
| - Set(varShowDrawer, true)         |     State Injection     | Mode = FormMode.Edit               |
| - EditForm(frm_CaseResolution)     |                         |                                    |
|                                    |                         | [Submit Resolution Action]         |
|                                    |                         | - Validate File Attachments >= 1   |
|                                    |                         | - SubmitForm(frm_CaseResolution)   |
|                                    |                         |                                    |
| [Auto Refresh Case Grid]           | <---------------------- | OnSuccess:                         |
| (SharePoint Connector Cache Inval) |      Event Trigger      | - Set(varShowDrawer, false)        |
|                                    |                         | - Notify("ปิดเคสสำเร็จ", Success)   |
+------------------------------------+                         +------------------------------------+
```

### Shared State Variables Contract

| Variable Name | Type | Scope | Owner | Description |
|---------------|------|-------|-------|-------------|
| `varSelectedCase` | Record (`Cases`) | Screen Context | Unit 1 (Producer) | เก็บข้อมูลของเคสแถวที่ถูกเลือกเพื่อส่งให้ฟอร์มใน Unit 2 |
| `varShowDrawer` | Boolean | Screen Context | Unit 1 & Unit 2 | ควบคุมการแสดงผลเปิด/ปิดของแถบ Side Drawer |
| `varSelectedStatus` | Text | Screen Context | Unit 1 (Producer) | ควบคุมการกรองสถานะเคส (`"All"`, `"Open"`, `"In Progress"`, `"Resolved"`) |
| `varLastRefreshedTime` | DateTime | Screen Context | Unit 1 (Producer) | บันทึกเวลาที่ดึงข้อมูลล่าสุดจากเซิร์ฟเวอร์ |

---

## Future Analytics & Power BI Integration

เพื่อตอบโจทย์ความต้องการของผู้ใช้ในอนาคตในการวิเคราะห์ข้อมูลสถิติเคสปริมาณมาก:
1. ข้อมูลในคอลัมน์ใหม่ `ResolutionCategory`, `ResolutionSummary`, `ResolvedAt` และเวลาสร้างเคส `Created` จะเป็นโครงสร้างมาตรฐานที่ Power BI Service สามารถดึงข้อมูลตรงผ่าน SharePoint Connector
2. รองรับการคำนวณ **Mean Time to Resolution (MTTR)** โดยตรงจากสูตร:
   $$\text{MTTR} = \text{ResolvedAt} - \text{Created}$$
3. รองรับการจัดทำกราฟ Pareto เพื่อวิเคราะห์หมวดหมู่ปัญหาที่พบบ่อยที่สุด (Root Cause Pareto Analysis)
