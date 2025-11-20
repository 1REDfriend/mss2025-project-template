#!/bin/bash

# 1. เข้าไปที่โฟลเดอร์โปรเจกต์ก่อน (สำคัญมาก เพราะ Cron ไม่รู้ว่าเราอยู่ที่ไหน)
cd /home/supakorn/git/mss2025-project-template/

# 2. ตรวจสอบว่าเป็น Branch "Tongtong" หรือไม่ ถ้าไม่ใช่ให้ switch
git checkout Tongtong

# 3. Add ไฟล์ทั้งหมด
git add .

# 4. Commit พร้อมระบุวันที่และเวลา เพื่อไม่ให้ข้อความซ้ำ
git commit -m "Auto Update: $(date '+%Y-%m-%d %H:%M:%S')"

# 5. Push ขึ้น Server
git push origin Tongtong
