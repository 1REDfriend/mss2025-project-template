#!/bin/bash
cd /home/sarojphan/mss2025-project-template/Mai
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)
MEM=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
STORAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
DIR_COUNT=$(find / -type d 2>/dev/null | wc -l)
TXT_COUNT=$(find / -type f -name "*.txt" 2>/dev/null | wc -l)
DATE=$(date "+%Y-%m-%d %H:%M:%S")

TEMPLATE="template.html"
OUTPUT="Mai.html"

sed -e "s/{{CPU}}/${CPU}%/" \
    -e "s/{{MEM}}/${MEM}%/" \
    -e "s/{{STORAGE}}/${STORAGE}%/" \
    -e "s/{{DIR_COUNT}}/${DIR_COUNT}/" \
    -e "s/{{TXT_COUNT}}/${TXT_COUNT}/" \
    -e "s/{{DATE}}/${DATE}/" \
    "$TEMPLATE" > "$OUTPUT"

echo "Updated Mai.html successfully!"

