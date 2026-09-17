# Personas: helpdesk-kb-management

## Overview
ฟีเจอร์การจัดการฐานความรู้ (Knowledge Base Management) และระบบแนะนำคำตอบ (Suggestion Menus) นี้ให้บริการผู้ใช้งาน 2 กลุ่มหลักที่มีบทบาท ความต้องการ และขั้นตอนการทำงานที่แตกต่างกันอย่างชัดเจน

---

## Persona 1: สมชาย (IT Helpdesk & KB Admin)

**Demographics**:
- Role: IT Helpdesk Specialist / Knowledge Base Administrator
- Technical Proficiency: Intermediate ถึง Expert (คุ้นเคยกับ Microsoft 365, SharePoint, Power Platform)
- Usage Frequency: Daily

**Goals**:
- Primary: บริหารจัดการฐานความรู้ของระบบงานไอที ทั้งเอกสารคู่มือ (System Manuals) และชุดข้อคำถาม-คำตอบ (Q&A Articles) ได้สะดวกและรวมศูนย์อยู่ที่เดียว
- Secondary: ตรวจสอบช่องว่างความรู้ (Knowledge Gaps) จากเคสที่ไม่สามารถตอบได้อัตโนมัติ และแปลงเป็นบทความองค์ความรู้ใหม่ผ่านกระบวนการอนุมัติ (Approval Lifecycle) ได้อย่างรวดเร็ว

**Pain Points**:
- เดิมเอกสารคู่มือและตาราง Q&A ฝากอยู่ที่ไซต์ของทีมอื่น (`BusinessAnalystandHelpdesk`) ขาดสิทธิ์ในการบริหารจัดการ และเสี่ยงต่อการที่เจ้าของไซต์ย้ายโฟลเดอร์จนทำให้ AI Search Error
- การเพิ่มข้อคำถาม-คำตอบใหม่ทำได้ช้า หากไม่มีเครื่องมือแบบ Grid Edit หรือกระบวนการอนุมัติ (Approval Status) ที่ชัดเจน อาจทำให้ข้อมูลที่ยังไม่ยืนยันหลุดไปตอบผู้ใช้

**User Journey**:
1. Entry: เข้าสู่ SharePoint Site `PowerAppPRD` ไปยัง Library `SystemManuals` หรือ List `AI_KnowledgeBase`
2. Action: ลากวางอัปโหลดคู่มือเวอร์ชันใหม่ หรือเปิด Edit in grid view เพื่อเพิ่ม/ปรับปรุงแนวทางแก้ไข พร้อมตั้งสถานะเป็น Approved
3. Outcome: HelpMe Agent สามารถดึงคำตอบที่ถูกต้องและเอกสารล่าสุดไปค้นหาตอบพนักงานได้ทันที

**Implications for Requirements**:
- ต้องการโครงสร้าง Folder แยกตามระบบ พร้อมคอลัมน์ Metadata ที่ชัดเจนใน Document Library
- ต้องการฟิลด์ `Review_Status` และ `Is_Active` ใน Q&A List เพื่อควบคุมความถูกต้อง
- ต้องการสิทธิ์แบบ Edit/Contribute ให้กับทีมงาน Helpdesk

---

## Persona 2: นารี (General End-User / พนักงานและตัวแทน)

**Demographics**:
- Role: พนักงานฝ่ายปฏิบัติการ / งานรับประกันภัย / ตัวแทน (Operations / Agent Staff)
- Technical Proficiency: Novice ถึง Intermediate
- Usage Frequency: Weekly หรือเมื่อพบปัญหาการใช้งานระบบ

**Goals**:
- Primary: ได้รับคำตอบและแนวทางแก้ไขปัญหาการใช้งานระบบ (เช่น DSS, Renewal Motor, PCS, Polisy 400) อย่างถูกต้องและรวดเร็วโดยไม่ต้องรอคิวสายด่วนไอที
- Secondary: มีเมนูตัวเลือกหรือปุ่มคำถามแนะนำ (Conversation Starters / Suggestions) ช่วยนำทาง ไม่ต้องนึกคำถามหรือพิมพ์ศัพท์เทคนิคเองทั้งหมด

**Pain Points**:
- เมื่อเปิดหน้าแชทขึ้นมาแล้วเจอกล่องข้อความว่างเปล่า ไม่แน่ใจว่าจะต้องเริ่มพิมพ์อย่างไร หรือระบบรองรับเรื่องอะไรบ้าง
- เมื่อ AI ตอบคำถามเสร็จ บางครั้งต้องการทราบขั้นตอนถัดไปหรือคำถามที่เกี่ยวข้อง แต่ไม่รู้จะถามต่ออย่างไร

**User Journey**:
1. Entry: เปิดหน้าต่างสนทนากับ HelpMe Agent ผ่าน Microsoft Teams หรือเว็บแอปพลิเคชัน
2. Action: คลิกปุ่ม Conversation Starters (เช่น "แจ้งปัญหา DSS เข้าไม่ได้") หรือคลิกปุ่มตัวเลือกระบบในเมนูหลัก
3. Outcome: ได้รับคำตอบที่กระชับ แม่นยำ อ้างอิงจากคู่มือที่ถูกต้อง พร้อมคำถามแนะนำที่เกี่ยวข้อง 2 ข้อให้คลิกหรือสอบถามต่อเนื่องได้ทันที

**Implications for Requirements**:
- ต้องการ Conversation Starters บนหน้าแรกของ Agent
- ต้องการปุ่มตัวเลือกระบบใน Topic สนทนา (In-Dialog Quick Replies)
- ต้องการให้ AI เสนอคำถามแนะนำต่อยอด (Follow-up Suggestions) ท้ายคำตอบเสมอ

---

## Persona-Requirement Matrix

| Requirement | สมชาย (IT Helpdesk) | นารี (End-User) | Priority |
|-------------|---------------------|-----------------|----------|
| US-KB-001: Manuals Document Library Management | Primary | Secondary | High |
| US-KB-002: Q&A Knowledge Articles Management | Primary | Secondary | High |
| US-KB-003: Knowledge Retrieval & Governance Guardrails | Secondary | Primary | High |
| US-KB-004: Conversation Starters (Prompt Starters) | Secondary | Primary | High |
| US-KB-005: In-Dialog System Selection Suggestions | Secondary | Primary | Medium |
| US-KB-006: AI Generative Follow-up Recommendations | Secondary | Primary | Medium |

**Legend**: Primary (ผู้ใช้งานหลัก / ผู้ได้รับผลกระทบโดยตรง), Secondary (ผู้ใช้งานทางอ้อม)

---

## Design Implications

**Architecture**: รวมศูนย์ฐานข้อมูลความรู้ทั้งหมดบน SharePoint Site `PowerAppPRD` ภายใต้บทบาทความปลอดภัยแยกตาม Role-Based Access Control (RBAC)  
**UI/UX**: ฝั่ง Admin ใช้ SharePoint Modern Grid & Drag-Drop; ฝั่ง End-User ใช้ Conversational Suggestion Chips, Quick Reply Buttons และ AI Follow-up Prompts  
**Data & Security**: พนักงานทุกคนมีสิทธิ์ Read เท่านั้นเพื่อป้องกันการดัดแปลงแก้ไขข้อมูลต้นฉบับ แต่ Agent สามารถค้นหาเนื้อหาแทนพนักงานทุกคนได้อย่างไร้รอยต่อ
