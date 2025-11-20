#!/bin/bash
# Simple system status -> HTML generator
# Usage: ./gen_status.sh [template.html] [output.html]

set -eu

TEMPLATE="${1:-Tongtong_template.html}"
OUTPUT="${2:-Tongtong.html}"

# ---------- Basic info ----------
HOSTNAME=$(hostname)
LAST_UPDATED=$(date '+%Y-%m-%d %H:%M:%S')
GEN_TIMESTAMP="$LAST_UPDATED"
HOST_ID=$(cat /etc/machine-id 2>/dev/null || echo "unknown")

UPTIME=$(uptime -p 2>/dev/null || uptime | sed 's/.*up *//; s/, *[0-9]* users.*//')
KERNEL_VERSION=$(uname -r)
DISTRO_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Unknown")

# ---------- CPU ----------
CPU_CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 1)
CPU_THREADS="$CPU_CORES"

# loadavg
CPU_LOAD_1=$(awk '{print $1}' /proc/loadavg 2>/dev/null || echo 0)
CPU_LOAD_5=$(awk '{print $2}' /proc/loadavg 2>/dev/null || echo 0)
CPU_LOAD_15=$(awk '{print $3}' /proc/loadavg 2>/dev/null || echo 0)

# CPU usage via /proc/stat (two samples)
cpu_line1=$(grep '^cpu ' /proc/stat)
sleep 0.5
cpu_line2=$(grep '^cpu ' /proc/stat)

set -- $cpu_line1
_=$1; u1=$2; n1=$3; s1=$4; i1=$5; w1=$6; irq1=$7; sirq1=$8; st1=$9
total1=$((u1+n1+s1+i1+w1+irq1+sirq1+st1))

set -- $cpu_line2
_=$1; u2=$2; n2=$3; s2=$4; i2=$5; w2=$6; irq2=$7; sirq2=$8; st2=$9
total2=$((u2+n2+s2+i2+w2+irq2+sirq2+st2))

idle_diff=$((i2 - i1))
total_diff=$((total2 - total1))

if [ "$total_diff" -le 0 ]; then
    CPU_USAGE="0.0"
else
    CPU_USAGE=$(awk "BEGIN { printf \"%.1f\", (1-($idle_diff/$total_diff))*100 }")
fi

# CPU temp (best-effort)
if command -v sensors >/dev/null 2>&1; then
    CPU_TEMP=$(sensors 2>/dev/null | awk '
        /Tctl:|Tdie:|Package id 0:|Tctl/ {
          if (match($0, /([0-9]+\.[0-9]+)/, a)) { print a[1]; exit }
        }' )
    [ -n "${CPU_TEMP:-}" ] || CPU_TEMP="N/A"
else
    CPU_TEMP="N/A"
fi

# ---------- Memory ----------
if command -v free >/dev/null 2>&1; then
    MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
    MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
    MEM_USED_PCT=$(awk "BEGIN { if ($MEM_TOTAL == 0) print 0; else printf \"%.1f\", ($MEM_USED/$MEM_TOTAL)*100 }")

    SWAP_USED=$(free -m | awk '/^Swap:/ {print $3}')
    SWAP_TOTAL=$(free -m | awk '/^Swap:/ {print $2}')
    if [ "$SWAP_TOTAL" -eq 0 ] 2>/dev/null; then
        SWAP_USED_PCT="0.0"
    else
        SWAP_USED_PCT=$(awk "BEGIN { printf \"%.1f\", ($SWAP_USED/$SWAP_TOTAL)*100 }")
    fi
else
    MEM_USED="0"
    MEM_TOTAL="0"
    MEM_USED_PCT="0.0"
    SWAP_USED="0"
    SWAP_TOTAL="0"
    SWAP_USED_PCT="0.0"
fi

# ---------- Disk (/) ----------
DISK_ROOT_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_ROOT_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_ROOT_USED_PCT=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')
DISK_ROOT_DEVICE=$(df -P / | awk 'NR==2 {print $1}')
DISK_ROOT_INODE_PCT=$(df -i / | awk 'NR==2 {gsub("%","",$5); print $5}')

# ---------- Network (default iface) ----------
if command -v ip >/dev/null 2>&1; then
    NET_IFACE=$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')
    if [ -z "${NET_IFACE:-}" ]; then
        NET_IFACE=$(ip -o link show | awk -F': ' '$2 != "lo" {print $2; exit}')
    fi
else
    NET_IFACE=""
fi

NET_IPV4="N/A"
NET_IPV6="N/A"
NET_RX_MBPS="0.00"
NET_TX_MBPS="0.00"

if [ -n "$NET_IFACE" ]; then
    NET_IPV4=$(ip -4 addr show dev "$NET_IFACE" 2>/dev/null | awk '/inet / {print $2; exit}' || echo "N/A")
    NET_IPV6=$(ip -6 addr show dev "$NET_IFACE" 2>/dev/null | awk '/inet6 / {print $2; exit}' || echo "N/A")

    RX1=$(cat "/sys/class/net/$NET_IFACE/statistics/rx_bytes" 2>/dev/null || echo 0)
    TX1=$(cat "/sys/class/net/$NET_IFACE/statistics/tx_bytes" 2>/dev/null || echo 0)
    sleep 0.5
    RX2=$(cat "/sys/class/net/$NET_IFACE/statistics/rx_bytes" 2>/dev/null || echo 0)
    TX2=$(cat "/sys/class/net/$NET_IFACE/statistics/tx_bytes" 2>/dev/null || echo 0)

    RX_DIFF=$((RX2 - RX1))
    TX_DIFF=$((TX2 - TX1))

    NET_RX_MBPS=$(awk "BEGIN { printf \"%.2f\", ($RX_DIFF/1024/1024)/0.5 }")
    NET_TX_MBPS=$(awk "BEGIN { printf \"%.2f\", ($TX_DIFF/1024/1024)/0.5 }")
fi

# ---------- GPU (NVIDIA only, best-effort) ----------
if command -v nvidia-smi >/dev/null 2>&1; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1 || echo "NVIDIA GPU")
    GPU_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 || echo "0")
    GPU_MEM_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -n1 || echo "0")
    GPU_MEM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1 || echo "0")
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 || echo "0")
else
    GPU_NAME="N/A"
    GPU_USAGE="0"
    GPU_MEM_USED="0"
    GPU_MEM_TOTAL="0"
    GPU_TEMP="N/A"
fi

# ---------- Processes ----------
PROC_TOTAL=$(ps -e --no-headers 2>/dev/null | wc -l | tr -d ' ' || echo 0)

PROC_RUNNING=$(ps -eo stat --no-headers 2>/dev/null | awk '
  { s = substr($1,1,1); if (s=="R") c++ }
  END { if (c=="") c=0; print c }')

PROC_SLEEPING=$(ps -eo stat --no-headers 2>/dev/null | awk '
  { s = substr($1,1,1); if (s=="S") c++ }
  END { if (c=="") c=0; print c }')

TOP_PROC_NAME="N/A"
TOP_PROC_CPU="0.0"
TOP_PROC_MEM="0.0"

if ps -eo comm,%cpu,%mem --sort=-%cpu >/dev/null 2>&1; then
    line=$(ps -eo comm,%cpu,%mem --sort=-%cpu | sed -n '2p')
    if [ -n "$line" ]; then
        TOP_PROC_NAME=$(echo "$line" | awk '{print $1}')
        TOP_PROC_CPU=$(echo "$line" | awk '{print $2}')
        TOP_PROC_MEM=$(echo "$line" | awk '{print $3}')
    fi
fi

# ---------- Build sed script ----------
SED_FILE=$(mktemp)

cat > "$SED_FILE" <<EOF
s|\*\*HOSTNAME\*\*|$HOSTNAME|g
s|\*\*LAST_UPDATED\*\*|$LAST_UPDATED|g
s|\*\*GEN_TIMESTAMP\*\*|$GEN_TIMESTAMP|g
s|\*\*HOST_ID\*\*|$HOST_ID|g
s|\*\*UPTIME\*\*|$UPTIME|g
s|\*\*KERNEL_VERSION\*\*|$KERNEL_VERSION|g
s|\*\*DISTRO_NAME\*\*|$DISTRO_NAME|g

s|\*\*CPU_USAGE\*\*|$CPU_USAGE|g
s|\*\*CPU_LOAD_1\*\*|$CPU_LOAD_1|g
s|\*\*CPU_LOAD_5\*\*|$CPU_LOAD_5|g
s|\*\*CPU_LOAD_15\*\*|$CPU_LOAD_15|g
s|\*\*CPU_TEMP\*\*|$CPU_TEMP|g
s|\*\*CPU_CORES\*\*|$CPU_CORES|g
s|\*\*CPU_THREADS\*\*|$CPU_THREADS|g

s|\*\*MEM_USED\*\*|$MEM_USED|g
s|\*\*MEM_TOTAL\*\*|$MEM_TOTAL|g
s|\*\*MEM_USED_PCT\*\*|$MEM_USED_PCT|g
s|\*\*SWAP_USED\*\*|$SWAP_USED|g
s|\*\*SWAP_TOTAL\*\*|$SWAP_TOTAL|g
s|\*\*SWAP_USED_PCT\*\*|$SWAP_USED_PCT|g

s|\*\*DISK_ROOT_USED\*\*|$DISK_ROOT_USED|g
s|\*\*DISK_ROOT_TOTAL\*\*|$DISK_ROOT_TOTAL|g
s|\*\*DISK_ROOT_USED_PCT\*\*|$DISK_ROOT_USED_PCT|g
s|\*\*DISK_ROOT_INODE_PCT\*\*|$DISK_ROOT_INODE_PCT|g
s|\*\*DISK_ROOT_DEVICE\*\*|$DISK_ROOT_DEVICE|g

s|\*\*NET_IFACE\*\*|$NET_IFACE|g
s|\*\*NET_IPV4\*\*|$NET_IPV4|g
s|\*\*NET_IPV6\*\*|$NET_IPV6|g
s|\*\*NET_RX_MBPS\*\*|$NET_RX_MBPS|g
s|\*\*NET_TX_MBPS\*\*|$NET_TX_MBPS|g

s|\*\*GPU_NAME\*\*|$GPU_NAME|g
s|\*\*GPU_USAGE\*\*|$GPU_USAGE|g
s|\*\*GPU_MEM_USED\*\*|$GPU_MEM_USED|g
s|\*\*GPU_MEM_TOTAL\*\*|$GPU_MEM_TOTAL|g
s|\*\*GPU_TEMP\*\*|$GPU_TEMP|g

s|\*\*PROC_TOTAL\*\*|$PROC_TOTAL|g
s|\*\*PROC_RUNNING\*\*|$PROC_RUNNING|g
s|\*\*PROC_SLEEPING\*\*|$PROC_SLEEPING|g
s|\*\*TOP_PROC_NAME\*\*|$TOP_PROC_NAME|g
s|\*\*TOP_PROC_CPU\*\*|$TOP_PROC_CPU|g
s|\*\*TOP_PROC_MEM\*\*|$TOP_PROC_MEM|g
EOF

# ---------- Generate output ----------
sed -f "$SED_FILE" "$TEMPLATE" > "$OUTPUT"
rm -f "$SED_FILE"

echo "Generated: $OUTPUT"

