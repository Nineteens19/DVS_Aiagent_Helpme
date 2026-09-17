# Design Document: Helpdesk Knowledge Base Management Portal

## Summary
<!-- 10-line max digest for downstream phases. Later phases can read ONLY this section. -->
- **Architecture**: Low-Code Multi-Tier Enterprise Architecture with 4-Tier Container Auto-Layout Desktop 16:9
- **Stack**: Microsoft Power Apps (Canvas App Desktop 16:9 in YAML) / Power Fx / SharePoint Online / Power Automate / Power Platform CLI
- **Components**: `TopBarHeader`, `KPISummaryBar`, `ControlFilterBar`, `ManualsLibraryWorkspace`, `QnAKnowledgeGrid`, `KnowledgeGapsGrid`, `SlidingSideDrawer`, `RBACGuardController`
- **Entities**: `ManualDocument`, `QnAEntry`, `KnowledgeGap`, `MasterSystem`
- **Integrations**: SharePoint Online OData Connector, Power Automate Cloud Flow (`KB_CreateFolder`), Power Platform CLI (`pac canvas pack`)
- **Testing**: Multi-Viewport Desktop Benchmark (1366x768 & 1920x1080), 100% Delegable Query Verification, Full CRUD Operations — NFR [Yes]
- **Key Decisions**: D3-1 Standalone Canvas App `Helpdesk_KB_Portal`, D3-2 Deves Enterprise Theme (44px compact rows, 100% Emoji-Free), D3-3 Exact-Prefix Delegable Formulas, D3-4 Side Drawer State Management

---

## Architecture

### System Context Diagram
```
+-------------------------------------------------------------------------------------------------------+
|                                    Power Apps Canvas App: Helpdesk_KB_Portal                          |
|                                       (Desktop 16:9 Laptop/PC Optimized)                              |
|                                                                                                       |
|  +-------------------------------------------------------------------------------------------------+  |
|  | Tier 1: TopBarHeader (64px, Deves Deep Navy #012169) - System Title, Nav Tabs, User Role Profile|  |
|  +-------------------------------------------------------------------------------------------------+  |
|  | Tier 2: KPISummaryBar (96px) - Total Manuals | Approved | Total Q&A | Active Q&A | Pending Gaps    |  |
|  +-------------------------------------------------------------------------------------------------+  |
|  | Tier 3: ControlFilterBar (56px) - Instant Search Box | Systems Dropdown | Primary Action Buttons   |  |
|  +-------------------------------------------------------------------------------------------------+  |
|  | Tier 4: Workspace Split (Remaining Height)                                                     |  |
|  |  +-------------------------------------------------------------+  +--------------------------+  |  |
|  |  | Left Pane: High-Density Table / Gallery (44px Row Height)    |  | Right Pane: Sliding Side |  |  |
|  |  | - Tab 1: System Manuals & Folders (SystemManuals)           |  | Drawer Editor (480px)    |  |  |
|  |  | - Tab 2: Q&A Grid with Quick Toggle (AI_KnowledgeBase)       |  | - Add / Edit Q&A Form    |  |  |
|  |  | - Tab 3: Unanswered Questions Grid (KnowledgeGaps)          |  | - Delete with Confirm    |  |  |
|  |  +-------------------------------------------------------------+  +--------------------------+  |  |
|  +-------------------------------------------------------------------------------------------------+  |
+-------------------------------------------------------------------------------------------------------+
                     |                                       |                              |
                     | Direct OData (Delegable 100%)         | Flow Trigger (Create Folder) | Graph Crawl
                     v                                       v                              v
+-----------------------------------------------------------------------------------+  +----------------+
|             SharePoint Online Site: https://dvsins.sharepoint.com/sites/PowerAppPRD|  | Copilot Studio |
| - SystemManuals (Library)    - AI_KnowledgeBase (List 74 Q&A)                     |  | HelpMe Agent   |
| - Systems (Master List)      - KnowledgeGaps (List)                               |  | (RAG Index)    |
+-----------------------------------------------------------------------------------+  +----------------+
```

### Technology Stack
- **Client Application**: Microsoft Power Apps Canvas App (Desktop 16:9 Widescreen, 1366x768 to 1920x1080)
- **Source Code Schema**: Power Apps YAML Layout (`.pa.yaml`)
- **Formula Engine**: Microsoft Power Fx (Server-Side Delegable Queries)
- **Data Backend**: SharePoint Online (OData V3 Connector)
- **Folder Backend**: Power Automate Cloud Flow (`KB_CreateFolder`)
- **CLI Packaging Tool**: Power Platform CLI (`pac.exe` v1.45+)

### Key Design Decisions
1. **Dedicated Standalone App (D3-1)**: จัดทำแอปพลิเคชันแยกเฉพาะชื่อ `Helpdesk_KB_Portal` เพื่อความคล่องตัวและไม่เพิ่มภาระให้กับแอป `Monitor_case_Helpdesk`
2. **Deves Modern Enterprise Fluent Design (D3-2)**: โทนสีน้ำเงิน Deves Deep Navy (`#012169`), ตารางกระชับ 44px, ปราศจาก Emoji 100%
3. **100% Delegable Query Formulation (D3-3)**: ใช้สูตร `Filter` และ `StartsWith` พร้อม Indexed Columns รองรับข้อมูลเกิน 2,000 แถว ไร้ Delegation Warning
4. **Contextual Side Drawer (D3-4)**: ใช้ตัวแปร Local Context ควบคุมการเปิด/ปิดและโหมดของแบบฟอร์มอย่างรัดกุม

---

## Detailed Specifications

- [Components Specification](design/components.md) — โครงสร้าง 4-Tier Container และคอมโพเนนต์ย่อย
- [Data Model Specification](design/data-model.md) — แหล่งข้อมูล SharePoint 4 แห่ง และ In-Memory Collections
- [Integration Architecture](design/integration.md) — การเชื่อมต่อ OData, Power Automate Flow, และ Copilot Studio
- [Implementation Guide](design/implementation.md) — โครงสร้างโปรเจกต์ YAML และแนวทางการคอมไพล์ .msapp
- [Non-Functional Requirements](design/nfr.md) — มาตรฐาน Ergonomics 16:9, Latency < 0.3s, และ RBAC Security
