# Requirements: helpdesk-kb-management

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Total Stories**: 6 across 2 functional areas
- **Priority**: 4 High, 2 Medium, 0 Low
- **User Types**: IT Helpdesk / KB Admin, General End-User (พนักงานและตัวแทน)
- **Key Entities**: `SystemManuals` (Document Library), `AI_KnowledgeBase` (SharePoint List), `KnowledgeGaps`, `HelpMe Agent`
- **Integrations**: SharePoint Online (`https://dvsins.sharepoint.com/sites/PowerAppPRD`), Microsoft Copilot Studio
- **Core Flows**:
  1. เจ้าหน้าที่อัปโหลดคู่มือระบบแยกโฟลเดอร์ พร้อมระบุ Metadata บน Site กลาง PowerAppPRD
  2. เจ้าหน้าที่สร้าง/ปรับปรุงบทความ Q&A ผ่านโหมด Grid View พร้อมควบคุมสถานะ Draft/Review Required/Approved
  3. ผู้ใช้เปิดหน้าแชทและเห็นปุ่ม Conversation Starters นำทางคำถามยอดนิยมทันที
  4. AI สแกนค้นหาคำตอบเฉพาะรายการที่ Approved + Active พร้อมระบุเลขอ้างอิง KB_ID
  5. AI เสนอคำถามที่เกี่ยวข้อง 2 ข้อท้ายคำตอบ เพื่อให้ผู้ใช้เลือกกดถามต่อยอดได้ทันที

## Overview
เอกสารข้อกำหนดความต้องการนี้ระบุคุณลักษณะของระบบจัดการองค์ความรู้ (Knowledge Base Management) และระบบเมนูแนะนำ (Suggestion Menus) สำหรับ HelpMe Agent โดยกำหนดเงื่อนไขการยอมรับตามรูปแบบ EARS Notation (Easy Approach to Requirements Syntax)

---

## Functional Area 1: Knowledge Base Storage & Governance (การจัดการคลังความรู้และการกำกับดูแล)

### US-KB-001: Centralized System Manuals Management
**As an** IT Helpdesk / KB Admin  
**I want** to upload, organize, and manage system user manuals in a dedicated Document Library on `PowerAppPRD`  
**So that** all system documentation is securely centralized and easily indexed by Copilot Studio without risk of cross-site permission issues

**Priority**: High

**Acceptance Criteria**:
1. **The system shall** provide a SharePoint Document Library named `SystemManuals` on `https://dvsins.sharepoint.com/sites/PowerAppPRD` with subfolders for each core system (`DSS`, `Renewal_Motor`, `PCS`, `Polisy_400`, `CMI`, `General`).
2. **WHEN** an administrator uploads document files (PDF, Word, Excel, PPTX) into a folder, **THEN** the system shall support drag-and-drop and allow tagging with `SystemName` (Single line of text matching Master List `Systems` for optimal AI semantic indexing), `DocType`, and `IsActive` metadata columns.
3. **The system shall** maintain SharePoint version history for each document file to enable version rollback and change tracking.
4. **IF** a document file has `IsActive` set to `No`, **THEN** the system shall exclude the document from active search indexing in Copilot Studio, **ELSE** include it in search retrieval.
5. **WHERE** user belongs to `Everyone except external users`, **THEN** the system shall restrict access permissions to Read Only.

**Dependencies**: None

---

### US-KB-002: Structured Q&A Knowledge Articles Management
**As an** IT Helpdesk / KB Admin  
**I want** to manage structured Q&A articles via a dedicated SharePoint List with grid editing and approval lifecycle  
**So that** standard solutions can be added, updated, and validated quickly without manual coding

**Priority**: High

**Acceptance Criteria**:
1. **The system shall** provide a SharePoint List named `AI_KnowledgeBase` on `PowerAppPRD` containing columns: `KB_ID`, `Issue_Title`, `System` (Single line of text matching Master List `Systems` for optimal AI semantic indexing), `Category`, `Keywords`, `Approved_Answer`, `Required_Information`, `Followup_Question`, `Action_Type`, `Escalation_Rule`, `Owner`, `Review_Status`, and `Is_Active`.
2. **The system shall** ensure that all multiple-line text columns (`Approved_Answer`, `Keywords`, `Required_Information`, `Followup_Question`) are configured as Plain text without rich HTML formatting.
3. **WHEN** an administrator accesses `AI_KnowledgeBase`, **THEN** the system shall support SharePoint Modern "Edit in grid view" to batch create and edit articles similar to a spreadsheet.
4. **WHEN** an administrator enters a new Q&A record, **THEN** the system shall default `Review_Status` to `Draft` and `Is_Active` to `Active`.
5. **WHERE** user belongs to IT Helpdesk group, **THEN** the system shall grant Edit/Contribute permissions, while granting Read Only permissions to general employees.

**Dependencies**: None

---

### US-KB-003: Knowledge Retrieval & Governance Guardrails
**As a** General End-User  
**I want** HelpMe Agent to provide answers retrieved exclusively from verified, approved knowledge sources  
**So that** I receive accurate, up-to-date guidance and avoid unverified or draft instructions

**Priority**: High

**Acceptance Criteria**:
1. **WHILE** evaluating questions against `AI_KnowledgeBase`, **IF** `Review_Status` is NOT equal to `Approved` OR `Is_Active` is NOT equal to `Active`, **THEN** the agent shall ignore that record and shall not use its content for user answers.
2. **WHEN** the agent answers an inquiry using `AI_KnowledgeBase`, **THEN** the agent shall reference and display the `KB_ID` at the end of the response.
3. **WHEN** the agent answers an inquiry using `SystemManuals`, **THEN** the agent shall cite the source document name and relevant section.
4. **IF** no approved knowledge record or active manual matches the user inquiry, **THEN** the agent shall inform the user that verified information was not found and offer to log a support case to Helpdesk, **ELSE** present the approved answer.

**Dependencies**: US-KB-001, US-KB-002

---

## Functional Area 2: Conversational Guidance & Suggestion Menus (ระบบนำทางและเมนูแนะนำการสนทนา)

### US-KB-004: Conversation Starters for Initial Engagement
**As a** General End-User  
**I want** to see interactive prompt buttons (Conversation Starters) floating on the screen when I first open HelpMe Agent  
**So that** I can trigger common support inquiries with a single click without having to type complex technical descriptions

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** a user launches the HelpMe Agent chat window, **THEN** the system shall display a set of at least 4 Conversation Starters representing top support scenarios:
   - "แจ้งปัญหาระบบ DSS เข้าไม่ได้"
   - "ขอปลดล็อค User หรือรีเซ็ตรหัสผ่าน"
   - "ติดตามสถานะเคสของฉัน"
   - "สอบถามวิธีใช้งานระบบ Renewal Motor"
2. **WHEN** a user clicks on any Conversation Starter button, **THEN** the chat client shall immediately submit that prompt as a message and trigger the corresponding topic or search.
3. **The system shall** enable administrators to configure and update Conversation Starter labels via Copilot Studio configuration without redeploying code.

**Dependencies**: None

---

### US-KB-005: In-Dialog System Selection Suggestions
**As a** General End-User  
**I want** to be guided through quick reply buttons when selecting which internal system I need help with  
**So that** my inquiry is accurately scoped to the right application domain

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** the agent executes topic `v4K` or `Greeting`, **THEN** the system shall present action choices as interactive quick-reply buttons.
2. **WHEN** the user selects "แจ้งปัญหาระบบ", **THEN** the system shall present quick-reply buttons for target systems dynamically populated from SharePoint Master List `Systems` where `IsActive = true`, along with an option "อื่นๆ (ระบุเอง)".
3. **IF** the user selects "อื่นๆ (ระบุเอง)", **THEN** the agent shall prompt the user with an open text input to capture the specific system name.
4. **The system shall** store the selected system name in dialog variable `Topic.IssueSystemName` for subsequent routing and case logging.

**Dependencies**: None

---

### US-KB-006: AI Generative Follow-up Recommendations
**As a** General End-User  
**I want** HelpMe Agent to suggest 2 relevant follow-up questions at the end of every answer retrieved from the knowledge base  
**So that** I can continue exploring next steps or related procedures seamlessly

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** the agent returns a resolved answer based on `AI_KnowledgeBase` or `SystemManuals`, **THEN** the agent shall append a concluding section titled "คำถามที่เกี่ยวข้อง" containing 2 concise suggested questions related to the current context.
2. **WHILE** generating follow-up suggestions, **IF** the user issue requires opening an incident or service request (Action_Type != Self-Service), **THEN** the agent shall include an option to initiate case creation as one of the suggestions.
3. **WHEN** the user types or clicks one of the suggested follow-up questions, **THEN** the agent shall process it in context of the existing session.

**Dependencies**: US-KB-003

---

## Story Summary

| ID | Title | Area | Priority | Dependencies |
|----|-------|------|----------|--------------|
| US-KB-001 | Centralized System Manuals Management | Storage & Governance | High | None |
| US-KB-002 | Structured Q&A Knowledge Articles Management | Storage & Governance | High | None |
| US-KB-003 | Knowledge Retrieval & Governance Guardrails | Storage & Governance | High | US-KB-001, US-KB-002 |
| US-KB-004 | Conversation Starters for Initial Engagement | Guidance & Suggestions | High | None |
| US-KB-005 | In-Dialog System Selection Suggestions | Guidance & Suggestions | Medium | None |
| US-KB-006 | AI Generative Follow-up Recommendations | Guidance & Suggestions | Medium | US-KB-003 |

---

## Story-Persona Matrix

| Story | สมชาย (IT Helpdesk) | นารี (End-User) |
|-------|---------------------|-----------------|
| US-KB-001 | ✓ Primary | ✓ Secondary |
| US-KB-002 | ✓ Primary | ✓ Secondary |
| US-KB-003 | ✓ Secondary | ✓ Primary |
| US-KB-004 | ✓ Secondary | ✓ Primary |
| US-KB-005 | ✓ Secondary | ✓ Primary |
| US-KB-006 | ✓ Secondary | ✓ Primary |

---

## Non-Functional Considerations
- **Search Retrieval Latency**: การสืบค้นผ่าน Copilot Studio Federated Search ต้องให้คำตอบแก่ผู้ใช้ภายในเวลาไม่เกิน 5-8 วินาที
- **Data Freshness**: ข้อมูลที่อัปเดตใน SharePoint List หรือ Document Library จะต้องพร้อมให้ Copilot Studio สแกนและนำไปตอบได้ตามรอบ Indexing ของ Microsoft 365 Semantic Search
- **Formatting Consistency**: คำตอบภาษาไทยต้องสุภาพ ถูกต้องตามหลักไวยากรณ์ และไม่มี HTML/Tag ขยะปะปน
- **Security & Access Control**: การเข้าถึงไฟล์เอกสารและตาราง Q&A ถูกควบคุมด้วย SharePoint Role-Based Access Control ป้องกันการเข้าถึงหรือแก้ไขโดยไม่ได้รับอนุญาต
