---
inclusion: always
---
# Technology Context

## Stack

- **Client / Frontend**: Microsoft Power Apps (Canvas App) — YAML layout schema (`.pa.yaml`), Power Fx formula language
- **AI Agent**: Microsoft Copilot Studio (template `default-2.1.0`), Adaptive Dialog YAML (`.mcs.yml`)
- **Backend / Integration**: Power Automate Cloud Flows (Logic Apps schema `2016-06-01`)
- **CLI & Packaging**: Microsoft Power Platform CLI (`pac`) — `pac canvas download/unpack/pack`, `pac copilot push/publish`
- **Languages**: Power Fx, YAML, JSON, PowerShell
- **Testing**: Power Apps Studio Test Player, Playwright for Power Apps / Manual Testing

## Architecture

- **Pattern**: Low-Code Multi-Tier Enterprise Architecture:
  - Presentation Layer: Power Apps Canvas App (`Monitor_case_Helpdesk`)
  - Conversational Layer: Copilot Studio Agent (`HelpMe Agent`)
  - Integration Layer: Power Automate Cloud Flows (Notification, Status Change, Auto Close)
  - Data Persistence Layer: SharePoint Online Lists (OData V3 Connector)
- **API Style**: SharePoint Connector (Delegable OData queries via Power Fx), OpenApiConnection

## Infrastructure

- **Cloud Provider**: Microsoft 365 / Microsoft Power Platform (SaaS)
- **Environment**: Deves Insurance (default) (`https://devesinsurancedefault.crm5.dynamics.com/`)
- **Database / Lists**:
  - `Cases` (`b8b22b0d-45c6-43c9-bc66-06e5e45b1237`) at `https://dvsins.sharepoint.com/sites/PowerAppPRD`
  - `Routing` (`3d5264cb-65f6-4db5-8afa-fa68a6ea61e1`)
  - `SLAConfig` (`9c7bb698-4841-447e-aae4-5a43466771af`)
  - `KnowledgeGaps` (`9beb45a0-08e2-4717-8eee-5b80bd218005`)
  - `ErrorLog` (`f6822ed6-ef24-4129-a56a-832d71c8312e`)

## Conventions

- **UI Standards**: Modern Enterprise Theme (Fluent Design System, Professional Blue/Gray palette, Strictly No Emojis in labels/buttons)
- **Delegation Rules**: All SharePoint list queries must strictly adhere to Power Apps Delegation rules (avoiding `in` operator on large sets, indexing columns in SharePoint, using `Filter`, `SortByColumns`, and `StartsWith`)
- **Attachment Standards**: Case resolution evidence stored via SharePoint native item attachment mechanism or documented document library with file validation (size, type)
- **Screen Resolution**: Optimized for 16:9 Desktop/Laptop viewports (1366x768 to 1920x1080)
