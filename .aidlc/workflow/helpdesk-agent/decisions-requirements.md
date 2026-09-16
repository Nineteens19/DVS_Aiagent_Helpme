# D1 Requirements Decisions

## Context Summary
- **Feature**: AI Helpdesk agent — ตอบจากฐานความรู้ที่ยืนยันแล้ว, เปิดเคสเมื่อตอบไม่ได้, ส่งอีเมลแจ้งทราบ/ติดตามสำหรับเคสที่รับแล้ว
- **Type**: Brownfield (Microsoft Copilot Studio + Power Automate + SharePoint + Office 365)
- **มีอยู่แล้ว**: ตอบจาก KB (74 รายการ), เปิดเคส (`OpenCase`) → บันทึก SharePoint + สร้าง CaseID + ส่งอีเมลถึง**ทีมเจ้าหน้าที่** ตาม routing list
- **ช่องว่างหลัก**: (1) ไม่มีอีเมลแจ้ง**ผู้แจ้ง** (acknowledgment), (2) ไม่มีการติดตามสถานะเคส (follow-up), (3) flow มี nested loop เสี่ยง bug
- **User types**: ผู้แจ้งปัญหา, ทีมเจ้าหน้าที่/Owner, ผู้ดูแล KB

> วิธีตอบ: เติมคำตอบในบรรทัด **Answer:** ของแต่ละข้อ (ใส่หมายเลขตัวเลือกก็ได้) แล้วพิมพ์ว่า **"done"** — หรือพิมพ์ **"use recommendations"** เพื่อใช้ตัวเลือกที่ผมแนะนำทั้งหมด

---

## Decision Questions

### D1-1: ขอบเขตของสเปก (Scope)
**Question**: จะให้สเปกนี้ครอบคลุมแค่ไหน?
- 1) เฉพาะส่วนที่ขาด — acknowledgment ถึงผู้แจ้ง + ติดตามสถานะ (เล็ก เร็ว โฟกัส)
- 2) ครอบคลุมทั้งระบบ — ตอบคำถาม + เปิดเคส + แจ้งทราบ + ติดตาม + ดูแล KB (แบ่งเป็น units) **(Recommended)**
- 3) ครอบคลุมทั้งระบบ แต่ไม่รวมงานดูแล/อนุมัติ KB
- 4) Other (ระบุ): _______

**Answer**: 2 (ครอบคลุมทั้งระบบ แบ่งเป็น units)

---

### D1-2: กลุ่มผู้ใช้และ Personas
**Question**: จะออกแบบโดยอิงผู้ใช้กี่กลุ่ม (และให้สร้างเอกสาร personas ไหม)?
- 1) 3 กลุ่ม: ผู้แจ้งปัญหา, ทีมเจ้าหน้าที่/Owner, ผู้ดูแล KB — สร้าง personas **(Recommended)**
- 2) 2 กลุ่ม: ผู้แจ้งปัญหา + เจ้าหน้าที่ (รวมผู้ดูแล KB เข้ากับเจ้าหน้าที่)
- 3) 1 กลุ่ม: ผู้แจ้งปัญหาอย่างเดียว (ไม่ต้องมี personas)
- 4) Other (ระบุ): _______

**Answer**: 1 (3 กลุ่ม + สร้าง personas)

---

### D1-3: การแจ้งทราบผู้แจ้ง (Acknowledgment)
**Question**: เมื่อเปิดเคสแล้ว จะแจ้งผู้แจ้งอย่างไร?
- 1) ส่งอีเมลถึงผู้แจ้งพร้อม CaseID + สรุปเรื่อง ทันทีที่เปิดเคส (ใช้ email จาก Entra/`System.User.Email`) **(Recommended)**
- 2) แจ้งเฉพาะข้อความในแชท (ไม่ส่งอีเมลถึงผู้แจ้ง)
- 3) ทั้งอีเมลถึงผู้แจ้ง + ข้อความยืนยัน CaseID ในแชท
- 4) Other (ระบุ): _______

**Answer**: 3 (อีเมลถึงผู้แจ้ง + ยืนยัน CaseID ในแชท) — ครอบคลุมกว่า option แนะนำเดิม เพื่อ UX ที่ดีขึ้น

---

### D1-4: โมเดลสถานะเคส (Case Status)
**Question**: จะใช้ชุดสถานะเคสแบบไหน?
- 1) Open → In Progress → Resolved → Closed **(Recommended)**
- 2) Open → Closed (สองสถานะ)
- 3) Open → In Progress → Done
- 4) Other (ระบุ): _______

**Answer**: 1 (Open → In Progress → Resolved → Closed)

---

### D1-5: การติดตาม/แจ้งเปลี่ยนสถานะ (Follow-up)
**Question**: จะแจ้งความคืบหน้าเคสให้ผู้แจ้งเมื่อไหร่ และทำงานอย่างไร?
- 1) เจ้าหน้าที่อัปเดตสถานะใน SharePoint → flow ตรวจจับการเปลี่ยน แล้วส่งอีเมลแจ้งผู้แจ้งทุกครั้งที่สถานะเปลี่ยน **(Recommended)**
- 2) ส่งอีเมลแจ้งผู้แจ้งเฉพาะตอนปิดเคส (Resolved/Closed) เท่านั้น
- 3) ไม่มี automation — เจ้าหน้าที่แจ้งเอง (สเปกนี้ไม่ครอบคลุม follow-up)
- 4) Other (ระบุ): _______

**Answer**: 1 (flow ตรวจจับการเปลี่ยนสถานะ → อีเมลแจ้งผู้แจ้งทุกครั้ง)

---

### D1-6: การเช็คสถานะเคสด้วยตนเองผ่าน agent
**Question**: ให้ผู้แจ้งพิมพ์ถามสถานะเคสกับ agent ได้ไหม?
- 1) ได้ — ผู้ใช้พิมพ์ CaseID แล้ว agent ดึงสถานะ/ความคืบหน้ามาแสดง **(Recommended)**
- 2) ไม่ต้อง — ใช้การแจ้งทางอีเมลอย่างเดียว
- 3) Other (ระบุ): _______

**Answer**: 1 (พิมพ์ CaseID → agent แสดงสถานะ)

---

### D1-7: การเตือนเคสค้าง (SLA reminder)
**Question**: ต้องการเตือนเมื่อเคสค้างเกินเวลาที่กำหนดไหม?
- 1) มี — เตือนเจ้าหน้าที่/Owner เมื่อเคสค้างเกิน SLA ตาม Severity (เช่น P2 เร็วกว่า P3) **(Recommended)**
- 2) มี — เตือนแบบเวลาเดียวกันทุกเคส (เช่น ค้างเกิน 2 วันทำการ)
- 3) ยังไม่ต้องมีในเฟสนี้
- 4) Other (ระบุ): _______

**Answer**: 1 (เตือนตาม SLA ตาม Severity)

---

### D1-8: ข้อมูลที่บันทึกลงเคส (Case Context)
**Question**: ให้บันทึกอะไรลงเคสบ้าง เพื่อให้เจ้าหน้าที่ทำงานต่อได้ง่าย?
- 1) สรุปปัญหา + `KB_ID`/หัวข้อที่ค้นเจอ + System/Category + priority + ประวัติสนทนาย่อ **(Recommended)**
- 2) เฉพาะรายละเอียดที่ผู้ใช้พิมพ์ + System + ผู้ติดต่อ (แบบเดิม)
- 3) Other (ระบุ): _______

**Answer**: 1 (สรุป + KB_ID + System/Category + priority + ประวัติย่อ)

---

### D1-9: การจัดการฐานความรู้ (KB Governance) — ตอบเมื่อเลือก scope ข้อ D1-1 = 2
**Question**: ให้สเปกครอบคลุมกระบวนการดูแล KB แค่ไหน?
- 1) ครอบคลุมการเพิ่ม/แก้/อนุมัติเนื้อหา KB (ใช้ `Review_Status`, `Is_Active`) + รายงานคำถามที่ตอบไม่ได้เพื่อเติม KB **(Recommended)**
- 2) เฉพาะรายงานคำถามที่ตอบไม่ได้ (gap report) ไม่รวม workflow อนุมัติ
- 3) ใช้ KB เดิม ไม่รวม governance ในสเปกนี้
- 4) Other (ระบุ): _______

**Answer**: 1 (ครอบคลุมเพิ่ม/แก้/อนุมัติ KB + gap report)

---

### D1-10: การจัดลำดับความสำคัญ (Priority / Phasing)
**Question**: จะจัดลำดับการส่งมอบอย่างไร?
- 1) P1: เปิดเคส + acknowledgment ผู้แจ้ง ให้ครบสมบูรณ์ → P2: ติดตามสถานะ + เช็คสถานะ → P3: SLA + KB governance **(Recommended)**
- 2) ทำทุกอย่างเป็นชุดเดียว ไม่แยกลำดับ
- 3) Other (ระบุ): _______

**Answer**: 1 (P1 case+ack → P2 follow-up+status → P3 SLA+KB)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D1-1 Scope: ครอบคลุมทั้งระบบ (answering + case + notification + follow-up + KB governance) แบ่งเป็น units
- D1-2 Personas: 3 personas — ผู้แจ้งปัญหา, ทีมเจ้าหน้าที่/Owner, ผู้ดูแล KB (สร้าง personas.md)
- D1-3 Acknowledgment: อีเมลถึงผู้แจ้งพร้อม CaseID + สรุปเรื่อง ทันทีที่เปิดเคส + ยืนยัน CaseID ในแชท
- D1-4 Case Status: Open → In Progress → Resolved → Closed
- D1-5 Follow-up: เจ้าหน้าที่อัปเดตสถานะใน SharePoint → flow ตรวจจับ → อีเมลแจ้งผู้แจ้งทุกครั้งที่สถานะเปลี่ยน
- D1-6 Self-service Status: ได้ — ผู้ใช้พิมพ์ CaseID แล้ว agent ดึงสถานะมาแสดง
- D1-7 SLA Reminder: เตือนเจ้าหน้าที่/Owner เมื่อเคสค้างเกิน SLA ตาม Severity (P2 < P3)
- D1-8 Case Context: สรุปปัญหา + KB_ID/หัวข้อ + System/Category + priority + ประวัติสนทนาย่อ
- D1-9 KB Governance: ครอบคลุมเพิ่ม/แก้/อนุมัติเนื้อหา (Review_Status, Is_Active) + gap report คำถามที่ตอบไม่ได้
- D1-10 Priority: P1 = case capture + acknowledgment, P2 = follow-up + self-service status, P3 = SLA reminder + KB governance

---

**Instructions**: Fill in your answers above and respond with "requirements decisions complete" (หรือพิมพ์ "done" / "use recommendations")


---

## Validation Notes
**Conflicts Detected**: 1 | **Resolved**: 1
### Acknowledged: Broad Scope Without Clear Boundaries (🟢 Low) → กำหนด "Out of Scope" ชัดเจนใน requirements.md และใช้การแบ่ง units (D2) + phasing (D1-10) เป็นขอบเขต
