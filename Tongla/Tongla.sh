#!/bin/bash

# Tongla.sh - ดึงข้อมูลระบบและเขียนผลออกเป็นไฟล์ Tongla.js

USER_NAME=$(whoami)
IP_ADDR=$(hostname -I | awk '{print $1}')
OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)

# CPU usage (ใช้ idle เป็นคอลัมน์ 8 ของ top)
CPU_USAGE=$(top -bn1 | awk -F'[, ]+' '/Cpu\(s\)/ {print 100-$8}')

# Memory (MB)
MEM_TOTAL=$(free -m | awk '/Mem/ {print $2}')
MEM_USED=$(free -m | awk '/Mem/ {print $3}')

# Storage จาก /
# ดึงค่าแบบ block 1K แล้วคำนวณเป็น GB เพื่อให้เป็นตัวเลขล้วน
ST_TOTAL_KB=$(df -k / | awk 'NR==2 {print $2}')
ST_USED_KB=$(df -k / | awk 'NR==2 {print $3}')
ST_TOTAL_GB=$(awk -v kb="$ST_TOTAL_KB" 'BEGIN {printf "%.2f", kb/1048576}')
ST_USED_GB=$(awk -v kb="$ST_USED_KB" 'BEGIN {printf "%.2f", kb/1048576}')
STORAGE_PERCENT=$(awk -v u="$ST_USED_KB" -v t="$ST_TOTAL_KB" 'BEGIN {if(t>0){printf "%.2f", (u/t)*100}else{print 0}}')

# Top processes
PROCESSES=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6)

# Time ICT
UPDATED_AT=$(TZ=Asia/Bangkok date +"%Y-%m-%d %H:%M:%S ICT")

cat <<EOF > Tongla.js
export const systemData = {
  user: "${USER_NAME}",
  ip: "${IP_ADDR}",
  os: "${OS_NAME}",
  kernel: "${KERNEL}",
  cpuUsage: ${CPU_USAGE},
  memory: {
    total: ${MEM_TOTAL},
    used: ${MEM_USED}
  },
  storage: {
    totalGB: ${ST_TOTAL_GB},
    usedGB: ${ST_USED_GB},
    percent: ${STORAGE_PERCENT}
  },
  lastUpdated: "${UPDATED_AT}",
  processes: \`
${PROCESSES}
  \`
};
EOF
