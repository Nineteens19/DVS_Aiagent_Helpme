# Design Document: Helpdesk Knowledge Base & Suggestion Management

## Summary
<!-- 10-line max digest for downstream phases. Later phases can read ONLY this section. -->
- **Architecture**: 2-Tier Layered Architecture (Storage & Governance Layer + Conversational AI UX Layer)
- **Stack**: Microsoft Copilot Studio (GPT Generative AI) / SharePoint Online (Document Library & List) / Power Platform CLI (`pac`)
- **Components**: `SystemManuals` (Doc Library), `AI_KnowledgeBase` (List 74 Q&A), `HelpMeAgentRAG` (Engine), `ConversationalMenuUX` (Topic v4K), `PromptFollowUpEngine`
- **Entities**: `ManualDocument`, `QnAEntry`, `MasterSystems` (31 systems reference)
- **Integrations**: SharePoint Graph Search Indexer, Microsoft Teams Channel, Power Platform CLI Deployment
- **Testing**: Golden Q&A Benchmark (15-20 test cases + negative edge-cases) — NFR [Yes]
- **Key Decisions**: D3-1 Strict Grounding & Zero Hallucination, D3-2 Static Top Systems with 0s latency & AI Disambiguation, D3-3 Inline Markdown Follow-up Prompts

---

## Architecture

### System Context Diagram
```
+-----------------------------------------------------------------------------------------+
|                                    User Interaction                                     |
|               (Microsoft Teams / Power Apps Embedded Chat / Mobile Web)                 |
+-----------------------------------------------------------------------------------------+
                                           |
                                           | User Queries / Quick System Choices
                                           v
+-----------------------------------------------------------------------------------------+
|                        Copilot Studio: HelpMe Agent (Live UAT)                          |
|                                                                                         |
|  +--------------------------------+       +------------------------------------------+  |
|  | Topic v4K: System Selection    |       | System Prompt & Guardrails               |  |
|  | - Top 4 Quick Replies (0s lag) |       | - Strict Grounding (D3-1)                |  |
|  | - AI Free-text Disambiguation  |       | - 2 Follow-up Question Prompts (D3-3)   |  |
|  +--------------------------------+       +------------------------------------------+  |
|                                  \         /                                            |
|                                   v       v                                             |
|                   +-----------------------------------------------+                     |
|                   | Azure OpenAI RAG & Semantic Retrieval Engine  |                     |
|                   +-----------------------------------------------+                     |
+-----------------------------------------------------------------------------------------+
                                           |
                                           | Enterprise Search & Security Trimming
                                           v
+-----------------------------------------------------------------------------------------+
|                SharePoint Online Site: https://dvsins.sharepoint.com/sites/PowerAppPRD  |
|                                                                                         |
|  +-------------------------------------+     +---------------------------------------+  |
|  | Library: SystemManuals              |     | List: AI_KnowledgeBase (74 Q&A items) |  |
|  | - Full PDF/Word Manuals             |     | - System, Category, Keywords          |  |
|  | - SystemName (Plain Text)           |     | - System (Plain Text)                 |  |
|  | - Status: Approved                  |     | - Status: Active                      |  |
|  +-------------------------------------+     +---------------------------------------+  |
|                                    \             /                                      |
|                                     v           v                                       |
|                  +---------------------------------------------------+                  |
|                  | Master List: Systems (31 Reference Standard Names)|                  |
|                  +---------------------------------------------------+                  |
+-----------------------------------------------------------------------------------------+
```

### Technology Stack
- **AI Agent Platform**: Microsoft Copilot Studio (Solution: `cr616_helpMeAgentUat`, Bot ID: `76812e27-6dce-f011-8544-6045bd592e11`)
- **Knowledge Storage**: SharePoint Online (`PowerAppPRD` site)
- **Search & Retrieval**: Microsoft Graph Semantic Search Indexer + Azure OpenAI Embeddings
- **Deployment Tooling**: Power Platform CLI (`pac.exe` v1.45+)
- **Data Preparation**: PowerShell 5.1 / 7 (UTF-8 with BOM CSV processing)

### Key Design Decisions
1. **Strict Grounding & Zero Hallucination (D3-1)**: กำหนด System Instructions ให้ตอบเฉพาะข้อมูลที่มีหลักฐานในคู่มือหรือ Q&A เท่านั้น หากไม่พบ ให้ตอบปฏิเสธสุภาพและแนะนำการส่งต่อ IT Helpdesk ทันที
2. **High-Speed Hybrid System Menu (D3-2)**: แสดงตัวเลือก Quick Reply 4 ระบบหลักเพื่อการตอบสนองทันที 0 วินาที พร้อมตรรกะ AI Disambiguation สำหรับการพิมพ์ชื่อระบบเอง
3. **Inline Follow-up Question Prompts (D3-3)**: แสดงคำถามที่เกี่ยวข้อง 2 ข้อท้ายคำตอบในรูปแบบ Markdown Bullets รองรับทุกแชนแนล (Teams, Mobile, Web)

---

## Open Questions & Risks

| # | Question/Risk | Impact | Status | Mitigation |
|---|--------------|--------|--------|------------|
| 1 | SharePoint Search Indexing Delay (15-60 min) | Medium | Mitigated | มีคู่มือ Force Sync สำหรับ Admin ใน Copilot Studio Portal |
| 2 | พนักงานพิมพ์ชื่อระบบผิดหรือใช้ชื่อย่อ | Low | Mitigated | ใส่ชื่อระบบและคำพ้องความหมายใน System Prompt Instructions |
| 3 | การจำกัดสิทธิ์ของไฟล์เอกสาร | Medium | Mitigated | กำหนดสิทธิ์ระดับ SharePoint ให้ผู้ใช้ทั่วไปเป็น Read-only |

---

## Detailed Specifications

- [Components](design/components.md) — รายละเอียดโครงสร้างคอมโพเนนต์ทั้ง 2 เลเยอร์และอินเทอร์เฟซ
- [Data Model](design/data-model.md) — โครงสร้าง Library `SystemManuals`, List `AI_KnowledgeBase` และ Master `Systems`
- [Integration](design/integration.md) — การเชื่อมต่อ Copilot Studio, SharePoint Indexer และ Power Platform CLI
- [Implementation](design/implementation.md) — โครงสร้างไฟล์ในโปรเจกต์, คู่มือ SOP สำหรับแอดมิน, และชุดทดสอบ Golden Q&A
- [Non-Functional Requirements](design/nfr.md) — มาตรฐานด้านความเร็ว (Latency), ความแม่นยำ (Accuracy) และความปลอดภัย (Security)
