#!/bin/bash

cd /home/nuntawat/mss2025-project-template/

# 2. ตรวจสอบว่าเป็น Branch "Tongtong" หรือไม่ ถ้าไม่ใช่ให้ switch
git checkout nano

# 3. Add ไฟล์ทั้งหมด
git add .

# 4. Commit พร้อมระบุวันที่และเวลา เพื่อไม่ให้ข้อความซ้ำ
git commit -m "Auto Update: $(date '+%Y-%m-%d %H:%M:%S')"

# 5. Push ขึ้น Server
git push origin nano
