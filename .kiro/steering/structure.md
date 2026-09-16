---
inclusion: always
---
# Project Structure

## Repository

- **Type**: Single repo (Copilot Studio agent export + supporting assets)
- **Root**: `e:\DVS\Project\Aiagent_Helpme` — มี agent เดิม, knowledge export, สคริปต์ deploy และ AI-DLC spec artifacts

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `HelpMe Agent/` | Microsoft Copilot Studio agent (source of truth ของ agent) |
| `HelpMe Agent/topics/` | Topics (`AdaptiveDialog`) เช่น Search, OpenCase, Escalate, Fallback |
| `HelpMe Agent/entities/` | Custom entities (`detailincident`, `imageincident`) |
| `HelpMe Agent/knowledge/` | Knowledge source configs (AI_KnowledgeBase_Helpdesk, Manual Systems) |
| `HelpMe Agent/workflows/` | Power Automate flow (NewcaseHelpDesk) — `workflow.json` + `metadata.yml` |
| `HelpMe Agent/.mcs/` | MCS project metadata / connection info |
| `AI_KnowledgeBase_Helpdesk_export/` | ฐานความรู้ export (CSV, 74 รายการ, 19 ฟิลด์) |
| `.kiro/specs/` | AI-DLC spec artifacts |
| `.aidlc/workflow/` | AI-DLC workflow state และ audit |

## Key Files

| File | Purpose |
|------|---------|
| `HelpMe Agent/agent.mcs.yml` | Agent metadata + instructions (system prompt) + model hint |
| `HelpMe Agent/settings.mcs.yml` | Channels, auth, AI settings, recognizer |
| `HelpMe Agent/connectionreferences.mcs.yml` | Connection references (SharePoint, Office 365) |
| `HelpMe Agent/workflows/NewcaseHelpDesk-.../workflow.json` | Logic ของการเปิดเคส + ส่งอีเมล |
| `AI_KnowledgeBase_Helpdesk_export/AI_KnowledgeBase_Helpdesk.csv` | เนื้อหาฐานความรู้ |
| `deploy-helpme-agent.ps1` | Script push + publish ผ่าน pac CLI |

## Entry Points

- **Conversation**: `topics/ConversationStart.mcs.yml`, `topics/Greeting.mcs.yml`
- **Answering**: `topics/Search.mcs.yml` (`OnUnknownIntent`, priority -1) → `SearchAndSummarizeContent`
- **Fallback → case**: `topics/Fallback.mcs.yml` (หลัง 3 ครั้ง → `OpenCase`)
- **Case capture**: `topics/OpenCase.mcs.yml` → `InvokeFlowAction` (flowId `15bbc09f-...`)
- **Human handoff**: `topics/Escalate.mcs.yml` → flow เดียวกัน
- **Flow trigger**: `workflow.json` trigger `manual` (kind `Skills`) รับ `text`..`text_6`
