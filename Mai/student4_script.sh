#!/bin/bash

# ไปที่โฟลเดอร์ Mai
cd /home/sarojphan/mss2025-project-template/Mai

TEMPLATE="template.html"
OUTPUT="Mai.html"

# ===== CPU Usage =====
CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf("%.0f", usage)}')

# ===== Memory Usage =====
MEM=$(free | awk '/Mem/ {printf("%.0f", $3/$2 * 100)}')

# ===== Storage =====
STORAGE=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')

# ===== Directory & TXT Count =====
DIR_COUNT=$(find /home/sarojphan -type d | wc -l)
TXT_COUNT=$(find /home/sarojphan -type f -name "*.txt" | wc -l)

# ===== Timestamp =====
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# ===== Replace Variables =====
sed \
  -e "s/{{CPU}}/${CPU}%/g" \
  -e "s/{{MEM}}/${MEM}%/g" \
  -e "s/{{STORAGE}}/${STORAGE}%/g" \
  -e "s/{{DIR_COUNT}}/${DIR_COUNT}/g" \
  -e "s/{{TXT_COUNT}}/${TXT_COUNT}/g" \
  -e "s/{{DATE}}/${DATE}/g" \
  "$TEMPLATE" > "$OUTPUT"

echo "Updated Mai.html successfully!"

