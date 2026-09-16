---
inclusion: always
---
# Technology Context

## Stack

- **Languages**: YAML (MCS component definitions), JSON (Power Automate/Logic Apps), Power Fx (expression bindings), PowerShell (deploy)
- **Frameworks**: Microsoft Copilot Studio (template `default-2.1.0`), Power Automate Cloud Flow (Logic Apps schema `2016-06-01`)
- **Build System**: Power Platform CLI — `pac copilot push`, `pac copilot publish`
- **Package Manager**: N/A (low-code platform)
- **Testing**: N/A — ยังไม่มี automated test; ทดสอบผ่าน Copilot Studio Test pane และช่องทางจริง (Teams / M365 Copilot)

## Architecture

- **Pattern**: Conversational agent (topic-based `AdaptiveDialog`) + Generative answering (`SearchAndSummarizeContent`, `GenerativeAIRecognizer`) + Serverless orchestration flow (Power Automate) สำหรับ side-effects (เปิดเคส/ส่งอีเมล)
- **API Style**: Skills-triggered flow (`Request` trigger kind `Skills`) เรียกจาก topic ผ่าน `InvokeFlowAction`; connectors ใช้ OpenApiConnection

## Infrastructure

- **Cloud Provider**: Microsoft 365 / Power Platform (SaaS)
- **Compute**: Copilot Studio runtime + Power Automate (managed)
- **Database**: SharePoint Online lists (site `https://dvsins.sharepoint.com/sites/PowerAppPRD`) — case lists + owner/routing list; KB = `AI_KnowledgeBase_Helpdesk` (structured search) + Manual Systems (document search)
- **IaC Tool**: ไม่มี IaC โดยตรง — จัดการผ่าน pac CLI + connection references; environment = `devesinsurancedefault` (crm5.dynamics.com)

## Conventions

- **Code Style**: MCS components เป็นไฟล์ `*.mcs.yml` แยกตามชนิด (agent/topics/entities/knowledge/workflows); flow เป็น `workflow.json` + `metadata.yml`
- **Naming**: schema prefix `cr616_helpMeAgentUat`; `CaseID` รูปแบบ `Case-UserSystem-{yyyyMMdd}-{ID}`; ภาษา UI/เนื้อหา = ไทย (locale 1054)
- **Testing Pattern**: Manual test ผ่าน Test pane; ยังไม่มี unit/integration test
- **Branch Strategy**: ยังไม่ระบุ (ไฟล์ export อยู่ใน workspace); deploy ผ่านสคริปต์ `deploy-helpme-agent.ps1`

## Guardrails & Security (existing)

- ตอบเฉพาะ `Approved_Answer`; ห้ามเดาสาเหตุ/วิธีแก้/ผู้รับผิดชอบ
- ห้ามใช้รายการที่ `Review_Status = Review Required` หรือ `Is_Active ≠ Active`
- ห้ามขอ/บันทึก Password, OTP หรือข้อมูลลับ
- แสดง `KB_ID` ท้ายคำตอบเมื่ออ้างจากฐานความรู้
- `contentModeration: High`; auth = Integrated (Entra ID), `authenticationTrigger: Always`
