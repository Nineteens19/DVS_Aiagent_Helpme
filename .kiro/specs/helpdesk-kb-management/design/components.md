# Design Specification: Component Architecture

## Overview
สถาปัตยกรรมเชิงคอมโพเนนต์ของระบบ **Helpdesk Knowledge Base & Suggestion Management** ออกแบบตามสถาปัตยกรรม 2 หน่วยงาน (Layer-Based Decomposition) เพื่อแยกความรับผิดชอบระหว่าง **ชั้นจัดเก็บข้อมูลและการควบคุม (Storage & Governance)** และ **ชั้นการสืบค้นและประสบการณ์ผู้ใช้ (Conversational AI UX)** อย่างชัดเจน

---

## 1. Storage & Governance Layer (`kb-storage-governance`)

### 1.1 `SystemManuals` (Document Library Component)
- **Host**: SharePoint Online (`https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals`)
- **Purpose**: จัดเก็บไฟล์คู่มือระบบ, สถาปัตยกรรมระบบ, และระเบียบปฏิบัติมาตรฐาน (SOP) ในรูปแบบ PDF, Word (.docx)
- **Key Responsibilities**:
  - จัดเก็บไฟล์เอกสารพร้อมรองรับการค้นหาเชิงความหมาย (Semantic Search) ของ M365 Graph Search Indexer
  - ควบคุมสถานะเอกสารผ่าน Metadata: `Status` (Draft, Approved, Archived) โดย Agent จะดึงเฉพาะเอกสารสถานะ `Approved`
  - ระบุชื่อระบบด้วยคอลัมน์ `SystemName` (`Single line of text`) ยึดตามชื่อใน Master List `Systems` เพื่อให้ AI จับคู่คำค้นได้แม่นยำ 100%
- **Security & Access Control**:
  - IT Helpdesk Admin / BA: Full Control (อัปโหลด, แก้ไข, ลบ, อนุมัติ)
  - All Internal Users (Domain Users): Read-only

### 1.2 `AI_KnowledgeBase` (SharePoint List Component)
- **Host**: SharePoint Online (`https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/AI_KnowledgeBase`)
- **List GUID**: `95e5e09d-6d20-4811-8833-820cef88fe98`
- **Purpose**: จัดเก็บฐานข้อมูลข้อคำถาม-คำตอบ (Q&A Pairs) เดิม 74 รายการและคำถามที่เพิ่มใหม่ในอนาคต
- **Key Responsibilities**:
  - รองรับการค้นหาคำถาม-คำตอบที่สั้นกระชับและแก้ไขบ่อย โดยไม่ต้องทำเอกสารเป็นไฟล์เต็ม
  - คัดกรองเฉพาะเรคอร์ดที่มี `Status: Active` เพื่อนำไปตอบในแชท
  - แมปชื่อระบบผ่านคอลัมน์ `System` (`Single line of text`) ให้ตรงกับ Master List `Systems`
- **Security & Access Control**:
  - IT Helpdesk Admin: Full Control / Edit
  - All Users: Read-only

---

## 2. Conversational AI UX Layer (`agent-conversational-ux`)

### 2.1 `HelpMeAgentRAG` (Copilot Studio Knowledge Engine)
- **Host**: Microsoft Copilot Studio (Bot ID: `76812e27-6dce-f011-8544-6045bd592e11`)
- **YAML Components**:
  - `ManualSystems_9SrlC8K2q_jCPnpBMmCOn.mcs.yml`: ชี้ไปยัง `https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals`
  - `AI_KnowledgeBase_SPList.mcs.yml`: ชี้ไปยัง `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/AI_KnowledgeBase`
- **Grounding & Moderation (ตามมติ D3-1)**:
  - **Strict Grounding**: สังเคราะห์คำตอบเฉพาะจากข้อมูลที่มีอยู่ใน `SystemManuals` และ `AI_KnowledgeBase` บน `PowerAppPRD` เท่านั้น
  - **Zero Hallucination**: หากไม่พบข้อมูล ห้ามแต่งคำตอบหรือคาดเดา ให้แจ้งผู้ใช้ตามตรงว่าไม่พบข้อมูลในคู่มือ
  - **Escalation**: ให้คำแนะนำในการติดต่อเจ้าหน้าที่ IT Helpdesk หรือเปิดเคสใหม่ในระบบ `HelpMe` ทันที
  - **Citation Link**: แสดงแหล่งที่มาและลิงก์ของเอกสารอ้างอิงเสมอ

### 2.2 `ConversationalMenuUX` (Topic `v4K` & System Selection)
- **Topic**: `HelpMe Agent/topics/v4K.mcs.yml`
- **Design Pattern (ตามมติ D3-2)**: **Static Top Systems with AI Free-text Disambiguation**
- **Flow Logic**:
  1. เมื่อผู้ใช้สอบถามเรื่องระบบ หรือเลือกเมนูเริ่มต้นระบบ จะแสดงตัวเลือก Quick Replies สำหรับ Top 4 ระบบที่มีเคสสูงสุด:
     - `1. Renewal Motor`
     - `2. DSS`
     - `3. PCS`
     - `4. Polisy 400`
     - `5. ระบบอื่นๆ (พิมพ์ชื่อระบบ)`
  2. การเลือกผ่านปุ่ม Quick Reply จะทำงานทันทีด้วยค่า Latency 0 วินาที (ไม่ผ่าน Power Automate)
  3. หากผู้ใช้เลือกข้อ 5 หรือพิมพ์ข้อความเอง AI System Instructions ใน `agent.mcs.yml` จะทำ Disambiguation ตรวจสอบชื่อระบบกับ Master List `Systems` และช่วยแนะนำต่ออย่างชาญฉลาด

### 2.3 `PromptFollowUpEngine` (AI Follow-up Question Suggestion)
- **Host**: `HelpMe Agent/agent.mcs.yml`
- **Format (ตามมติ D3-3)**: **Inline Markdown Prompt Bullets**
- **Logic**:
  - ทุกครั้งที่ AI สังเคราะห์คำตอบเสร็จสิ้น จะต่อท้ายด้วยหัวข้อ:
    ```markdown
    ---
    คำถามที่อาจเกี่ยวข้อง:
    - [คำถามสั้นที่ผู้ใช้อาจต้องการถามต่อ ข้อที่ 1]
    - [คำถามสั้นที่ผู้ใช้อาจต้องการถามต่อ ข้อที่ 2]
    ```
  - คำถามแนะนำจะต้องดึงมาจากบริบทที่เกี่ยวข้องในคู่มือหรือข้อคำถามอื่นๆ เพื่อให้ผู้ใช้สามารถ Copy หรือพิมพ์ถามต่อได้ทันที

---

## 3. Governance & Lifecycle Sync Component

### 3.1 `IndexSyncGovernance` (ตามมติ D3-4)
- **Automatic Crawl**: Copilot Studio และ Microsoft Graph Indexer จะทยอยอัปเดตดัชนีการค้นหาแบบ Background Sync ภายใน 15-60 นาที หลังมีการแก้ไขข้อมูลใน SharePoint
- **Manual Force Index Procedure**: จัดทำคู่มือ SOP สำหรับ IT Helpdesk Admin ในกรณีต้องการ Force Sync ทันทีหลังอัปโหลดไฟล์คู่มือใหม่ฉุกเฉิน
