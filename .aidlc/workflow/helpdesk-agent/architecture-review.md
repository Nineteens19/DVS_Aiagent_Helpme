# Architecture Review — helpdesk-agent (cross-unit)

**Reviewer**: Principal Architect
**Date**: 2026-09-14
**Units reviewed**: foundation, case-management, notification-followup, knowledge-answering, kb-governance

## Alignment Status: **Partially Aligned** ✅ (ไม่มี CRITICAL blocker)

| Severity | Count |
|----------|:-----:|
| 🔴 CRITICAL | 0 |
| 🟠 MAJOR | 2 |
| 🟡 MINOR | 3 |

โดยรวม design สอดคล้องกันดี เพราะทุก unit ยึด contract จาก `foundation` (Cases schema, events, CaseID, email templates, error handling) ประเด็นที่พบเป็นเรื่อง **ความชัดเจนของเจ้าของงาน (ownership) และลำดับการทำ** ไม่ใช่ conflict เชิงสถาปัตยกรรม

---

## Issues

### 🟠 MAJOR-1: เจ้าของการแก้ topic `OpenCase`/`Escalate`
- **Affected**: foundation (task 5.5 "minimal rewire"), case-management (redesign เต็ม)
- **Issue**: ทั้งสอง unit แตะ `OpenCase`/`Escalate` — เสี่ยงแก้ทับกัน
- **Resolution**: ให้ **case-management เป็นเจ้าของการแก้ topic ทั้งหมด**; foundation `cutover` จำกัดเฉพาะ lists/flows/migration/publish (ไม่แตะ topic) → ปรับ foundation task 5.5
- **Impact**: ตัดความซ้ำซ้อน; ลำดับ = foundation (data/flows) → case-management (topics)

### 🟠 MAJOR-2: เจ้าของเนื้อหาอีเมล Acknowledgment
- **Affected**: foundation (CreateCaseAndAck ส่ง ack — task 3.5), notification-followup (นิยามเนื้อหา ack — task 1.1)
- **Issue**: กลไกส่งอยู่ foundation แต่เนื้อหาอยู่ notification-followup
- **Resolution**: **foundation เป็นเจ้าของ template + การส่ง**; notification-followup **นิยาม "เนื้อหา/ฟิลด์"** ของ ack แล้วส่งให้ foundation ใช้ (template placeholder) → ลำดับ: กำหนดเนื้อหา ack ก่อน foundation 3.5 ทำการส่ง
- **Impact**: ack ไม่ตกหล่น/ไม่ทำซ้ำ

### 🟡 MINOR-1: Flow shells vs logic (NotifyStatusChange / RemindStaleCases)
- **Affected**: foundation (สร้าง shell — 4.1/4.2), notification-followup (เติม logic — 2.x/3.x)
- **Resolution**: foundation สร้าง shell (trigger + connection + error scope) ก่อน; notification-followup เติม business logic/content — ทำตามลำดับ (documented แล้ว)

### 🟡 MINOR-2: การแก้ `agent.mcs.yml` (guardrails)
- **Affected**: foundation (baseline — 5.4), knowledge-answering (answering-specific — 1.1)
- **Resolution**: foundation ใส่ baseline ก่อน → knowledge-answering ต่อยอด (ไฟล์เดียวกัน ทำตามลำดับ)

### 🟡 MINOR-3: `SlaDueDate` dependency
- **Affected**: foundation (คำนวณตอน create — 3.4), notification-followup (ใช้ใน RemindStaleCases)
- **Resolution**: ต้องมั่นใจว่า foundation 3.4 เขียน `SlaDueDate` ก่อน RemindStaleCases ทำงาน — เป็น dependency ปกติ (documented)

---

## Recommendations

### Immediate actions
1. ปรับ foundation task 5.5: cutover จำกัดเฉพาะ data/flows/migration/publish — ย้ายการแก้ topic ไป case-management (จะปรับให้)
2. ยืนยัน boundary ack: foundation = template+ส่ง, notification-followup = เนื้อหา

### Consolidation opportunities
- ทุก email ใช้ template กลางของ foundation (ack/status/reminder/error) — ยึดจุดเดียว
- guardrails รวมที่ `agent.mcs.yml` baseline เดียว แล้วแต่ละ unit อ้างอิง

### Recommended Implementation Sequence (cross-unit)
1. **foundation** — lists, connections, templates, `CreateCaseAndAck`, error handling, migration (ยกเว้น topic rewire)
2. **case-management** — redesign `OpenCase`/`Escalate` + เรียก flow + แสดง CaseID
3. **knowledge-answering** — guardrails refine, Search, no-answer handoff (พึ่ง OpenCase)
4. **notification-followup** — เติม NotifyStatusChange/RemindStaleCases + CaseStatus topic + ack content
5. **kb-governance** — gap views, KB lifecycle, gap→KB

## Conclusion
**GO** ✅ — เดินหน้า implement ได้ หลังปรับ MAJOR-1 (ownership ของ topic) และยืนยัน MAJOR-2 (ownership ของ ack) ซึ่งเป็นการปรับเล็กน้อยเชิงขอบเขต ไม่กระทบสถาปัตยกรรม
