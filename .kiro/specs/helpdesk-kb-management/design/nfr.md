# Design Specification: Non-Functional Requirements (NFR)

## Overview
ข้อกำหนดด้านคุณภาพและประสิทธิภาพ (Non-Functional Requirements) สำหรับระบบ **Helpdesk Knowledge Base & Suggestion Management**

---

## 1. Performance & Latency Targets

| Metric | Target | Design Mechanism |
|--------|--------|------------------|
| **In-Dialog System Choice Latency** | < 0.2 วินาที | ออกแบบเป็น Static Quick Replies Top 4 Systems (Topic `v4K`) โดยไม่เรียก Power Automate Flow ในระหว่างการเลือก |
| **Generative AI Answer Latency** | < 3.0 วินาที | Azure OpenAI Semantic Retrieval ที่เชื่อมต่อโดยตรงกับ SharePoint Index |
| **Index Synchronization Window** | 15 - 60 นาที | Background Synchronization ของ Microsoft Graph Indexer พร้อมรองรับ Manual Sync ผ่าน Copilot Studio Portal |

---

## 2. Accuracy & Grounding (ความถูกต้องและการป้องกันความผิดพลาด)

| Metric | Target | Enforcement Rule |
|--------|--------|------------------|
| **Hallucination Rate** | 0.0% (Zero Hallucination) | บังคับใช้ Strict Grounding ใน System Instructions ห้ามคาดเดาหรือแต่งคำตอบนอกเหนือจากคู่มือและ Q&A ที่กำหนด |
| **Citation Attribution** | 100% | คำตอบที่ดึงมาจากคู่มือหรือข้อคำถามจะต้องแสดงลิงก์และแหล่งที่มา (Citation) เสมอ |
| **Follow-up Suggestions Consistency** | 100% | มีการเสนอคำถามเกี่ยวเนื่อง 2 ข้อที่ท้ายคำตอบเสมอ เพื่อเพิ่มความต่อเนื่องในการใช้งาน |

---

## 3. Security & Governance (ความมั่นคงปลอดภัยและการกำกับดูแล)

| Area | Requirement | Implementation |
|------|-------------|----------------|
| **Authentication** | M365 Entra ID SSO | ผู้ใช้งานต้องผ่านการพิสูจน์ตัวตนด้วยบัญชีองค์กร |
| **Access Control (RBAC)** | Role-based Authorization | พนักงานทั่วไปได้รับสิทธิ์แบบ Read-only ในคลังความรู้ ป้องกันการแก้ไขหรือลบโดยไม่ได้รับอนุญาต |
| **Data Isolation** | Tenant Bound | ข้อมูลทั้งหมดอยู่ภายใต้ Microsoft 365 Tenant ของ Deves Insurance ไม่รั่วไหลออกสู่สาธารณะ |
| **Lifecycle Filter** | Status Guard | กรองเฉพาะเอกสารสถานะ `Approved` และข้อคำถามสถานะ `Active` เท่านั้น เพื่อป้องกันการนำข้อมูลร่างหรือข้อมูลยกเลิกไปตอบ |

---

## 4. Availability & Reliability

- **Service Availability**: ยึดตาม SLA ของ Microsoft 365 & Copilot Studio Cloud (99.9% Uptime)
- **Degradation Fallback**: หากค้นหาข้อมูลในคลังความรู้ไม่พบหรือเกิดความขัดข้องของบริการค้นหา Agent จะเข้าสู่โหมด Fallback อัตโนมัติ โดยแนะนำช่องทางการเปิดเคส HelpDesk หรือติดต่อเจ้าหน้าที่ทันที
