# Requirements

## Summary
<!-- 10-line max digest for downstream agents. Later phases can read ONLY this section. -->
- **Total Stories**: 15 across 4 functional areas
- **Priority**: 8 High, 4 Medium, 3 Low
- **User Types**: ผู้แจ้งปัญหา (Requester), ทีมเจ้าหน้าที่/Owner (Resolver), ผู้ดูแล KB (Admin)
- **Key Entities**: KnowledgeItem (KB), Case, CaseStatus, RoutingRule/Owner, Reporter/Contact, Notification, GapReport
- **Integrations**: SharePoint Online (case + KB + routing), Office 365 Outlook (email), Power Automate (orchestration), Copilot Studio (agent); SysAid ถูกอ้างถึงใน Approved_Answer (ยังไม่ integrate ตรง)
- **Core Flows**: (1) ตอบจาก KB, (2) เปิดเคส + acknowledgment, (3) ติดตามสถานะ (follow-up), (4) เช็คสถานะด้วยตนเอง, (5) ดูแล/เติม KB

## Overview
User stories จัดกลุ่มตาม functional area พร้อม acceptance criteria แบบ EARS (keyword WHEN/IF/THEN/ELSE/WHILE/WHERE เป็นภาษาอังกฤษ, เนื้อหาเป็นไทย)

---

## Functional Area 1: Knowledge Answering (การตอบจากฐานความรู้)

### US-001: ค้นและตอบจากฐานความรู้ที่ยืนยันแล้ว
**As a** ผู้แจ้งปัญหา
**I want** ถามคำถามแล้วได้คำตอบที่ถูกต้องจากฐานความรู้
**So that** แก้ปัญหาได้เองทันทีโดยไม่ต้องรอเจ้าหน้าที่

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้ส่งคำถามที่ตรงกับรายการ KB ที่ `Is_Active = "Active"` และผ่านเกณฑ์ `Review_Status`, **THEN** ระบบตอบด้วยข้อความจาก `Approved_Answer` เท่านั้น
2. **WHEN** ระบบตอบจากรายการ KB, **THEN** แสดง `KB_ID` ที่ใช้อ้างอิงท้ายคำตอบ
3. **IF** ไม่พบรายการ KB ที่ตรงและยืนยันได้, **THEN** แจ้งว่าไม่พบข้อมูลที่ยืนยันได้และเสนอเปิดเคส, **ELSE** ตอบจาก `Approved_Answer`
4. The system shall ไม่สร้างหรือเดาสาเหตุ วิธีแก้ไข หรือผู้รับผิดชอบที่ไม่มีอยู่ใน KB

**Dependencies**: None

---

### US-002: รวบรวมข้อมูลที่จำเป็นก่อนสรุป
**As a** ผู้แจ้งปัญหา
**I want** ให้ระบบถามข้อมูลที่จำเป็นจนครบก่อนสรุป
**So that** คำตอบหรือเคสมีข้อมูลเพียงพอที่จะดำเนินการต่อ

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** รายการ KB ที่ตรงมี `Required_Information` ที่ยังไม่ครบ, **THEN** ระบบถามเพิ่มตาม `Followup_Question` ทีละส่วนจนครบ
2. **WHILE** ข้อมูลที่จำเป็นยังไม่ครบ, **IF** ผู้ใช้ขอให้ดำเนินการต่อ, **THEN** ระบบยังไม่เปิดเคสและถามข้อมูลที่ขาด
3. **WHEN** ข้อมูลครบตาม `Required_Information`, **THEN** ระบบสรุปข้อมูลและไปขั้นถัดไป (ตอบ หรือเปิดเคส)

**Dependencies**: US-001

---

### US-003: จัดการหลายรายการที่ใกล้เคียงกัน (Disambiguation)
**As a** ผู้แจ้งปัญหา
**I want** ให้ระบบช่วยแยกแยะเมื่อคำถามตรงกับหลายเรื่อง
**So that** ได้คำตอบที่ตรงกับระบบ/อาการของฉันจริง ๆ

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** คำถามตรงกับหลายรายการ KB ที่ต่าง `System` หรืออาการ, **THEN** ระบบถามให้ผู้ใช้ระบุ System/อาการก่อน และไม่รวมคำตอบเข้าด้วยกัน
2. **IF** ผู้ใช้เลือก System/อาการแล้ว, **THEN** ระบบตอบจากรายการที่ตรงที่สุดเพียงรายการเดียว

**Dependencies**: US-001

---

### US-004: Guardrails ด้านความปลอดภัยและคุณภาพคำตอบ
**As a** ผู้ดูแล KB
**I want** ให้ agent ตอบอย่างปลอดภัยและอยู่ในกรอบเนื้อหาที่อนุมัติ
**So that** ลดความเสี่ยงข้อมูลผิดและการรั่วไหลของข้อมูลลับ

**Priority**: High

**Acceptance Criteria**:
1. The system shall ไม่ใช้รายการที่ `Review_Status = "Review Required"` หรือ `Is_Active ≠ "Active"` มาตอบ
2. **IF** ผู้ใช้พยายามให้ หรือระบบกำลังจะถาม Password/OTP/ข้อมูลลับ, **THEN** ระบบปฏิเสธการเก็บและเตือนผู้ใช้ไม่ให้ส่งข้อมูลลับ
3. **WHERE** `contentModeration = High`, **WHEN** เนื้อหาเข้าข่ายไม่เหมาะสม, **THEN** ระบบปฏิเสธอย่างสุภาพ
4. The system shall ตอบเป็นภาษาไทยสุภาพ กระชับ ชัดเจน

**Dependencies**: US-001, US-015

---

## Functional Area 2: Case Capture & Routing (การเปิดเคสและส่งต่อ)

### US-005: เปิดเคสเมื่อตอบไม่ได้หรือผู้ใช้ร้องขอ
**As a** ผู้แจ้งปัญหา
**I want** ให้ระบบเปิดเคสส่งต่อเจ้าหน้าที่เมื่อจำเป็น
**So that** ปัญหาของฉันได้รับการดูแลต่อ ไม่ตกหล่น

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** ระบบไม่พบคำตอบที่ยืนยันได้ **OR** ผู้ใช้ขอเปิดเคส/คุยกับเจ้าหน้าที่, **THEN** ระบบเริ่มกระบวนการเก็บรายละเอียดเพื่อเปิดเคส
2. **WHEN** เก็บข้อมูล, **THEN** ระบบถาม ประเภทปัญหา, ความเร่งด่วน, ระบบ (System), รายละเอียดปัญหา, ชื่อผู้แจ้ง และเบอร์ติดต่อ
3. **WHILE** ยังเก็บข้อมูลไม่ครบ, **IF** ผู้ใช้ยกเลิก, **THEN** ระบบหยุดโดยไม่สร้างเคส
4. **WHEN** `System.FallbackCount` ถึง 3, **THEN** ระบบเสนอและเริ่มกระบวนการเปิดเคสอัตโนมัติ

**Dependencies**: US-002

---

### US-006: บันทึกบริบทและสรุปปัญหาลงเคส
**As a** เจ้าหน้าที่/Owner
**I want** ให้เคสมีข้อมูลบริบทครบถ้วน
**So that** ทำงานต่อได้ทันทีโดยไม่ต้องไล่ถามผู้แจ้งซ้ำ

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** สร้างเคส, **THEN** ระบบบันทึก สรุปปัญหา, `System`/`Category`, priority/severity, `KB_ID` ที่เกี่ยวข้อง (ถ้ามี) และประวัติสนทนาย่อ
2. The system shall ไม่ทำให้รายละเอียดที่ผู้ใช้แจ้งตกหล่นในเคส
3. **IF** ผู้ใช้แนบภาพหน้าจอ/ข้อความ Error, **THEN** ระบบบันทึกอ้างอิงข้อมูลนั้นไว้กับเคส

**Dependencies**: US-005

---

### US-007: กำหนดผู้รับผิดชอบตามระบบ (Routing)
**As a** เจ้าหน้าที่/Owner
**I want** ให้เคสถูกส่งไปยังทีมที่รับผิดชอบระบบนั้นโดยอัตโนมัติ
**So that** เคสถึงมือคนที่แก้ได้เร็วที่สุด

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** สร้างเคสสำหรับ `System` หนึ่ง, **THEN** ระบบค้นหาผู้รับผิดชอบจาก routing list ตาม `SystemName`
2. **IF** ไม่พบผู้รับผิดชอบสำหรับ System นั้น, **THEN** ใช้ `Helpdesk` เป็นผู้รับผิดชอบเริ่มต้น
3. **WHEN** ได้ผู้รับผิดชอบ, **THEN** ระบบกำหนดผู้รับอีเมล (To/CC) ตาม `ToNotifyBA` / `ToNotifySA` / `CCNotify`

**Dependencies**: US-005

---

### US-008: สร้าง CaseID, ตั้งสถานะ Open และแจ้งทีม
**As a** เจ้าหน้าที่/Owner
**I want** ให้ทุกเคสมีเลขอ้างอิงและถูกแจ้งเข้าทีมทันที
**So that** ติดตามและรับผิดชอบเคสได้ชัดเจน

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** บันทึกเคสลง SharePoint สำเร็จ, **THEN** ระบบสร้าง `CaseID` รูปแบบ `Case-UserSystem-{yyyyMMdd}-{ID}` และตั้ง `Statuscase = Open`
2. **WHEN** สร้างเคสเสร็จ, **THEN** ระบบส่งอีเมลแจ้งทีมเจ้าหน้าที่/Owner พร้อมรายละเอียดเคสและ `CaseID`
3. **IF** การบันทึกเคสหรือส่งอีเมลล้มเหลว, **THEN** ระบบบันทึก error และแจ้งผู้ใช้ว่าจะมีเจ้าหน้าที่ตรวจสอบ (ต้องไม่จบการทำงานแบบเงียบ)

**Dependencies**: US-006, US-007

---

### US-009: แยกประเภทเคสตาม Action_Type
**As a** เจ้าหน้าที่/Owner
**I want** ให้เคสถูกจัดเก็บตามประเภทงาน
**So that** จัดการตามกระบวนการที่ถูกต้อง (Incident / Service Request / Business Support)

**Priority**: Medium

**Acceptance Criteria**:
1. **WHERE** รายการที่เกี่ยวข้องมี `Action_Type`, **WHEN** เปิดเคส, **THEN** ระบบจัดเก็บเคสในปลายทาง/ประเภทที่เหมาะสม
2. **IF** เป็นคำขอเกี่ยวกับ user/สิทธิ์ (เช่น reset password, ขอเปิดใช้งาน), **THEN** ระบบเก็บฟิลด์ `Username` เพิ่มเติม
3. The system shall ไม่ขอหรือบันทึกค่า Password/OTP แม้เป็นเคสประเภท access

**Dependencies**: US-005

---

## Functional Area 3: Notification & Follow-up (การแจ้งทราบและติดตาม)

### US-010: อีเมลแจ้งทราบผู้แจ้ง (Acknowledgment) + ยืนยันในแชท
**As a** ผู้แจ้งปัญหา
**I want** ได้รับการยืนยันว่าเรื่องถูกรับแล้วพร้อมเลขเคส
**So that** มั่นใจว่าเรื่องไม่หาย และใช้เลขเคสติดตามได้

**Priority**: High

**Acceptance Criteria**:
1. **WHEN** เปิดเคสสำเร็จ, **THEN** ระบบส่งอีเมลถึงผู้แจ้ง (email จาก Entra/`System.User.Email`) พร้อม `CaseID`, สรุปเรื่อง และวิธีติดตาม ภายใน ≤ 1 นาที
2. **WHEN** เปิดเคสสำเร็จ, **THEN** ระบบแสดงข้อความยืนยัน `CaseID` ในแชทด้วย
3. **IF** ไม่พบอีเมลของผู้แจ้ง, **THEN** ระบบยังคงแสดง `CaseID` ในแชทและบันทึกว่าไม่ได้ส่งอีเมล acknowledgment

**Dependencies**: US-008

---

### US-011: แจ้งผู้แจ้งเมื่อสถานะเคสเปลี่ยน
**As a** ผู้แจ้งปัญหา
**I want** ได้รับอีเมลเมื่อสถานะเคสเปลี่ยน
**So that** ทราบความคืบหน้าโดยไม่ต้องคอยถาม

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** เจ้าหน้าที่เปลี่ยนสถานะเคสใน SharePoint (`Open → In Progress → Resolved → Closed`), **THEN** ระบบส่งอีเมลแจ้งผู้แจ้งพร้อมสถานะใหม่และ `CaseID`
2. **WHERE** มีหมายเหตุความคืบหน้าจากเจ้าหน้าที่, **WHEN** ส่งอีเมล, **THEN** รวมหมายเหตุนั้นในอีเมล
3. **IF** สถานะเปลี่ยนเป็น `Resolved`, **THEN** อีเมลรวมข้อความเชิญให้ยืนยันผลหรือปิดเคส

**Dependencies**: US-008

---

### US-012: เช็คสถานะเคสด้วยตนเองผ่าน agent
**As a** ผู้แจ้งปัญหา
**I want** พิมพ์เลขเคสเพื่อดูสถานะได้ทันที
**So that** ติดตามความคืบหน้าได้เองทุกเมื่อ

**Priority**: Medium

**Acceptance Criteria**:
1. **WHEN** ผู้ใช้พิมพ์ `CaseID` หรือขอเช็คสถานะ, **THEN** ระบบค้นเคสและแสดงสถานะปัจจุบัน + วันเวลาอัปเดตล่าสุด
2. **IF** ไม่พบ `CaseID`, **THEN** ระบบแจ้งว่าไม่พบเคสและเสนอเปิดเคสใหม่หรือติดต่อเจ้าหน้าที่
3. **WHERE** ผู้ใช้ไม่ใช่เจ้าของเคส, **WHEN** ขอดูเคส, **THEN** ระบบแสดงเฉพาะเคสของผู้ใช้เอง (privacy)

**Dependencies**: US-008

---

### US-013: เตือนเคสค้างตาม SLA (SLA Reminder)
**As a** เจ้าหน้าที่/Owner
**I want** ให้ระบบเตือนเมื่อเคสค้างเกินเวลาที่กำหนด
**So that** ไม่มีเคสตกหล่นและรักษาระดับบริการ

**Priority**: Low

**Acceptance Criteria**:
1. **WHILE** เคสยังไม่ถูกปิด, **IF** ระยะเวลาค้างเกิน SLA ตาม `Severity` (P2 High เร็วกว่า P3 Normal), **THEN** ระบบส่งอีเมลเตือนเจ้าหน้าที่/Owner
2. **WHERE** เคสเกินเกณฑ์ escalation, **WHEN** ถึงเกณฑ์, **THEN** ระบบแจ้งผู้เกี่ยวข้องระดับถัดไป (เช่น CC หัวหน้า)

**Dependencies**: US-008, US-011

---

## Functional Area 4: KB Governance & Continuous Improvement (การดูแลฐานความรู้)

### US-014: รายงานคำถามที่ตอบไม่ได้ (Gap Report)
**As a** ผู้ดูแล KB
**I want** เห็นคำถามที่ agent ตอบไม่ได้
**So that** เติมเนื้อหา KB ให้ครอบคลุมขึ้น

**Priority**: Low

**Acceptance Criteria**:
1. **WHEN** ระบบไม่พบคำตอบที่ยืนยันได้และต้องเปิดเคส, **THEN** ระบบบันทึกคำถาม/ข้อความผู้ใช้และ `System` ที่เกี่ยวข้องเป็นรายการ gap
2. **WHERE** ผู้ดูแล KB, **WHEN** เปิดรายงาน gap, **THEN** เห็นรายการคำถามที่ตอบไม่ได้ จัดกลุ่มตาม System/ความถี่

**Dependencies**: US-005

---

### US-015: จัดการเนื้อหา KB ผ่านสถานะ Review/Approval
**As a** ผู้ดูแล KB
**I want** เพิ่ม/แก้/อนุมัติเนื้อหา KB อย่างมีการควบคุม
**So that** agent ตอบจากเนื้อหาที่ถูกต้องและอนุมัติแล้วเท่านั้น

**Priority**: Low

**Acceptance Criteria**:
1. **WHERE** ผู้ดูแล KB, **WHEN** เพิ่ม/แก้รายการ KB, **THEN** รายการเริ่มที่ `Review_Status = "Review Required"`
2. **WHEN** รายการได้รับอนุมัติ, **THEN** เปลี่ยน `Review_Status` เป็นสถานะพร้อมใช้และตั้ง `Is_Active = "Active"`
3. The system shall ใช้เฉพาะรายการที่อนุมัติและ `Active` ในการตอบ (สอดคล้องกับ US-004)

**Dependencies**: None

---

## Story Summary

| ID | Title | Area | Priority | Dependencies |
|----|-------|------|----------|--------------|
| US-001 | ตอบจากฐานความรู้ที่ยืนยันแล้ว | Knowledge Answering | High | None |
| US-002 | รวบรวมข้อมูลที่จำเป็นก่อนสรุป | Knowledge Answering | High | US-001 |
| US-003 | จัดการหลายรายการใกล้เคียง | Knowledge Answering | Medium | US-001 |
| US-004 | Guardrails ความปลอดภัย/คุณภาพ | Knowledge Answering | High | US-001, US-015 |
| US-005 | เปิดเคสเมื่อตอบไม่ได้/ร้องขอ | Case Capture & Routing | High | US-002 |
| US-006 | บันทึกบริบทลงเคส | Case Capture & Routing | High | US-005 |
| US-007 | Routing ผู้รับผิดชอบตามระบบ | Case Capture & Routing | High | US-005 |
| US-008 | CaseID + สถานะ Open + แจ้งทีม | Case Capture & Routing | High | US-006, US-007 |
| US-009 | แยกประเภทเคสตาม Action_Type | Case Capture & Routing | Medium | US-005 |
| US-010 | Acknowledgment ผู้แจ้ง + ยืนยันแชท | Notification & Follow-up | High | US-008 |
| US-011 | แจ้งเมื่อสถานะเปลี่ยน | Notification & Follow-up | Medium | US-008 |
| US-012 | เช็คสถานะผ่าน agent | Notification & Follow-up | Medium | US-008 |
| US-013 | SLA reminder เคสค้าง | Notification & Follow-up | Low | US-008, US-011 |
| US-014 | Gap report คำถามที่ตอบไม่ได้ | KB Governance | Low | US-005 |
| US-015 | จัดการเนื้อหา KB (review/approval) | KB Governance | Low | None |

---

## Story-Persona Matrix

| Story | ผู้แจ้งปัญหา | เจ้าหน้าที่/Owner | ผู้ดูแล KB |
|-------|:----:|:----:|:----:|
| US-001 | ✓ Primary | - | ✓ Secondary |
| US-002 | ✓ Primary | ✓ Secondary | - |
| US-003 | ✓ Primary | - | ✓ Secondary |
| US-004 | ✓ Primary | - | ✓ Primary |
| US-005 | ✓ Primary | ✓ Secondary | - |
| US-006 | ✓ Secondary | ✓ Primary | - |
| US-007 | - | ✓ Primary | - |
| US-008 | ✓ Secondary | ✓ Primary | - |
| US-009 | - | ✓ Primary | - |
| US-010 | ✓ Primary | - | - |
| US-011 | ✓ Primary | ✓ Secondary | - |
| US-012 | ✓ Primary | - | - |
| US-013 | - | ✓ Primary | - |
| US-014 | - | ✓ Secondary | ✓ Primary |
| US-015 | - | - | ✓ Primary |

---

## Out of Scope (สำหรับสเปกนี้)
- การเชื่อมต่อระบบ ticketing ภายนอกโดยตรง (เช่น SysAid) — ปัจจุบันเป็นการอ้างอิงใน `Approved_Answer` เท่านั้น
- การทำ voice/โทรศัพท์ หรือช่องทางนอกเหนือ Teams / M365 Copilot
- การวิเคราะห์เชิงสถิติ/แดชบอร์ด BI ของเคส (นอกเหนือจาก gap report พื้นฐาน)
- การแปลหลายภาษา (ระบบทำงานเป็นภาษาไทยตาม locale 1054)
- Single Sign-On / การเปลี่ยนรูปแบบ authentication (ใช้ Integrated/Entra เดิม)

---

## Non-Functional Considerations
(จะลงรายละเอียดในเฟส NFR / Phase 4)
- **Accuracy/Grounding**: ตอบเฉพาะจาก `Approved_Answer`; วัดอัตราการตอบผิด/หลุดกรอบ
- **Reliability**: การเปิดเคสและส่งอีเมลต้องไม่ล้มเหลวเงียบ; มี retry/logging สำหรับ flow
- **Performance**: เวลาตอบคำถามและส่ง acknowledgment (เป้าหมาย ≤ 1 นาทีสำหรับ ack)
- **Security/Privacy**: ห้ามเก็บ Password/OTP; ข้อมูลติดต่อผู้แจ้งอยู่ภายใต้ PDPA; เข้าถึงเคสได้เฉพาะเจ้าของ/เจ้าหน้าที่
- **Auditability**: บันทึกการเปิด/เปลี่ยนสถานะเคสและการส่งอีเมล
- **Maintainability**: ปรับ routing/SLA/KB ได้โดยไม่แก้โค้ด flow (ใช้ SharePoint list เป็น config)
