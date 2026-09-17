# Design Document: Monitor_case_Helpdesk

## Summary
- **Architecture**: Single-Screen Master-Detail with Collapsible Side Drawer — รวมหน้าจอเป็นหน้าเดียวบน `Home_incident` ลดเวลาโหลดและประหยัดคลิกบนจอ Laptop
- **Stack**: Microsoft Power Apps (Canvas YAML) / SharePoint Online Lists / Power Platform CLI (`pac`)
- **Components**: `cmp_AppHeader`, `cmp_KpiSummaryBar`, `cmp_ControlFilterBar`, `cmp_CaseTableGallery`, `cmp_ResolutionSideDrawer`
- **Entities**: `Cases` (Primary List + 2 New Columns + Attachments), `Systems` (Lookup List)
- **Integrations**: SharePoint Online Connector (RPC over OData), Office 365 Users Connector
- **Design Tokens**: Fluent Slate & Deves Corporate Deep Navy (`#012169`) — Zero Emoji 100%
- **Delegation Compliance**: สูตร Server-side Delegable 100% ปราศจาก Warning 2,000 แถว
- **Resolution Evidence**: Native EditForm Attachment Control บังคับแนบไฟล์หลักฐานและสรุปวิธีแก้ไขก่อนปิดเคส
- **Testing & Verification**: Comprehensive 4-Pillar Verification (Delegation Audit, Form Validation, Laptop Layout Check, PAC Canvas Pack Integrity)

---

## Architecture

### System Context Diagram
```
+--------------------------------------------------------------------------------------------------+
| Microsoft 365 Cloud Tenant (Deves Insurance)                                                     |
|                                                                                                  |
|   +------------------------------------------------------------------------------------------+   |
|   | SharePoint Online Site: /sites/PowerAppPRD                                              |   |
|   |                                                                                          |   |
|   |   +---------------------------------------+      +-----------------------------------+   |   |
|   |   | List: Cases                           |      | List: Systems                     |   |   |
|   |   | - 5 Indexed Columns for Delegation    |      | - List of Active Systems          |   |   |
|   |   | - ResolutionCategory [NEW]            |      +-----------------------------------+   |   |
|   |   | - ResolutionSummary [NEW]             |                        ^                     |   |
|   |   | - Native Item Attachments Collection  |                        |                     |   |
|   |   +---------------------------------------+                        |                     |   |
|   +-----------------------^--------------------------------------------+---------------------+   |
|                           | OData Queries (Delegated Filter)           | Lookup Query            |
|                           | Multi-part Native Attachments Stream       |                         |
|                           v                                            v                         |
|   +------------------------------------------------------------------------------------------+   |
|   | Power Apps Canvas Application: Monitor_case_Helpdesk                                     |   |
|   |                                                                                          |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   |   | Screen: Home_incident (4-Tier Auto-Layout Container Hierarchy)                   |   |   |
|   |   |                                                                                  |   |   |
|   |   |   [Tier 1: cmp_AppHeader]  - Navy #012169, Context, User Profile, Sync Status   |   |   |
|   |   |   [Tier 2: cmp_KpiSummaryBar] - 5 Metric Cards (Total, Open, InProg, Resolved, SLA) |   |   |
|   |   |   [Tier 3: cmp_ControlFilterBar] - Status Tabs, System Dropdown, Keyword Search  |   |   |
|   |   |                                                                                  |   |   |
|   |   |   [Tier 4: Workspace Split]                                                      |   |   |
|   |   |   +---------------------------------------+  +-------------------------------+   |   |
|   |   |   | cmp_CaseTableGallery (Dense Grid 44px)|  | cmp_ResolutionSideDrawer(480px)|   |   |
|   |   |   | - Delegable 100% Server Filter        |  | - Visible = varShowDrawer     |   |   |
|   |   |   | - Semantic Status Badges (Pills)      |  | - Resolution Category & Notes |   |   |
|   |   |   | - Zero Emoji                          |  | - Native Attachments Control  |   |   |
|   |   |   +---------------------------------------+  +-------------------------------+   |   |
|   |   +----------------------------------------------------------------------------------+   |   |
|   +------------------------------------------------------------------------------------------+   |
+--------------------------------------------------------------------------------------------------+
```

### Technology Stack
- **Client Frontend**: Microsoft Power Apps Canvas App (Screen resolution: Landscape 16:9 Desktop/Laptop)
- **Data Backend**: Microsoft SharePoint Online Lists
- **Authentication**: Microsoft Entra ID (Azure AD) SSO
- **Build & Packaging**: Microsoft Power Platform CLI (`pac canvas unpack` / `pac canvas pack`)
- **Version Control**: Git Workspace (`Monitor_case_Helpdesk/Src/*.pa.yaml`)

### Key Design Decisions (from D3)
1. **4-Tier Auto-Layout Container Hierarchy (D3-1)**: จัดโครงสร้างหน้าจอเป็น 4 ลำดับชั้นตามแนวนอน ปรับขนาดแบบยืดหยุ่นตามความกว้างหน้าจอ Laptop และแยกพื้นที่ทำงานฝั่งขวาเป็น Collapsible Side Drawer กว้าง 480px เพื่อการปิดเคสที่รวดเร็วโดยไม่ต้องสลับหน้าจอ
2. **Fluent Slate & Deves Corporate Palette (D3-2)**: ใช้โทนสีหลัก Deves Deep Navy (`#012169`) ผสานกับ Neutral Slate `#F1F5F9` และสถานะเป็น Semantic Pills ปราศจาก Emoji 100% ทั่วทั้งระบบ
3. **Direct Boolean Delegable Filter (D3-3)**: ใช้สูตร Power Fx แบบ Boolean ตรงร่วมกับ `StartsWith()` และเรียงลำดับด้วยคอลัมน์ `Created` เดี่ยว เพื่อให้ SharePoint ประมวลผล Server-Side 100% ไร้ Delegation Warning
4. **Native EditForm Attachment Control (D3-4)**: ใช้ DataCard Attachments ใน EditForm ผูกตรงกับ SharePoint List `Cases` เพื่อรองรับการอัปโหลดไฟล์หลักฐานในคราวเดียวกับข้อมูลการปิดงานแบบ Single Transaction
5. **2 New Columns & 5 Indexed Columns (D3-5)**: จัดทำข้อกำหนดคอลัมน์ `ResolutionSummary`, `ResolutionCategory` และ 5 Indexed Columns บน SharePoint List `Cases`
6. **Comprehensive 4-Pillar Verification (D3-6)**: ตรวจสอบความถูกต้องรอบด้านทั้ง Delegation Warning = 0, กฎการตรวจสอบความถูกต้องของฟอร์ม, การจัดวางบน Laptop และความสมบูรณ์ในการ Pack ผ่าน `pac canvas pack`

---

## Open Questions & Risks

| # | Question / Risk | Impact | Status | Mitigation Strategy |
|---|-----------------|--------|--------|---------------------|
| 1 | สิทธิ์การสร้างคอลัมน์และทำ Indexed Columns ใน SharePoint List `Cases` | Medium | Mitigated | จัดทำเอกสารคู่มือสเปกคอลัมน์และขั้นตอนการคลิกตั้งค่าอย่างละเอียดให้ผู้ใช้/SharePoint Admin ดำเนินการ |
| 2 | จำนวนไฟล์แนบขนาดใหญ่ต่อเคส | Low | Mitigated | SharePoint Online รองรับไฟล์แนบสูงสุด 250MB ต่อไฟล์ (กำหนดในระบบให้แนะนำไม่เกิน 25MB) และมีระบบสแกนไวรัสในตัว |
| 3 | หน้าจอเดิม `updateincident` ถูกอ้างอิงจากระบบภายนอกหรือไม่ | Low | Mitigated | ยังคงเก็บหน้าจอ `updateincident` ไว้ในโปรเจกต์โดยปรับแต่งธีมให้เป็น Modern คู่ขนานเพื่อรองรับ Backward Compatibility |

---

## Detailed Specifications

- [Components Specification](file:///e:/DVS/Project/Aiagent_Helpme/.kiro/specs/monitor-case-helpdesk/design/components.md) — รายละเอียดคอนโทรล 5 ชิ้น, โครงสร้างลำดับชั้น และ Data Flow
- [Data Model Specification](file:///e:/DVS/Project/Aiagent_Helpme/.kiro/specs/monitor-case-helpdesk/design/data-model.md) — โครงสร้างคอลัมน์เดิมและคอลัมน์ใหม่ใน SharePoint, ER Diagram และ Indexed Columns
- [Integration Specification](file:///e:/DVS/Project/Aiagent_Helpme/.kiro/specs/monitor-case-helpdesk/design/integration.md) — การเชื่อมต่อ M365, การสื่อสารข้ามยูนิตด้วย Context Variables และความพร้อมสำหรับ Power BI
- [Implementation Specification](file:///e:/DVS/Project/Aiagent_Helpme/.kiro/specs/monitor-case-helpdesk/design/implementation.md) — โครงสร้างไดเรกทอรีซอร์สโค้ด YAML, มาตรฐานการตั้งชื่อ, สูตร Power Fx หลัก และวงจร CLI Pack
- [Non-Functional Requirements](file:///e:/DVS/Project/Aiagent_Helpme/.kiro/specs/monitor-case-helpdesk/design/nfr.md) — การรองรับข้อมูลปริมาณมาก, มาตรฐาน Zero Emoji, SLA ประสิทธิภาพ และความปลอดภัยระดับองค์กร
