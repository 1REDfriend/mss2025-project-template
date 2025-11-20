#!/bin/bash
# File: Tongla.sh
# Description: Generate system stats and write to Tongla.js

USER_NAME=$(whoami)
IP_ADDR=$(hostname -I | awk '{print $1}')
OS_NAME=$(grep "^PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
KERNEL_VERSION=$(uname -r)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_PERCENT=$((100 * MEM_USED / MEM_TOTAL))
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
LAST_UPDATED=$(TZ='Asia/Bangkok' date "+%Y-%m-%d %H:%M:%S ICT")

# Process List (Top 5 by CPU)
PROCESS_LIST=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6 | tail -n +2 \
  | awk '{printf "{\"pid\":%s, \"name\":\"%s\", \"cpu\":%s, \"mem\":%s},", $1,$2,$3,$4}' | sed 's/,$//')

# Generate JavaScript File
cat <<EOF > Tongla.js
const systemStats = {
  user: "$USER_NAME",
  ip: "$IP_ADDR",
  os: "$OS_NAME",
  kernel: "$KERNEL_VERSION",
  cpuUsage: $CPU_USAGE,
  memoryUsage: $MEM_PERCENT,
  diskUsage: "${DISK_USAGE//%/}",
  lastUpdated: "$LAST_UPDATED",
  processes: [$PROCESS_LIST]
};
EOF

echo "✅ Tongla.js updated at $LAST_UPDATED"
