# Design Specification: Integration Architecture

## Overview
สถาปัตยกรรมการเชื่อมต่อ (Integration Architecture) ของระบบ **Helpdesk Knowledge Base & Suggestion Management** เชื่อมโยงระหว่าง Microsoft Copilot Studio, SharePoint Online (Microsoft Graph Indexer), และ Power Platform CLI (`pac`)

---

## 1. Copilot Studio Knowledge Source Integrations

### 1.1 `ManualSystems` Integration
- **Source Type**: SharePoint Document Library
- **Configuration File**: `HelpMe Agent/knowledge/cr616_helpMeAgentUat.topic.ManualSystems_9SrlC8K2q_jCPnpBMmCOn.mcs.yml`
- **Target Site**: `https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals`
- **Protocol**: Microsoft Graph Semantic Indexing & Enterprise Search Connector
- **Sync Method**: Periodic background crawl (อัตโนมัติ 15-60 นาที)
- **Data Extracted**: ชื่อไฟล์, หัวเรื่อง, Metadata, และเนื้อหาภายในไฟล์ PDF/DOCX ทั้งฉบับ

### 1.2 `AI_KnowledgeBase_SPList` Integration
- **Source Type**: SharePoint List
- **Configuration File**: `HelpMe Agent/knowledge/cr616_helpMeAgentUat.topic.AI_KnowledgeBase_SPList.mcs.yml`
- **Target Site**: `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/AI_KnowledgeBase`
- **Protocol**: SharePoint REST / Graph API via Native Copilot Studio Connector
- **Data Extracted**: ฟิลด์ `Title`, `Question`, `Answer`, `System`, `Category`, `Keywords`, `Status`
- **Filtering Logic**: เฉพาะรายการที่มีสถานะ `Active`

---

## 2. Power Platform CLI & Deployment Pipelines

### 2.1 Configuration Synchronization (`pac copilot push`)
- **CLI Executable**: Power Platform CLI (`pac.exe`)
- **Action**: ดันการเปลี่ยนแปลงไฟล์ YAML ในโปรเจกต์ `HelpMe Agent` ขึ้นสภาพแวดล้อม Dataverse
- **Command**:
  ```powershell
  & "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe" copilot push --project-dir "HelpMe Agent"
  ```

### 2.2 Deployment & Release Pipeline (`pac copilot publish`)
- **Bot ID**: `76812e27-6dce-f011-8544-6045bd592e11`
- **Action**: เผยแพร่ Agent เวอร์ชั่นล่าสุดไปยังทุกแชนแนล (Microsoft Teams, Web Chat, Mobile)
- **Command**:
  ```powershell
  & "$env:USERPROFILE\pac-cli\extracted\tools\pac.exe" copilot publish --bot 76812e27-6dce-f011-8544-6045bd592e11
  ```

---

## 3. Security & Channel Integration

### 3.1 Authentication & Graph Tokens
- ผู้ใช้งานเข้าสู่ระบบผ่าน Azure Active Directory (Azure AD / Entra ID) Single Sign-On (SSO)
- Copilot Studio ใช้สิทธิ์ Delegated Permissions ของผู้ใช้ในการสืบค้น SharePoint Knowledge Sources เพื่อให้มั่นใจว่าผู้ใช้เห็นเฉพาะข้อมูลที่ตนมีสิทธิ์เข้าถึง (Security Trimming)

### 3.2 Channel Rendering Matrix
| Channel | Inline Follow-up Bullets | Document Citations | Quick Reply Options |
|---------|--------------------------|--------------------|---------------------|
| **Microsoft Teams** | Full Markdown Support | Clickable SharePoint Link | Interactive Buttons |
| **Power Apps Embedded Web Chat** | Full Markdown Support | Modal / New Tab Link | Card Action Buttons |
| **Mobile Web Browser** | Full Markdown Support | Web Viewer Link | Touch Pills |
