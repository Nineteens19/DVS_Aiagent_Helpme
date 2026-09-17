# Units of Work: Helpdesk Knowledge Base & Suggestion Management

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Units**: 2 units — `kb-storage-governance`, `agent-conversational-ux`
- **Strategy**: Layer-Based (Data Storage & Governance Layer vs Conversational AI UX Layer)
- **Architecture**: Copilot Studio Generative AI RAG connected to SharePoint PowerAppPRD Site (Document Library + SharePoint List)
- **Story Distribution**: Unit 1 (kb-storage-governance): 3 stories (US-KB-001, US-KB-002, US-KB-003) | Unit 2 (agent-conversational-ux): 3 stories (US-KB-004, US-KB-005, US-KB-006)
- **Key Dependencies**: Unit 2 (agent-conversational-ux) → Unit 1 (kb-storage-governance) [Data/Schema Dependency]
- **Development Sequence**: Phase 1: Unit 1 (`kb-storage-governance`), Phase 2: Unit 2 (`agent-conversational-ux`)

---

## Overview
ฟีเจอร์การบริหารจัดการ Knowledge Base และระบบเมนูตัวช่วยนำทาง (Suggestion Menus) ถูกแบ่งการส่งมอบออกเป็น 2 หน่วยงาน (Units of Work) เพื่อให้เกิดความชัดเจนในการแบ่งแยกความรับผิดชอบระหว่าง **ชั้นจัดเก็บข้อมูลและการควบคุม (Data Storage & Governance)** กับ **ชั้นประสบการณ์ผู้ใช้และการสนทนาของ AI (Conversational AI UX)**

**Strategy**: Layer-Based Decomposition  
**Rationale**:
1. **Clear Boundary**: แยกโครงสร้างข้อมูลสิทธิ์การเข้าถึง (SharePoint Data Layer) ออกจากการตั้งค่า Agent Logic และ Prompting (Copilot Studio Platform Layer)
2. **Independent Testability**: Unit 1 สามารถตรวจสอบความถูกต้องของ Schema, สิทธิ์ RBAC, และความสมบูรณ์ของข้อมูล Q&A 74 รายการได้โดยอิสระ ส่วน Unit 2 สามารถทดสอบการตอบคำถาม การอ้างอิงแหล่งข้อมูล (Citations) และคุณภาพของ Prompt ได้หลังจาก Unit 1 พร้อมใช้งาน
3. **Low Latency & High AI Intelligence**: การจัดโครงสร้างแยกกันช่วยให้ควบคุมประสิทธิภาพการตอบสนองได้ตามข้อตกลง D2-4 (High-Speed Hybrid with AI Disambiguation)

---

## Unit 1: `kb-storage-governance`

**Purpose**: จัดเตรียมและควบคุมแหล่งเก็บข้อมูลองค์ความรู้บน SharePoint Site `PowerAppPRD` ทั้งคลังเอกสารคู่มือ (`SystemManuals`) และรายการคำถาม-คำตอบ (`AI_KnowledgeBase`) พร้อมกลไกกำกับดูแลสถานะความถูกต้อง (Approval & Active Status)  
**Priority**: High  
**Complexity**: Medium  
**Stories**: 3 stories — US-KB-001, US-KB-002, US-KB-003  

### Commands & Operations
| Operation / Action | Description | Actor |
|--------------------|-------------|-------|
| `UploadManualDocument` | อัปโหลดไฟล์คู่มือ PDF/Word พร้อมระบุ Metadata (`SystemName`, `DocType`, `Status`) | IT Helpdesk Admin |
| `ImportQnAEntries` | นำเข้าคำถาม-คำตอบ 74 รายการสู่ SharePoint List พร้อมแมปหมวดหมู่และระบบ | IT Helpdesk Admin |
| `UpdateContentStatus` | ปรับสถานะเนื้อหาเป็น `Draft`, `Approved`, หรือ `Archived` เพื่อควบคุมการนำไปใช้ของ AI | IT Helpdesk Admin / BA |
| `ConfigureRBACPermissions` | กำหนดสิทธิ์แบบ Read-only สำหรับผู้ใช้ทั่วไป และ Full Control สำหรับ Admin | IT Helpdesk Admin |

### Domain Model
- **Aggregates**:
  - `KnowledgeItem` (Root: `AI_KnowledgeBase` Item)
  - `ManualDocument` (Root: `SystemManuals` File Item)
- **Entities & Schemas**:
  - `ManualDocument`: `FileLeafRef` (Title/Filename), `SystemName` (Single line of text), `DocType` (Choice: User Manual, Admin Guide, SOP), `Status` (Choice: Draft, Approved, Archived), `Keywords` (Multiple lines of text)
  - `QnAEntry`: `Title` (Single line of text - คำถามหลัก), `Question` (Multiple lines of text - รายละเอียดคำถาม), `Answer` (Multiple lines of text - คำตอบ), `System` (Single line of text), `Category` (Single line of text), `Keywords` (Multiple lines of text), `Status` (Choice: Active, Inactive)
- **Value Objects**:
  - `SystemIdentifier`: Plain text string ที่สอดคล้องกับ Master List `Systems` (e.g. "Renewal Motor", "DSS", "PCS", "Polisy 400") เพื่อประสิทธิภาพ Semantic Search สูงสุด

### Domain Events & Triggers
- **Publishes**:
  - `KnowledgeUpdated`: ส่งสัญญาณเมื่อมีการเพิ่ม/แก้ไขเนื้อหา เพื่อให้ดัชนี Copilot Studio ทยอยอัปเดต
  - `ContentArchived`: ส่งสัญญาณเมื่อเนื้อหาถูกระงับ เพื่อป้องกันการตอบข้อมูลล้าสมัย
- **Subscribes**: ไม่มี (เป็นชั้นล่างสุดของระบบ)

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| Master List `Systems` | Reference Data | ใช้อ้างอิงรายชื่อระบบมาตรฐานสำหรับกรอกในฟิลด์ `SystemName` และ `System` |
| Microsoft 365 Tenant Auth | Security/Auth | การจัดการสิทธิ์ผ่าน M365 Groups & SharePoint Permission Levels |

---

## Unit 2: `agent-conversational-ux`

**Purpose**: ปรับแต่ง Copilot Studio Agent (`HelpMe Agent`) ให้เชื่อมต่อกับคลังข้อมูลใหม่บน `PowerAppPRD`, จัดการเมนูเริ่มต้นการสนทนา (Conversation Starters), ออกแบบเมนูตัวเลือกระบบใน Topic `v4K` แบบ High-Speed Hybrid และสร้างคำถามแนะนำต่อยอด (Follow-up Suggestions) หลังการตอบ  
**Priority**: High  
**Complexity**: Medium  
**Stories**: 3 stories — US-KB-004, US-KB-005, US-KB-006  

### Commands & Operations
| Operation / Action | Description | Actor |
|--------------------|-------------|-------|
| `RepointKnowledgeSources` | ปรับแก้ YAML ให้ Copilot Studio ชี้ URL ไปที่ `SystemManuals` และ `AI_KnowledgeBase` ใหม่ | Solution Architect / Developer |
| `DeliverSystemSuggestions` | นำเสนอ Quick Replies / ตัวเลือกระบบหลัก 4-5 ระบบแรก พร้อมตัวเลือกพิมพ์เอง | HelpMe Agent |
| `GenerateGroundedAnswer` | สังเคราะห์คำตอบจากเอกสารและ Q&A ด้วย Azure OpenAI Semantic Search พร้อมระบุ Reference Citation | HelpMe Agent |
| `ProvideFollowUpSuggestions` | สรุปคำถามที่เกี่ยวข้อง 2 ข้อท้ายคำตอบ เพื่อให้ผู้ใช้กดถามต่อได้ทันที | HelpMe Agent |

### Conversational Architecture
- **Knowledge Components**:
  - `ManualSystems_9SrlC8K2q_jCPnpBMmCOn.mcs.yml`: ชี้ไปยัง `https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals`
  - `AI_KnowledgeBase_SPList.mcs.yml`: ชี้ไปยัง `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/AI_KnowledgeBase`
- **Topics & Dialog Flow**:
  - `agent.mcs.yml`: System Instructions กำหนด Guardrails, Prompt instructions สำหรับการเสนอคำถามเกี่ยวเนื่อง 2 ข้อ, และการตรวจจับชื่อระบบเทียบกับ Master Systems
  - Topic `v4K` (System Inquiries): ปรับเมนูตัวเลือกระบบแบบ High-Speed Hybrid โดยมีระบบยอดนิยม (DSS, Renewal Motor, PCS, Polisy 400, อื่นๆ)
- **Generative AI Settings**:
  - Search Scope: Grounded only on Approved / Active data from PowerAppPRD
  - Citation Enforcement: แสดงลิงก์อ้างอิงเสมอ

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| Unit 1 (`kb-storage-governance`) | Data & Schema | ต้องการ Document Library และ SharePoint List บน `PowerAppPRD` ที่มีสิทธิ์และข้อมูลพร้อม |
| Power Platform CLI (`pac`) | Deployment Tooling | ใช้สำหรับ `pac copilot push` และ `pac copilot publish` สู่ Environment |

---

## Context Map

### Relationships
| Upstream (Supplier) | Downstream (Customer) | Pattern | Relationship Description |
|---------------------|-----------------------|---------|--------------------------|
| Unit 1: `kb-storage-governance` | Unit 2: `agent-conversational-ux` | Customer/Supplier | Unit 1 ส่งมอบข้อมูลและ Schema ที่ได้มาตรฐานให้ Unit 2 นำไป Search & Ground |
| Master List `Systems` | Unit 1 & Unit 2 | Shared Kernel / Reference | รายชื่อระบบที่เป็น Master อ้างอิงร่วมกันเพื่อความสอดคล้อง |

---

## Development & Delivery Sequence

### Phase 1: Foundation & Data Preparation (Unit 1)
- [x] จัดเตรียม Document Library `SystemManuals` บน `PowerAppPRD`
- [x] จัดเตรียม SharePoint List `AI_KnowledgeBase` บน `PowerAppPRD` (List ID: `95e5e09d-6d20-4811-8833-820cef88fe98`)
- [x] แปลงและนำเข้าข้อมูล Q&A 74 รายการเข้าสู่ SharePoint List
- [x] ตรวจสอบความถูกต้องของคอลัมน์ `System` และ `SystemName` แบบ Single line of text

### Phase 2: Agent Reconfiguration & Conversational UX (Unit 2)
- [x] ปรับแก้ YAML files ชี้ Knowledge Sources ไปยังไซต์ `PowerAppPRD`
- [x] กำหนด Guardrails และ Prompt ใน `agent.mcs.yml` ให้แสดงคำถามแนะนำ 2 ข้อ
- [x] Deploy และ Publish Copilot Studio Agent ผ่าน `pac` CLI
- [ ] ทดสอบการค้นหาและตอบคำถามจริงใน Copilot Studio Test Pane

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| SharePoint Search Indexing Delay | Medium | ดัชนีการค้นหาของ SharePoint อาจใช้เวลา 15-30 นาทีในการ Index ข้อมูลและไฟล์ใหม่ ให้ทดสอบคำถามที่มีใน List หลัง Index เสร็จสิ้น |
| Non-standard System Name Input | Low | กำหนดให้ AI Prompt มีตรรกะ Disambiguation จับคู่ชื่อระบบที่ผู้ใช้พิมพ์กับรายชื่อระบบใน Master List `Systems` อัตโนมัติ |
| Permissions Mismatch | Medium | ตรวจสอบให้แน่ใจว่าผู้ใช้งานทั่วไปมีสิทธิ์ Read-only บนทั้ง `SystemManuals` และ `AI_KnowledgeBase` เพื่อไม่ให้ Agent ขาดสิทธิ์ในการดึงข้อมูล |
