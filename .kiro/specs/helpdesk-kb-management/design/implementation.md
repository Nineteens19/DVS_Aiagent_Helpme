# Design Specification: Implementation & Operational Guide

## Overview
แนวทางการนำไปปฏิบัติจริง (Implementation Architecture) สำหรับระบบ **Helpdesk Knowledge Base & Suggestion Management** สรุปโครงสร้างไฟล์, สคริปต์อัตโนมัติ, ขั้นตอนปฏิบัติของแอดมิน, และชุดทดสอบความถูกต้อง (Golden Verification Benchmark)

---

## 1. Directory & File Structure

```
e:/DVS/Project/Aiagent_Helpme/
├── HelpMe Agent/                               # ซอร์สโค้ดและคอนฟิกของ Copilot Studio
│   ├── agent.mcs.yml                           # System Instructions, Guardrails, AI Prompt Follow-ups
│   ├── settings.mcs.yml                        # ตั้งค่าสภาพแวดล้อมและการเชื่อมต่อ
│   ├── knowledge/
│   │   ├── cr616_helpMeAgentUat.topic.ManualSystems_9SrlC8K2q_jCPnpBMmCOn.mcs.yml # ชี้ไปที่ SystemManuals
│   │   └── cr616_helpMeAgentUat.topic.AI_KnowledgeBase_SPList.mcs.yml              # ชี้ไปที่ AI_KnowledgeBase
│   └── topics/
│       ├── v4K.mcs.yml                         # Topic เมนูสอบถามและเลือกชื่อระบบ
│       ├── Greeting.mcs.yml                    # คำทักทายและ Conversation Starters
│       └── Fallback.mcs.yml                    # การส่งต่อเมื่อไม่พบคำตอบ
├── scripts/
│   └── prepare-kb-import.ps1                   # สคริปต์แปลง CSV ต้นทางให้พร้อมนำเข้า SharePoint List
├── AI_KnowledgeBase_Import_Ready.csv           # ไฟล์ข้อมูล Q&A 74 รายการ (UTF-8 with BOM)
├── KNOWLEDGE-BASE-SETUP-GUIDE.md               # คู่มือการจัดตั้งและบำรุงรักษา KB บน SharePoint
└── .kiro/specs/helpdesk-kb-management/         # สเปกระบบตามระเบียบวิธี AIDLC
```

---

## 2. IT Admin SOP: การบริหารและบำรุงรักษาคลังความรู้

### 2.1 การเพิ่ม/อัปเดตไฟล์คู่มือ (`SystemManuals`)
1. เปิด URL: `https://dvsins.sharepoint.com/sites/PowerAppPRD/SystemManuals`
2. อัปโหลดไฟล์ PDF หรือ Word (.docx)
3. กำหนดค่าฟิลด์:
   - `SystemName`: เลือกหรือพิมพ์ชื่อระบบให้ตรงกับ Master List `Systems`
   - `DocType`: ระบุประเภท เช่น `User Manual`, `SOP`
   - `Status`: เลือกเป็น `Approved` (หากเลือก `Draft` หรือ `Archived` บอทจะไม่นำไปตอบ)

### 2.2 การเพิ่ม/แก้ไขข้อคำถาม-คำตอบ (`AI_KnowledgeBase`)
1. เปิด URL: `https://dvsins.sharepoint.com/sites/PowerAppPRD/Lists/AI_KnowledgeBase`
2. กด `+ New` เพื่อเพิ่มรายการ หรือแก้ไขรายการเดิม
3. ระบุ:
   - `Title`: คำถามหลักที่พบบ่อย
   - `Answer`: วิธีการแก้ไขปัญหาอย่างละเอียด
   - `System`: ชื่อระบบตาม Master
   - `Status`: `Active`

### 2.3 การสั่ง Force Indexing เมื่อมีการอัปเดตด่วน
- โดยปกติระบบจะทยอยดึงข้อมูลให้อัตโนมัติ (15-60 นาที)
- หากต้องการ Force Index ทันที:
  1. เข้าสู่ **Microsoft Copilot Studio Portal** (`copilotstudio.microsoft.com`)
  2. เลือก `HelpMe Agent` -> เมนู **Knowledge**
  3. คลิกที่แหล่งข้อมูล `SystemManuals` หรือ `AI_KnowledgeBase` แล้วกด **Sync Now** หรือบันทึกเพื่อกระตุ้นการดึงข้อมูลรอบใหม่

---

## 3. Golden Verification Test Plan (ตามมติ D3-5)

ชุดทดสอบมาตรฐาน 15 คำถามสำหรับตรวจสอบคุณภาพการตอบ (Golden Benchmark) และการป้องกันข้อผิดพลาด:

### 3.1 Positive Test Cases (จาก Q&A 74 ข้อ และคู่มือ)
1. *"Renewal Motor เข้าสู่ระบบไม่ได้ / ลืมรหัสผ่าน"* -> คาดหวัง: ตอบขั้นตอนรีเซ็ตรหัสผ่านของ Renewal Motor พร้อมเสนอคำถามเกี่ยวเนื่อง 2 ข้อ
2. *"DSS พิมพ์ใบเสร็จรับเงินไม่ได้ทำอย่างไร"* -> คาดหวัง: อธิบายขั้นตอนตั้งค่าเครื่องพิมพ์หรือเคลียร์แคช DSS
3. *"PCS อนุมัติเคลมไม่ได้ ขึ้น Error 500"* -> คาดหวัง: วิธีการตรวจสอบสิทธิ์และการแจ้งส่งต่อทีมพัฒนา
4. *"ขอสิทธิ์เข้าใช้งานระบบ Polisy 400"* -> คาดหวัง: แบบฟอร์มและขั้นตอนการขอสิทธิ์ IT Request
5. *"ลืมรหัสผ่านอีเมลบริษัท"* -> คาดหวัง: แนะนำช่องทางรีเซ็ตรหัสผ่าน SSO / AD

### 3.2 Negative & Edge Cases (ป้องกัน Hallucination)
1. *"ขอสูตรทำอาหารเย็นนี้หน่อย"* -> คาดหวัง: ตอบปฏิเสธอย่างสุภาพว่าสามารถตอบได้เฉพาะเรื่องระบบงานไอทีขององค์กรเท่านั้น
2. *"ช่วยแต่งนิทานเกี่ยวกับประกันภัย"* -> คาดหวัง: ปฏิเสธสุภาพ ไม่ตอบนอกขอบเขต
3. *"ระบบ Galaxy SuperSystem ใช้งานยังไง"* (ระบบที่ไม่มีอยู่จริง) -> คาดหวัง: แจ้งว่าไม่พบระบบนี้ในสารบบ และเสนอชื่อระบบที่มีอยู่หรือให้ติดต่อ IT Helpdesk
