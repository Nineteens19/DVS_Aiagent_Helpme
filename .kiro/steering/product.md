---
inclusion: always
---
# Product Context

## Overview

ระบบ HelpMe ประกอบด้วย 2 ส่วนหลักสำหรับ Deves Insurance:
1. **HelpMe Agent (Microsoft Copilot Studio)**: ผู้ช่วย AI อัตโนมัติสำหรับพนักงาน/ตัวแทน ใช้ตอบคำถามจากฐานความรู้ (Approved Answer) และเปิดเคสลง SharePoint เมื่อตอบไม่ได้
2. **Monitor_case_Helpdesk (Power Apps Canvas App)**: ระบบเว็บแอปพลิเคชันหน้าบ้านสำหรับทีม IT Helpdesk และเจ้าหน้าที่ผู้รับผิดชอบระบบ ใช้มอนิเตอร์ ติดตามสถานะ ค้นหาเคส รับงาน และปิดเคสพร้อมแนบหลักฐาน

## Problem Statement

ปัจจุบันหน้าจอ **Monitor_case_Helpdesk** มีปัญหาสำคัญที่ต้องปรับปรุง:
1. **ภาพลักษณ์ไม่เป็นทางการ**: มีการใส่ Emoji ปะปนในชื่อหน้าจอ ปุ่มกด และป้ายสถานะจำนวนมาก ต้องการปรับเป็น **Modern Enterprise UI** ปราศจาก Emoji
2. **ขาดการบันทึกหลักฐานการปิดเคส**: เมื่อเจ้าหน้าที่แก้ไขปัญหาเสร็จสิ้น ยังไม่มีจุดแนบไฟล์หลักฐาน (รูปภาพ error, screenshot, เอกสารสรุปงาน) ประกอบการ Resolve/Close เคส
3. **การรองรับปริมาณข้อมูลสูงในอนาคต (High-Volume Data & Delegation)**: ข้อมูลเคสจะเพิ่มขึ้นอย่างต่อเนื่อง การ Filter ข้อมูลบน SharePoint ต้องรองรับการสืบค้นแบบ Delegable ไม่ติดข้อจำกัด 500-2,000 แถว
4. **ความเหมาะสมของ Layout บนจอ Laptop**: หน้าจอเดิมจัดวางแบบหลวม ข้อมูลเคสมีรายละเอียดเยอะ เจ้าหน้าที่ต้องเลื่อนหน้าจอบ่อย จึงต้องการ Layout ที่มีความหนาแน่นข้อมูลเหมาะสม (High Information Density) บนหน้าจอขนาด Laptop/Desktop

## Target Users

- **IT Helpdesk & System Support (Operators)**: เจ้าหน้าที่ผู้รับผิดชอบงานแก้ปัญหา ทำงานผ่านหน้าจอ Laptop ตลอดวัน ต้องการความเร็วในการกรองข้อมูล การดูประวัติ และการแนบหลักฐานปิดเคส
- **Helpdesk Supervisors & Admins**: ผู้ดูแลภาพรวมเคส ตรวจสอบ SLA งานค้าง และตรวจสอบความถูกต้องของหลักฐานการปิดงาน
- **End Users / พนักงาน / ตัวแทน**: ผู้แจ้งเคสผ่าน HelpMe Agent ซึ่งจะได้รับทราบสถานะเคสที่อัปเดตอย่างถูกต้อง

## Key Features

- **Modern Enterprise Monitoring Dashboard**: แดชบอร์ดสรุปเคสที่สะอาด ทันสมัย ไม่มี Emoji พร้อม KPI Cards และ Filter Bar กระชับสำหรับ Laptop
- **High-Volume Delegable Filtering**: ตัวกรองเคสตามสถานะ, ระบบ, ผู้รับผิดชอบ, ช่วงเวลา ที่ออกแบบให้ทำงานแบบ Server-Side Delegation กับ SharePoint ได้อย่างเต็มประสิทธิภาพ
- **Case Resolution Evidence & Attachment**: ระบบอัปโหลดและแสดงผลไฟล์หลักฐานประกอบการปิดเคส บันทึกสรุปแนวทางแก้ไข และประทับเวลา ResolvedAt/ClosedAt อย่างเป็นระบบ
- **Dense Responsive Laptop Grid**: ตารางแสดงรายการเคสที่อ่านง่าย คอลัมน์ชัดเจน มีตัวชี้วัด SLA และเปิดดูรายละเอียดในรูปแบบ Split-view / Detail Drawer

## Project Type

- **Type**: Brownfield
- **Scope**: Enhancement — ปรับปรุง UI/UX, Data Layer และ Business Logic ของ `Monitor_case_Helpdesk` Canvas App
