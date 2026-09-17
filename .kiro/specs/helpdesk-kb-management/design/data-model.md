# Design Specification: Data Model & Schema Architecture

## Overview
การออกแบบโมเดลข้อมูลสำหรับระบบ **Helpdesk Knowledge Base & Suggestion Management** ยึดหลักการ **AI Intelligence First** ตามมติที่ได้รับอนุมัติใน D1, D2 และ D3 โดยเน้นให้ AI สามารถสืบค้นแบบ Semantic Search ได้เต็มประสิทธิภาพ ข้อมูลทุกส่วนรวมศูนย์อยู่บน SharePoint Site `https://dvsins.sharepoint.com/sites/PowerAppPRD`

---

## 1. Document Library: `SystemManuals`

- **URL**: `https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals`
- **Internal Name**: `SystemManuals`
- **Description**: จัดเก็บเอกสารคู่มือระบบงานและระเบียบปฏิบัติมาตรฐาน (SOP)

| Column Display Name | Internal Name | Type | Constraints / Options | AI Usage & Rationale |
|---------------------|---------------|------|------------------------|----------------------|
| **File** | `FileLeafRef` | File Name | Required (PDF, DOCX) | เอกสารคู่มือตัวเต็มที่ Copilot Studio นำไป Index ทั้งเนื้อหา |
| **Title** | `Title` | Single line of text | Max 255 chars | ชื่อทางการของเอกสาร ใช้แสดงในผลการค้นหาและ Citations |
| **SystemName** | `SystemName` | Single line of text | Required | ชื่อระบบงานตามมาตรฐาน Master List `Systems` เพื่อให้ AI กรองและจับคู่คำถามได้ 100% |
| **DocType** | `DocType` | Choice | `User Manual`, `Admin Guide`, `SOP`, `FAQ`, `Release Notes` | จำแนกประเภทเอกสาร |
| **Status** | `Status` | Choice | `Draft`, `Approved`, `Archived` (Default: `Draft`) | AI ดึงเฉพาะสถานะ `Approved` เพื่อตอบผู้ใช้งาน |
| **Version** | `Version` | Single line of text | e.g. `1.0`, `2.1` | ควบคุมเวอร์ชันเอกสาร |
| **Keywords** | `Keywords` | Multiple lines of text | Plain text | คำสำคัญหรือคำค้นหาเฉพาะ (Synonyms, คำเฉพาะทาง) เพื่อช่วย Search Engine |
| **LastReviewed** | `LastReviewed` | Date and Time | Date Only | วันที่ทบทวนความถูกต้องของเนื้อหาล่าสุด |

---

## 2. SharePoint List: `AI_KnowledgeBase`

- **URL**: `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/AI_KnowledgeBase`
- **List GUID**: `95e5e09d-6d20-4811-8833-820cef88fe98`
- **Description**: จัดเก็บข้อคำถาม-คำตอบ (Q&A) 74 รายการเดิมและคำถามเพิ่มเติมที่ตอบบ่อย

| Column Display Name | Internal Name | Type | Constraints / Options | AI Usage & Rationale |
|---------------------|---------------|------|------------------------|----------------------|
| **Title** | `Title` | Single line of text | Required (Max 255) | หัวเรื่อง/คำถามหลัก ใช้เป็น primary trigger ในการสืบค้น |
| **Question** | `Question` | Multiple lines of text | Plain text | รายละเอียดคำถาม หรือคำถามในรูปแบบต่างๆ ที่ผู้ใช้อาจพิมพ์ถาม |
| **Answer** | `Answer` | Multiple lines of text | Plain text / Rich text | คำตอบและแนวทางแก้ไขปัญหาที่ Agent จะนำไปตอบผู้ใช้ |
| **System** | `System` | Single line of text | Required | ชื่อระบบงานตาม Master List `Systems` เพื่อจับคู่กับระบบ |
| **Category** | `Category` | Single line of text | Optional | หมวดหมู่ปัญหา เช่น `การใช้งาน`, `สิทธิ์การเข้าถึง`, `รหัสผ่าน` |
| **Keywords** | `Keywords` | Multiple lines of text | Plain text | คำค้นหา คีย์เวิร์ด และคำพ้องความหมาย |
| **Status** | `Status` | Choice | `Active`, `Inactive` (Default: `Active`) | AI ดึงเฉพาะข้อที่มีสถานะ `Active` เท่านั้น |

---

## 3. Master Systems Reference Entity

- **URL**: `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/Systems`
- **List GUID**: `37a7b3db-d9ef-4cf8-b3f7-920f0ee3ee9a`
- **Purpose**: ตาราง Master อ้างอิงรายชื่อระบบมาตรฐานทั้ง 31 ระบบขององค์กร สำหรับกรอกในคอลัมน์ `SystemName` และ `System`

### รายชื่อระบบมาตรฐานสำคัญ (Top Systems):
1. `Renewal Motor` (ระบบต่ออายุประกันภัยรถยนต์)
2. `DSS` (ระบบงานขายและบริการตัวแทน)
3. `PCS` (ระบบจัดการสินไหมทดแทน)
4. `Polisy 400` (ระบบประกันภัยหลัก Core Insurance)
5. `CRM`, `HRIS`, `Smart Form`, `BI Dashboard`, อื่นๆ รวม 31 ระบบ

---

## 4. Entity Relationship Diagram (Conceptual)

```
+-------------------------------------------------------------+
|                  Master List: Systems                       |
|  - Title (System Name, e.g. "Renewal Motor", "DSS")          |
|  - SystemCode, Status, Description                          |
+-------------------------------------------------------------+
             ^                                   ^
             | (Plain-text standard name)        | (Plain-text standard name)
             |                                   |
+---------------------------+       +---------------------------+
| Library: SystemManuals    |       | List: AI_KnowledgeBase    |
| - FileLeafRef (PDF/Word)  |       | - Title (Question Title)  |
| - SystemName (Text)       |       | - System (Text)           |
| - DocType (Choice)        |       | - Question (Multiline)    |
| - Status (Approved)       |       | - Answer (Multiline)      |
| - Keywords (Text)         |       | - Status (Active)         |
+---------------------------+       +---------------------------+
             \                                   /
              \                                 /
               v                               v
       +-----------------------------------------------+
       |       Copilot Studio Knowledge Engine         |
       |  (M365 Graph / Azure OpenAI Semantic Search)  |
       +-----------------------------------------------+
```
