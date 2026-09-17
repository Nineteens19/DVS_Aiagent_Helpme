# Design Specification: Integration Architecture (`helpdesk-kb-portal`)

## Overview
สถาปัตยกรรมการเชื่อมต่อของแอปพลิเคชัน **Helpdesk Knowledge Base Management Portal** สรุปการผสานการทำงานระหว่าง Power Apps Canvas App, SharePoint OData V3 Connector, Power Automate Cloud Flow, และการกระจายความรู้สู่ Copilot Studio Knowledge Engine

---

## 1. Data Connection Architecture

```
+-----------------------------------------------------------------------------------+
|               Power Apps Canvas App: Helpdesk_KB_Portal (Desktop 16:9)             |
+-----------------------------------------------------------------------------------+
       |                                   |                             |
       | Native OData (Delegable)          | Instant Flow Trigger        | Direct Link
       v                                   v                             v
+-------------------------------+   +-----------------------------+   +-------------------+
| SharePoint Online Connector   |   | Power Automate Cloud Flow   |   | SharePoint Online |
| - AI_KnowledgeBase (List)     |   | - KB_CreateFolder           |   | Web Viewer        |
| - Systems (Master List)       |   |   (สร้างโฟลเดอร์ใน Library)   |   | (เปิดอ่านคู่มือเต็ม)|
| - KnowledgeGaps (List)        |   +-----------------------------+   +-------------------+
| - SystemManuals (Library)     |                  |
+-------------------------------+                  v
       |                          +-----------------------------------+
       |                          | SharePoint Document Library:      |
       +------------------------> | SystemManuals                     |
                                  +-----------------------------------+
                                                   |
                                                   | Graph Indexer Background Sync
                                                   v
                                  +-----------------------------------+
                                  | Microsoft Copilot Studio:         |
                                  | HelpMe Agent Knowledge Sources    |
                                  +-----------------------------------+
```

---

## 2. Power Automate Flow Integration: `KB_CreateFolder`

### 2.1 Flow Definition
- **Trigger**: PowerApps (V2)
- **Inputs**:
  - `FolderName` (String): ชื่อโฟลเดอร์ระบบใหม่ (เช่น `Smart_Form`, `HRIS`)
- **Actions**:
  1. SharePoint Action: `Create new folder`
     - Site Address: `https://dvsins.sharepoint.com/sites/PowerAppPRD`
     - List or Library: `SystemManuals`
     - Folder Path: `FolderName`
  2. Response Action: `Respond to a PowerApp or flow`
     - Output: `Status: Success`, `Message: "Folder created successfully"`
- **Invocation in Power Apps**:
  ```powerfx
  Set(varFlowResult, KB_CreateFolder.Run(txt_NewFolderName.Text));
  If(varFlowResult.Status = "Success",
      Notify("สร้างโฟลเดอร์ระบบใหม่เรียบร้อยแล้ว", NotificationType.Success);
      Refresh(SystemManuals);
      UpdateContext({varShowNewFolderDialog: false}),
      Notify("เกิดข้อผิดพลาดในการสร้างโฟลเดอร์", NotificationType.Error)
  );
  ```

---

## 3. Knowledge Base Synchronization Pipeline

### 3.1 Closed-Loop AI Learning (Gap-to-KB Flow)
1. เมื่อผู้ใช้งานถามคำถามที่ HelpMe Agent ไม่พบคำตอบ บอทจะเขียนเรคอร์ดลงใน SharePoint List `KnowledgeGaps`
2. เจ้าหน้าที่ IT Helpdesk เปิดแอปพลิเคชันพอร์ทัล ดูแท็บ `Knowledge Gaps`
3. คลิกปุ่ม **"แปลงเป็น Q&A (Create Q&A)"**:
   - แอปดึงข้อความคำถาม และชื่อระบบเปิดเข้าสู่ Side Drawer
   - เจ้าหน้าที่กรอกคำตอบที่ถูกต้อง แล้วกด **"บันทึก Q&A"**
4. แอปพลิเคชันทำการ:
   - สั่ง `Patch(AI_KnowledgeBase, Defaults(AI_KnowledgeBase), { ... })`
   - สั่ง `Patch(KnowledgeGaps, varSelectedGap, { Status: { Value: "Resolved" } })`
   - ผลลัพธ์: คำถามถูกแปลงเป็นองค์ความรู้ทันที และสถานะของ Gap ถูกปิดงานอย่างสมบูรณ์

---

## 4. Power Platform CLI Packaging Integration

- **Source Code Repository**: ซอร์สโค้ด YAML เก็บอยู่ใน `Helpdesk_KB_Portal/`
- **Build / Packaging Tool**: Power Platform CLI (`pac canvas pack`)
- **Packaging Command**:
  ```powershell
  & "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe" canvas pack --sources "Helpdesk_KB_Portal" --msapp "Helpdesk_KB_Portal.msapp"
  ```
- **Deployment Artifact**: ไฟล์ไบนารี `Helpdesk_KB_Portal.msapp` สำหรับนำเข้าสู่ Power Apps Maker Portal หรือเปิดรันบน Teams Desktop
