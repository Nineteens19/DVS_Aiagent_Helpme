---
inclusion: always
---
# Project Structure

## Repository

- **Type**: Single repository combining Copilot Studio Agent + Power Apps Canvas App source + deployment scripts
- **Root**: `e:\DVS\Project\Aiagent_Helpme`

## Key Directories

| Directory | Purpose |
|---|---|
| `Monitor_case_Helpdesk/` | Source code ของ Power Apps Canvas App สำหรับทีมมอนิเตอร์เคส |
| `Monitor_case_Helpdesk/Src/` | Screen YAMLs (`App.pa.yaml`, `Home_incident.pa.yaml`, `updateincident.pa.yaml`) |
| `Monitor_case_Helpdesk/References/` | DataSources.json, Themes, Templates |
| `HelpMe Agent/` | Microsoft Copilot Studio agent source (topics, entities, knowledge, workflows) |
| `scripts/` | สคริปต์ PowerShell สำหรับ deploy, provisioning และคู่มือ SharePoint |
| `.kiro/specs/monitor-case-helpdesk/` | AI-DLC spec artifacts สำหรับฟีเจอร์ปรับปรุง Monitor_case_Helpdesk |
| `.aidlc/workflow/monitor-case-helpdesk/` | AI-DLC workflow state และ audit log |

## Key Files

| File | Purpose |
|---|---|
| `Monitor_case_Helpdesk.msapp` | Binary package ของ Canvas App สำหรับนำเข้า/เปิดใน Power Apps Studio |
| `Monitor_case_Helpdesk/Src/Home_incident.pa.yaml` | หน้าจอหลัก Incident Dashboard & Case Filtering |
| `Monitor_case_Helpdesk/Src/updateincident.pa.yaml` | หน้าจอดูรายละเอียด อัปเดตสถานะ และแนบหลักฐานปิดเคส |
| `Monitor_case_Helpdesk/References/DataSources.json` | นิยามการเชื่อมต่อ SharePoint list `Cases`, `Routing`, `SLAConfig` |
| `deploy-helpme-agent.ps1` | สคริปต์ deploy Copilot Studio agent ผ่าน pac CLI |
| `HELPME-AGENT-README.md` | สรุปภาพรวมสถาปัตยกรรมและตาราง GUIDs ทั้งหมด |

## Entry Points

- **Canvas App Launch**: `Monitor_case_Helpdesk/Src/App.pa.yaml` (`OnStart` → `Navigate(Home_incident)`)
- **Dashboard & Search**: `Home_incident` (KPI counters, filter group, case gallery)
- **Case Edit & Close**: `updateincident` (Item detail, status changer, attachment picker)
