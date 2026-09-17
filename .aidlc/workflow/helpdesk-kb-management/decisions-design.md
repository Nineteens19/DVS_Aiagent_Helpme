# Design & Technology Decisions (D3)

## Context Summary
- **Feature**: `helpdesk-kb-management`
- **Units**:
  - Unit 1: `kb-storage-governance` (Document Library `SystemManuals` & SharePoint List `AI_KnowledgeBase` บน `https://dvsins.sharepoint.com/sites/PowerAppPRD`)
  - Unit 2: `agent-conversational-ux` (Copilot Studio `HelpMe Agent` เชื่อมต่อ RAG, Quick Replies ระบบ, และ AI Follow-up Suggestions)
- **Data Status**: ข้อมูลคำถาม-คำตอบ (Q&A) เดิม 74 รายการ ได้รับการแปลงและนำเข้าสู่ SharePoint List บน `PowerAppPRD` เรียบร้อยแล้ว และ Agent ได้รับการ Re-point + Publish เรียบร้อยแล้ว
- **Architectural Principles (จาก D1/D2)**:
  - AI Intelligence First: คอลัมน์ `SystemName` และ `System` เป็น `Single line of text` ยึดตาม Master List `Systems` เพื่อให้ Semantic Search ทำงานได้แม่นยำสูงสุด
  - High-Speed Hybrid: การเลือกดูข้อมูลระบบเน้นความเร็วระดับเสี้ยววินาที เสริมด้วย AI Disambiguation

---

## Decision Questions

### D3-1: Knowledge Retrieval Strictness & Hallucination Prevention
**Question**: ควรตั้งค่าระดับความเข้มงวด (Content Moderation / Grounding Strictness) และพฤติกรรมการตอบของ AI เมื่อผู้ใช้ถามคำถามที่ไม่มีอยู่ในคลังความรู้ไว้อย่างไร?
- 1) **Strict Grounding with Fallback Escalation**: ตอบเฉพาะเนื้อหาที่มีข้อมูลรองรับใน `SystemManuals` และ `AI_KnowledgeBase` เท่านั้น หากไม่พบข้อมูล ให้แจ้งผู้ใช้ตามตรงว่าไม่พบในคู่มือ พร้อมเสนอให้ส่งต่อเจ้าหน้าที่ IT Helpdesk หรือเปิดเคสใหม่ทันที ห้ามคาดเดาหรือแต่งคำตอบ **(Recommended)**
     - *ข้อดี*: ป้องกันปัญหาข้อมูลเท็จ (Hallucination) ได้ 100%, ปลอดภัยสูงสุดสำหรับงาน IT Enterprise
     - *ข้อเสีย*: หากผู้ใช้ถามด้วยคำที่แปลกมากๆ AI จะไม่พยายามตอบทั่วไป
- 2) **Balanced Reasoning with Disclaimer**: ให้ AI ใช้ความรู้ทั่วไปของ GPT ช่วยตอบเสริมได้ในกรณีที่ข้อมูลในคู่มือมีเพียงบางส่วน แต่ต้องใส่ข้อความเตือน (Disclaimer) ชัดเจนว่าคำแนะนำนี้เป็นข้อมูลทั่วไป
     - *ข้อดี*: ให้คำตอบได้ยืดหยุ่นขึ้นในกรณีถามเรื่องคอมพิวเตอร์ทั่วไป
     - *ข้อเสีย*: เสี่ยงต่อการให้ขั้นตอนที่ไม่ตรงกับ SOP หรือนโยบายเฉพาะของบริษัท
- 3) Other (please specify): _______

**Answer**: 1) Strict Grounding with Fallback Escalation (Recommended)

---

### D3-2: In-Dialog System Menu UX & Dynamic Selection (Topic `v4K`)
**Question**: สำหรับการแสดงเมนูตัวเลือกระบบงานใน Topic `v4K` (เพื่อให้ผู้ใช้เลือกระบบที่ต้องการสอบถามหรือแจ้งปัญหา) ควรออกแบบเชิงสถาปัตยกรรมอย่างไร?
- 1) **Static Top Systems with AI Free-text Disambiguation (Zero Latency)**: แสดงปุ่ม Quick Reply 4 ระบบหลักที่พบบ่อยที่สุด (DSS, Renewal Motor, PCS, Polisy 400) + ปุ่ม "ระบุระบบอื่น" หากผู้ใช้เลือกพิมพ์ชื่อระบบเอง AI จะเทียบชื่อกับ Master Systems ใน System Prompt ให้โดยอัตโนมัติ โดยไม่มีความหน่วงจาก Power Automate **(Recommended)**
     - *ข้อดี*: ตอบสนองทันทีในเสี้ยววินาที (0s latency), เสถียรสูง, ไม่กินโควต้า API Flow run
     - *ข้อเสีย*: หากมีระบบใหม่เป็น Top 4 ต้องอัปเดต Topic เพิ่มเติม
- 2) **Full Dynamic Adaptive Card via Power Automate Flow**: ทุกครั้งที่เข้า Topic `v4K` ให้เรียก Flow ไปดึงรายชื่อจาก SharePoint List `Systems` แล้วสร้าง Dropdown ใน Adaptive Card ให้เลือก
     - *ข้อดี*: สะท้อนระบบใหม่ได้ทันทีจาก SharePoint
     - *ข้อเสีย*: มีความหน่วงในการเรียก Flow ประมาณ 1.5 - 2.5 วินาที ทำให้ประสบการณ์แชทช้าลง
- 3) Other (please specify): _______

**Answer**: 1) Static Top Systems with AI Free-text Disambiguation (Recommended)

---

### D3-3: Follow-up Suggestions Delivery & Visual Format
**Question**: รูปแบบการแสดงผลคำถามแนะนำที่เกี่ยวข้อง 2 ข้อท้ายคำตอบของ AI ควรนำเสนอแก่ผู้ใช้งานในลักษณะใด?
- 1) **Inline Markdown Prompt Bullets with Interactive Styling**: แสดงเป็นส่วนท้ายของข้อความคำตอบโดยแบ่งบรรทัดชัดเจน มีหัวข้อ "คำถามที่อาจเกี่ยวข้อง:" พร้อมข้อความคำถาม 2 ข้อที่กระชับ เพื่อให้ผู้ใช้สามารถ Copy หรือคลิกพิมพ์ต่อได้ง่ายในทุกช่องทาง (Teams, Web Chat, Mobile) **(Recommended)**
     - *ข้อดี*: ทำงานได้สมบูรณ์และเสถียร 100% บนทุก Channel ไม่ติดข้อจำกัดของ Client Rendering
     - *ข้อเสีย*: ไม่ได้เป็นปุ่มกดลอย (Chip Button) เหมือน Native Bot Framework
- 2) **Direct Action Chips / Suggested Actions**: ให้ Agent ส่ง Suggestion Chips แบบ Native Card ออกมาเป็นปุ่มกดใต้ข้อความ
     - *ข้อดี*: สวยงาม ผู้ใช้กดได้ทันทีโดยไม่ต้องพิมพ์
     - *ข้อเสีย*: บาง Channel หรือ Copilot Generative Answer Node อาจไม่รองรับ Dynamic Suggested Actions จากคำตอบที่ Generate สดโดยตรง
- 3) Other (please specify): _______

**Answer**: 1) Inline Markdown Prompt Bullets with Interactive Styling (Recommended)

---

### D3-4: Knowledge Update & Index Refresh Strategy
**Question**: เมื่อเจ้าหน้าที่ IT Helpdesk หรือ BA มีการอัปเดตไฟล์คู่มือใน `SystemManuals` หรือเพิ่ม/แก้ข้อคำถามใน `AI_KnowledgeBase` ควรบริหารการอัปเดตดัชนีการค้นหา (Search Indexing) อย่างไร?
- 1) **Automatic SharePoint Periodic Sync with Admin Manual Trigger Guide**: ยึดกลไก Automatic Background Crawl ของ Copilot Studio (ซึ่งจะดึงข้อมูลใหม่ภายใน 15-60 นาทีโดยอัตโนมัติ) ควบคู่กับการจัดทำขั้นตอนสำหรับ Admin ในกรณีต้องการ Force Indexing ทันทีผ่าน Copilot Studio Portal **(Recommended)**
     - *ข้อดี*: ไม่ต้องเขียน Service หรือ Flow มา Sync ซ้ำซ้อน, ใช้ความสามารถตามมาตรฐาน M365 Security & Graph Indexer
     - *ข้อเสีย*: ข้อมูลที่เพิ่งเพิ่มสดๆ อาจไม่ได้ผลลัพธ์ทันทีในนาทีแรก
- 2) **Automated Power Automate Webhook Re-index Notification**: สร้าง Flow ตรวจจับเมื่อมีรายการใหม่ใน SharePoint แล้วส่ง Notification แจ้งเตือนในห้อง IT Helpdesk Team ให้ทราบสถานะการอัปเดตความรู้
     - *ข้อดี*: ทีมงานทราบสถานะการอัปเดตแบบเรียลไทม์
     - *ข้อเสีย*: มีความซับซ้อนของ Flow เพิ่มเติม
- 3) Other (please specify): _______

**Answer**: 1) Automatic SharePoint Periodic Sync with Admin Manual Trigger Guide (Recommended)

---

### D3-5: Correctness & Verification Testing Strategy (Mandatory)
**Question**: แนวทางการทดสอบความถูกต้องของสถาปัตยกรรม Knowledge Retrieval และ Conversational Quality ควรใช้เกณฑ์และชุดทดสอบใด?
- 1) **Golden Q&A Benchmark + Negative Edge-case Validation**:
     - สร้างชุดทดสอบ Golden Test Set 15-20 คำถาม ครอบคลุมทั้งคำถามตรงจาก Q&A 74 ข้อ (เช่น Renewal Motor, DSS), คำถามจากคู่มือ PDF, และคำถามก้ำกึ่ง (Synonyms)
     - ทดสอบ Negative Case (คำถามที่ไม่เกี่ยวข้อง เช่น เรื่องส่วนตัว, ระบบที่ไม่มีอยู่) ต้องตอบปฏิเสธสุภาพและไม่ Hallucinate 100%
     - ตรวจสอบ Citations Link ว่าชี้ไปยังเอกสาร/รายการที่ถูกต้อง **(Recommended)**
     - *ข้อดี*: ครอบคลุมทั้งความแม่นยำ (Accuracy) และความปลอดภัยของระบบ (Safety & Grounding)
- 2) **Ad-hoc Manual Spot-checking**: ให้ทีม Helpdesk ทดสอบถามตอบแบบสุ่ม 3-5 คำถามก่อนใช้งาน
     - *ข้อดี*: ใช้เวลาน้อย
     - *ข้อเสีย*: ไม่สามารถการันตีความครอบคลุมและป้องกัน Regression ในอนาคตได้
- 3) Other (please specify): _______

**Answer**: 1) Golden Q&A Benchmark + Negative Edge-case Validation (Recommended)

---

## Decisions Summary
<!-- Machine-readable compact summary. Downstream agents: read ONLY this section. -->
<!-- Auto-populated after user fills answers above. One line per decision. -->
- D3-1 Retrieval Strictness: Strict Grounding with Fallback Escalation (Recommended)
- D3-2 In-Dialog System Menu UX: Static Top Systems with AI Free-text Disambiguation (Recommended)
- D3-3 Follow-up Suggestions Format: Inline Markdown Prompt Bullets with Interactive Styling (Recommended)
- D3-4 Index Refresh Strategy: Automatic SharePoint Periodic Sync with Admin Manual Trigger Guide (Recommended)
- D3-5 Verification Strategy: Golden Q&A Benchmark + Negative Edge-case Validation (Recommended)

---

**Instructions**: Fill in your answers above and respond with "design decisions complete" or "use recommendations"
