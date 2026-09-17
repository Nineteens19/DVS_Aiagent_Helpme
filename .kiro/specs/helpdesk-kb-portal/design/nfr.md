# Design Specification: Non-Functional Requirements (NFR) (`helpdesk-kb-portal`)

## Overview
ข้อกำหนดด้านคุณภาพและประสิทธิภาพทางเทคนิค (Non-Functional Requirements) สำหรับระบบ **Helpdesk Knowledge Base Management Portal**

---

## 1. Ergonomics & Screen Responsiveness

| Metric | Target | Design Implementation |
|--------|--------|------------------------|
| **Target Aspect Ratio** | 16:9 Widescreen (Laptop & Desktop) | ออกแบบขนาดฐาน 1366x768 และ Auto-layout รองรับถึง 1920x1080 |
| **Horizontal Scrolling** | 0% (ห้ามมี Scroll แนวนอน) | ใช้ Flexible Width Containers (`Parent.Width`) |
| **Data Density** | 12-15 แถวต่อหน้าจอ Laptop | แถวตาราง Gallery สูง 44px พอดีกับสายตาและพื้นที่คลิก |
| **Corporate Standards** | 100% Emoji-Free | ใช้เฉพาะข้อความทางการภาษาไทยและ Fluent Icons |

---

## 2. Performance & Latency Targets

| Operation | Max Latency | Optimization Mechanism |
|-----------|-------------|-------------------------|
| **Tab Module Switching** | < 0.2 วินาที | ซ่อน/แสดงคอนเทนเนอร์ในหน้าจอเดียวด้วยตัวแปร `varCurrentTab` (ไม่ต้องโหลดหน้าใหม่) |
| **Instant Search & Filter** | < 0.3 วินาที | Server-Side Delegable Queries ด้วย `StartsWith` และ Indexed Columns |
| **Dropdown Systems Load** | 0.0 วินาที | ดึงข้อมูล Master `Systems` เก็บใน Client Collection ตอน `App.OnStart` |
| **Drawer Slide Open/Close** | < 0.15 วินาที | ควบคุมด้วย Boolean Property `Visible` บน Side Container |

---

## 3. Data Integrity & Safety

| Area | Requirement | Enforcement Rule |
|------|-------------|-------------------|
| **Delegation Compliance** | 100% Delegable | ห้ามใช้สูตรที่ก่อให้เกิด Delegation Warning (เช่น `in` บนตารางใหญ่) |
| **Data Validation** | Strict Required Fields | ฟิลด์ `Title`, `Answer`, `System` ต้องไม่ว่างเปล่าก่อนสั่ง `SubmitForm` / `Patch` |
| **Accidental Delete Guard**| 100% Confirmation Dialog | แสดงกล่องยืนยันก่อนลบข้อมูลเสมอ เพื่อป้องกันการลบ Q&A สำคัญโดยไม่ได้ตั้งใจ |

---

## 4. Security & Access Control (RBAC)

- **Authentication**: เชื่อมต่อผ่าน M365 Entra ID SSO อัตโนมัติ
- **Role Enforcement**:
  - `IT Helpdesk Admin / BA`: มีสิทธิ์ Create, Edit, Delete, Toggle Status, Force Sync
  - `General Employees`: สิทธิ์ Read-only สำหรับการค้นหาคู่มือและอ่านคำตอบเท่านั้น (ปุ่มควบคุมแก้ไขจะถูกซ่อน)
