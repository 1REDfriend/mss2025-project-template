#!/bin/bash

# Tongla.sh - ดึงข้อมูลระบบและเขียนผลออกเป็นไฟล์ Tongla.js

# ดึงข้อมูล
USER_NAME=$(whoami)
IP_ADDR=$(hostname -I | awk '{print $1}')
OS_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM_TOTAL=$(free -m | awk '/Mem/ {print $2}')
MEM_USED=$(free -m | awk '/Mem/ {print $3}')
STORAGE_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
STORAGE_USED=$(df -h / | awk 'NR==2 {print $3}')
PROCESSES=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6)
UPDATED_AT=$(date +"%Y-%m-%d %H:%M:%S ICT")

# สร้างไฟล์ JS ที่ export variable
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
    total: "${STORAGE_TOTAL}",
    used: "${STORAGE_USED}"
  },
  lastUpdated: "${UPDATED_AT}",
  processes: \`
${PROCESSES}
  \`
};
EOF
