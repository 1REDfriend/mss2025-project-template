#!/bin/bash

# 1. cd เข้า repo ให้ถูกต้อง
cd /home/sarojphan/mss2025-project-template/Mai

# 2. รัน script update html
./student4_script.sh

# 3. กลับขึ้นไป root repo (เพื่อ commit ที่ถูกต้อง)
cd /home/sarojphan/mss2025-project-template

git checkout Mai
git add .

git commit -m "Auto Update: $(date '+%Y-%m-%d %H:%M:%S')"

git push origin Mai

