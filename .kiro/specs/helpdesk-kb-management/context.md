# Context Assessment: helpdesk-kb-management

## Summary
- **Type**: Brownfield
- **Stack**: Microsoft Copilot Studio (Generative AI) / SharePoint Online / Power Automate / Microsoft Power Apps
- **Architecture**: AI-Assisted Low-Code Knowledge Management & Federated Retrieval Architecture
- **Feature**: ระบบบริหารจัดการองค์ความรู้แบบรวมศูนย์ (Knowledge Base Management) ครอบคลุมเอกสารคู่มือระบบ (Manuals Document Library) และข้อมูล Q&A (SharePoint List) พร้อมกลไก Suggestion Menus ใน Copilot Studio และการย้ายศูนย์ข้อมูลสู่ Site เดียวกัน (PowerAppPRD)
- **Impact**: Extends existing knowledge sources and Modifies Copilot Studio agent configuration
- **Complexity**: Medium — 6 stories, 2 domains (KM Governance & Agent Conversational Experience), 2 user types (IT Helpdesk KB Admin & End-User)
- **Recommendations**: Personas [Yes], Units [Yes], NFR [Yes]

## Project Overview
- **Type**: Brownfield
- **Assessment Date**: 2026-09-17
- **Target System**: HelpMe Agent (Copilot Studio) & Monitor_case_Helpdesk (Power Apps)
- **Context Background**: ปัจจุบัน HelpMe Agent มีการดึงข้อมูลความรู้จาก 2 แหล่งหลัก ได้แก่ รายการ Q&A (`AI_KnowledgeBase_Helpdesk`) และไฟล์คู่มือระบบ (`Manual Systems`) ซึ่งปัจจุบันทั้งสองแหล่งถูกจัดเก็บบน SharePoint Site ต่างแผนก (`BusinessAnalystandHelpdesk`) ทำให้เกิดปัญหาเรื่อง Cross-site permissions, ความยากลำบากในการปรับปรุงโครงสร้าง (Schema Governance), การขาดสิทธิ์ในการตั้ง Flow อัตโนมัติ และความเสี่ยงต่อ Broken Links หากทีมเจ้าของ Site มีการเคลื่อนย้ายโฟลเดอร์

## Technology Stack
- **AI Agent Framework**: Microsoft Copilot Studio (Agent schema `cr616_helpMeAgentUat`, Engine `GPT55Chat`, Template `default-2.1.0`)
- **Knowledge Retrieval Engine**:
  - `FederatedStructuredSearchSource` (สำหรับ SharePoint List Q&A)
  - `SharePointSearchSource` (สำหรับ SharePoint Document Library / Semantic Search ในไฟล์คู่มือ)
- **Data Persistence & Document Management**: SharePoint Online (Site: `https://dvsins.sharepoint.com/sites/PowerAppPRD`)
- **Automation Layer**: Power Automate Cloud Flows
- **Management Client**: SharePoint Modern UI (Grid View, Document Library, Metadata Filter) / Power Apps (Optional KM Portal)

## Codebase Analysis (Brownfield)

**Architecture**: Multi-Source Generative Knowledge Architecture
- **Conversational Delivery**: `agent.mcs.yml` กำหนด System Prompt และ Instructions ในการคัดกรองข้อมูลเฉพาะรายการที่ `Review_Status = Approved` และ `Is_Active = Active`
- **Knowledge Sources Configuration**:
  - `HelpMe Agent/knowledge/cr616_helpMeAgentUat.topic.AI_KnowledgeBase_Helpdesk_4bdXIbH8F5fwgT6yMhK4U.mcs.yml`
  - `HelpMe Agent/knowledge/cr616_helpMeAgentUat.topic.ManualSystems_9SrlC8K2q_jCPnpBMmCOn.mcs.yml`
- **Conversational Flows & Menus**:
  - `Greeting.mcs.yml` / `ConversationStart.mcs.yml` เรียก Dialog `v4K.mcs.yml`
  - `v4K.mcs.yml` แสดงเมนูหลักด้วยโหนด `Question` แบบ `ClosedListEntity` (ระบุตัวเลือก 5 รายการระบบหลัก)

**Key Components**:
| Component | Purpose | Location |
|-----------|---------|----------|
| `agent.mcs.yml` | Master Agent Prompt, Guardrails, Model Settings | `HelpMe Agent/agent.mcs.yml` |
| `settings.mcs.yml` | Agent Channels, Semantic Search & AI Settings | `HelpMe Agent/settings.mcs.yml` |
| `v4K.mcs.yml` | In-Dialog Topic Navigation & Menu Options | `HelpMe Agent/topics/v4K.mcs.yml` |
| `AI_KnowledgeBase_Helpdesk...yml` | Configuration สำหรับเชื่อมต่อ Q&A List | `HelpMe Agent/knowledge/` |
| `ManualSystems...yml` | Configuration สำหรับเชื่อมต่อ Document Library | `HelpMe Agent/knowledge/` |
| `Cases`, `KnowledgeGaps` | ระบบเคสและบันทึกช่องว่างความรู้ | SharePoint `PowerAppPRD` |

## Feature Impact

**Affected Areas**:
- [ ] New standalone feature
- [x] Extends existing component (Knowledge Sources, SharePoint Schema)
- [x] Modifies existing behavior (ย้าย Location สู่ PowerAppPRD, ปรับแต่ง Topic Suggestions)
- [x] Cross-cutting concern (Permissions, Data Governance, Enterprise Search)

**Files & Configurations Likely to Change**:
| File / Resource | Change Type | Reason |
|-----------------|-------------|--------|
| SharePoint Site `PowerAppPRD` | New | สร้าง List `AI_KnowledgeBase` และ Document Library `SystemManuals` |
| `HelpMe Agent/knowledge/*.mcs.yml` | Modify | ชี้ URL แหล่งข้อมูลมายัง `PowerAppPRD` |
| `HelpMe Agent/agent.mcs.yml` | Modify | ปรับ Prompt ให้ระบุแหล่งข้อมูลและรูปแบบการ Suggest คำถามท้ายคำตอบ |
| `HelpMe Agent/topics/v4K.mcs.yml` | Modify | ปรับแต่งหรือปรับโครงสร้างตัวเลือก Suggestion ให้ยืดหยุ่น |
| `HelpMe Agent/topics/ConversationStart.mcs.yml` | Modify | เพิ่มเติม Prompt Starters / Conversation Starters |

## Recommendations

**Complexity Indicators**:
- Story Count: Medium (5-6 stories)
- Domain Boundaries: 2 domains (Knowledge Governance & Content Pipeline vs Conversational UI/UX)
- User Types: 2 (Helpdesk Admin / KB Contributor vs End-User)
- Integration Points: SharePoint Online (List & Library), Copilot Studio Federated Search

**Decision Gate Recommendations**:
- **Personas**: Yes — มีความต้องการชัดเจนระหว่าง ผู้ดูแลเนื้อหา (Admin/Contributor ที่ต้องการความสะดวกในการอัปโหลด/แก้ไข) กับ ผู้ใช้งานทั่วไป (ต้องการเมนูนำทางและคำตอบที่แม่นยำ)
- **Units**: Yes — แบ่งออกเป็น 2 ส่วนหลัก:
  1. `unit-kb-storage-governance`: โครงสร้าง SharePoint (List & Document Library) บน PowerAppPRD, สิทธิ์การเข้าถึง, กระบวนการเพิ่ม/ลด/อัปโหลดไฟล์
  2. `unit-agent-suggestions-config`: การเชื่อมต่อ Copilot Studio เข้ากับแหล่งข้อมูลใหม่, การตั้งค่า Conversation Starters และ In-Dialog Suggested Prompts
- **NFR**: Yes — เรื่องความถูกต้องของข้อมูล (Data Freshness), เวลาในการตอบสนอง (Response Latency), ความปลอดภัยและสิทธิ์การเข้าถึง (Access Control / Permissions)

## Next Steps
Proceed to Requirements phase (D1 Decision Gate → Requirements Specification)
