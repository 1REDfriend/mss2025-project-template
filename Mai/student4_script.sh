#!/bin/bash

cd /home/sarojphan/mss2025-project-template/Mai

# ===== Correct CPU Usage (Linux standard) =====
CPU=$(grep 'cpu ' /proc/stat | \
      awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf("%.0f", usage)}')

# ===== Correct Memory Usage =====
MEM=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')

# ===== Storage Root Partition =====
STORAGE=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')

# ===== Faster Directory & TXT Count =====
# Scan only /home (not whole system) to avoid slow cron
DIR_COUNT=$(find /home -type d 2>/dev/null | wc -l)
TXT_COUNT=$(find /home -type f -name "*.txt" 2>/dev/null | wc -l)

# ===== Date =====
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# ===== Files =====
TEMPLATE="template.html"
OUTPUT="Mai.html"

# ===== Replace HTML variables =====
sed \
  -e "s/{{CPU}}/${CPU}%/g" \
  -e "s/{{MEM}}/${MEM}%/g" \
  -e "s/{{STORAGE}}/${STORAGE}%/g" \
  -e "s/{{DIR_COUNT}}/${DIR_COUNT}/g" \
  -e "s/{{TXT_COUNT}}/${TXT_COUNT}/g" \
  -e "s/{{DATE}}/${DATE}/g" \
  "$TEMPLATE" > "$OUTPUT"

echo "Updated Mai.html successfully!"

