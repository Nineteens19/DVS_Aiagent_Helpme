# Personas

## Overview
ระบบนี้ให้บริการผู้ใช้ 3 กลุ่มที่มีเป้าหมายและ workflow ต่างกัน: ผู้แจ้งปัญหา (ผู้ใช้ปลายทาง), ทีมเจ้าหน้าที่/Owner (ผู้แก้ไขเคส) และผู้ดูแลฐานความรู้ (ผู้ดูแลคุณภาพเนื้อหา)

---

## Persona 1: ผู้แจ้งปัญหา (Requester / End User)

**Demographics**:
- Role: พนักงาน/ตัวแทนขายที่ใช้ระบบงานภายใน (DSS, Renewal Motor, Polisy 400, PCS, CMI ฯลฯ)
- Technical Proficiency: Novice–Intermediate
- Usage Frequency: เมื่อพบปัญหาหรือมีคำถาม (ไม่สม่ำเสมอ)

**Goals**:
- Primary: ได้คำตอบที่ถูกต้องทันทีเพื่อแก้ปัญหาเอง
- Secondary: ถ้าแก้เองไม่ได้ ต้องการแจ้งเรื่องง่าย ๆ และมั่นใจว่าเรื่องถูกรับแล้ว พร้อมติดตามความคืบหน้าได้

**Pain Points**:
- รอเจ้าหน้าที่นาน ไม่รู้ว่าเรื่องถึงใครหรือคืบหน้าแค่ไหน
- ต้องเล่าปัญหาซ้ำหลายรอบ / ไม่รู้ว่าต้องเตรียมข้อมูลอะไร

**User Journey**:
1. Entry: เปิดแชทใน Teams / M365 Copilot แล้วถามคำถามหรือแจ้งปัญหา
2. Action: รับคำตอบจาก KB หรือให้ข้อมูลเพื่อเปิดเคส
3. Outcome: ได้คำตอบ หรือได้ CaseID + อีเมลยืนยัน และติดตามสถานะได้

**Implications for Requirements**:
- ต้องการภาษาสุภาพ กระชับ เป็นไทย และขั้นตอนถามข้อมูลที่ชัดเจนทีละส่วน
- ต้องได้รับการยืนยัน (แชท + อีเมล) และช่องทางเช็คสถานะด้วย CaseID

---

## Persona 2: ทีมเจ้าหน้าที่ / Owner (Helpdesk Agent / Resolver)

**Demographics**:
- Role: IT Helpdesk, ฝ่ายรับประกันภัยรถยนต์, IT/SA, ฝ่ายบัญชี, IT/Infrastructure
- Technical Proficiency: Intermediate–Expert
- Usage Frequency: รายวัน (รับและจัดการเคส)

**Goals**:
- Primary: รับเคสที่มีข้อมูลครบถ้วน จัดลำดับตาม priority/SLA และแก้ไขได้เร็ว
- Secondary: อัปเดตสถานะให้ผู้แจ้งทราบโดยไม่ต้องเขียนอีเมลเอง

**Pain Points**:
- เคสข้อมูลไม่ครบ ต้องไล่ถามผู้แจ้งเพิ่ม
- ไม่มีระบบเตือนเคสค้าง ทำให้บางเคสตกหล่น

**User Journey**:
1. Entry: รับอีเมลแจ้งเคสใหม่ตามระบบที่รับผิดชอบ
2. Action: เปิดเคสใน SharePoint, อัปเดตสถานะ, บันทึกความคืบหน้า
3. Outcome: เคสถูกแก้ไขและปิด พร้อมแจ้งผู้แจ้งอัตโนมัติ

**Implications for Requirements**:
- เคสต้องมีสรุปปัญหา + KB_ID + System/Category + priority + ประวัติย่อ
- ต้องมี routing ตามระบบ + fallback Helpdesk และการเตือน SLA ตาม Severity

---

## Persona 3: ผู้ดูแลฐานความรู้ / แอดมิน (KB Maintainer / Admin)

**Demographics**:
- Role: BA / Helpdesk Lead ที่ดูแลเนื้อหา `AI_KnowledgeBase_Helpdesk` และกฎการส่งต่อ
- Technical Proficiency: Expert
- Usage Frequency: รายสัปดาห์ (ทบทวน/ปรับปรุงเนื้อหา)

**Goals**:
- Primary: ให้ agent ตอบจากเนื้อหาที่ถูกต้อง อนุมัติแล้ว และเป็นปัจจุบัน
- Secondary: ปิดช่องว่างความรู้จากคำถามที่ตอบไม่ได้

**Pain Points**:
- ไม่รู้ว่าผู้ใช้ถามอะไรที่ KB ยังตอบไม่ได้
- เสี่ยงที่เนื้อหายังไม่อนุมัติถูกนำไปตอบ

**User Journey**:
1. Entry: ทบทวนรายงานคำถามที่ตอบไม่ได้ (gap report)
2. Action: เพิ่ม/แก้รายการ KB ผ่านสถานะ Review → อนุมัติ → Active
3. Outcome: KB ครอบคลุมขึ้น และ agent ใช้เฉพาะรายการที่อนุมัติ

**Implications for Requirements**:
- ต้องมี gap report และ workflow ควบคุมสถานะ `Review_Status` / `Is_Active`
- agent ต้องบังคับใช้ guardrail: ไม่ตอบจากรายการที่ยังไม่อนุมัติ/ไม่ Active

---

## Persona-Requirement Matrix

| Requirement | ผู้แจ้งปัญหา | เจ้าหน้าที่/Owner | ผู้ดูแล KB | Priority |
|-------------|:----:|:----:|:----:|----------|
| US-001 ตอบจาก KB | Primary | N/A | Secondary | High |
| US-002 รวบรวมข้อมูลที่จำเป็น | Primary | Secondary | N/A | High |
| US-003 จัดการหลายรายการใกล้เคียง | Primary | N/A | Secondary | Medium |
| US-004 Guardrails | Primary | N/A | Primary | High |
| US-005 เปิดเคส | Primary | Secondary | N/A | High |
| US-006 บันทึกบริบทลงเคส | Secondary | Primary | N/A | High |
| US-007 Routing ผู้รับผิดชอบ | N/A | Primary | N/A | High |
| US-008 CaseID + แจ้งทีม | Secondary | Primary | N/A | High |
| US-009 แยกประเภทเคส | N/A | Primary | N/A | Medium |
| US-010 Acknowledgment ผู้แจ้ง | Primary | N/A | N/A | High |
| US-011 แจ้งเปลี่ยนสถานะ | Primary | Secondary | N/A | Medium |
| US-012 เช็คสถานะผ่าน agent | Primary | N/A | N/A | Medium |
| US-013 SLA reminder | N/A | Primary | N/A | Low |
| US-014 Gap report | N/A | Secondary | Primary | Low |
| US-015 จัดการเนื้อหา KB | N/A | N/A | Primary | Low |

**Legend**: Primary (core), Secondary (nice-to-have), N/A (not relevant)

---

## Design Implications

**Architecture**: ต้องรองรับ role-based flow — ผู้แจ้ง (แชท), เจ้าหน้าที่ (SharePoint + email), ผู้ดูแล KB (governance). Case ต้องผูกกับ Reporter identity เพื่อความเป็นส่วนตัวเวลาเช็คสถานะ
**UI/UX**: ผู้แจ้งเป็น novice → ต้องมี guided questions, ปุ่มตัวเลือก (ClosedListEntity), ข้อความยืนยันชัดเจน
**Data & Privacy**: เก็บข้อมูลติดต่อผู้แจ้ง (ชื่อ/อีเมล/เบอร์) ต้องเป็นไปตาม PDPA; ห้ามเก็บ Password/OTP; ผู้ใช้เห็นได้เฉพาะเคสของตนเอง
