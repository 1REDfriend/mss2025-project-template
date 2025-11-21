
#!/bin/bash
cd /home/pitch/mss2025-project-template/Pitch
OUTPUT="/home/pitch/mss2025-project-template/Pitch/Pitch.html"
cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}') 
cpu_usage=$(echo "100 - $cpu_idle" | bc)
cpu_usage_int=${cpu_usage%.*} 

mem_total=$(free -m | awk '/Mem:/ {print $2}')
mem_used=$(free -m | awk '/Mem:/ {print $3}')
mem_percent=$(( 100 * mem_used / mem_total ))

disk_avaliable=$(df -h / | awk 'NR==2 {print $2}')
disk_usage=$(df -h / | awk 'NR==2 {print $3}')
disk_percent=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

DISK=$(df -h / | awk 'NR==2{print $3" used of "$2" ("$5")"}')
UPTIME=$(uptime -p)
LOAD_AVG=$(uptime | awk -F"load average:" '{print $2}')
OS=$(awk -F\" '/^PRETTY_NAME=/{print $2}' /etc/os-release)
HOST=$(hostnamectl | awk -F': ' '/Static hostname/ {print $2}')
KERNEL=$(hostnamectl | awk -F': ' '/Kernel/ {print $2}')
ARCHITECTURE=$(hostnamectl | awk -F': ' '/Architecture/ {print $2}')

TOP_PROCESSES=$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 11)

if [ "$cpu_usage_int" -lt 20 ]; then
    CPU_STATUS="Normal"
    CPU_STATUS_CLASS="status-normal"
elif [ "$cpu_usage_int" -lt 80 ]; then
    CPU_STATUS="Medium"
    CPU_STATUS_CLASS="status-warning"
else
    CPU_STATUS="Risk"
    CPU_STATUS_CLASS="status-critical"
fi

if [ "$mem_percent" -lt 20 ]; then
    MEM_STATUS="Normal"
    MEM_STATUS_CLASS="status-normal"
elif [ "$mem_percent" -lt 80 ]; then
    MEM_STATUS="Medium"
    MEM_STATUS_CLASS="status-warning"
else
    MEM_STATUS="Risk"
    MEM_STATUS_CLASS="status-critical"
fi

if [ "$disk_percent" -lt 20 ]; then
    DISK_STATUS="Normal"
    DISK_STATUS_CLASS="status-normal"
elif [ "$disk_percent" -lt 80 ]; then
    DISK_STATUS="Medium"
    DISK_STATUS_CLASS="status-warning"
else
    DISK_STATUS="Risk"
    DISK_STATUS_CLASS="status-critical"
fi

LAST_UPDATE=$(dimedatectl | awk '/Local time:/ {print$3 " " $4}')

cat <<EOF > "$OUTPUT"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="refresh" content="10">
<title>Server Status Dashboard</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background: #fafafa; color: #262626; padding: 2rem; line-height: 1.6; }
.container { max-width: 1200px; margin: 0 auto; }
.header { margin-bottom: 3rem; padding-bottom: 1.5rem; border-bottom: 1px solid #e5e5e5; }
.header h1 { font-size: 2.5rem; font-weight: 700; color: #171717; margin-bottom: 0.5rem; }
.header p { font-size: 1rem; color: #737373; }
.metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
.metric-card { background: white; border: 1px solid #e5e5e5; border-radius: 12px; padding: 1.5rem; transition: all 0.3s ease; }
.metric-card:hover { box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); transform: translateY(-2px); }
.metric-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.25rem; }
.metric-label { font-size: 1.125rem; font-weight: 600; color: #171717; margin-bottom: 0.25rem; }
.metric-description { font-size: 0.875rem; color: #737373; }
.metric-value { font-size: 2rem; font-weight: 700; color: #171717; line-height: 1; }
.metric-status { font-size: 0.75rem; font-weight: 600; margin-top: 0.5rem; text-transform: uppercase; letter-spacing: 0.05em; }
.status-normal { color: #16a34a; }
.status-warning { color: #ea580c; }
.status-critical { color: #dc2626; }
.progress-bar { width: 100%; height: 12px; background: #f5f5f5; border-radius: 9999px; overflow: hidden; position: relative; }
.progress-fill { height: 100%; border-radius: 9999px; transition: width 0.7s cubic-bezier(0.4, 0, 0.2, 1); position: relative; }
.progress-cpu { background: #10b981; }
.progress-memory { background: #8b5cf6; }
.progress-disk { background: #22c55e; }
.system-info { background: white; border: 1px solid #e5e5e5; border-radius: 12px; padding: 1.5rem; margin-bottom: 2rem; }
.system-info h2 { font-size: 1.25rem; font-weight: 600; color: #171717; margin-bottom: 1.5rem; }
.info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; }
.info-item { display: flex; flex-direction: column; gap: 0.5rem; }
.info-label { font-size: 0.75rem; font-weight: 600; color: #737373; text-transform: uppercase; letter-spacing: 0.05em; }
.info-value { font-size: 0.875rem; font-weight: 500; color: #171717; }
.footer { text-align: center; padding: 1.5rem; color: #737373; font-size: 0.875rem; }
@media (max-width: 768px) { body { padding: 1rem; } .header h1 { font-size: 1.875rem; } .metrics-grid { grid-template-columns: 1fr; } .info-grid { grid-template-columns: 1fr; } }
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <h1>Server Status Dashboard</h1>
    <p>Real-time monitoring and system metrics</p>
  </div>

  <div class="metrics-grid">
    <!-- CPU Metric -->
    <div class="metric-card">
      <div class="metric-header">
        <div><div class="metric-label">CPU Usage</div></div>
        <div style="text-align: right;">
          <div class="metric-value">$cpu_usage_int%</div>
          <div class="metric-status $CPU_STATUS_CLASS">$CPU_STATUS</div>
        </div>
      </div>
      <div class="progress-bar">
        <div class="progress-fill progress-cpu" style="width: $cpu_usage_int%"></div>
      </div>
    </div>

    <!-- Memory Metric -->
    <div class="metric-card">
      <div class="metric-header">
        <div>
          <div class="metric-label">Memory Usage</div>
          <div class="metric-description">$mem_used MB / $mem_total MB</div>
        </div>
        <div style="text-align: right;">
          <div class="metric-value">$mem_percent%</div>
          <div class="metric-status $MEM_STATUS_CLASS">$MEM_STATUS</div>
        </div>
      </div>
      <div class="progress-bar">
        <div class="progress-fill progress-memory" style="width: $mem_percent%"></div>
      </div>
    </div>

    <!-- Disk Metric -->
    <div class="metric-card">
      <div class="metric-header">
        <div>
          <div class="metric-label">Disk Usage</div>
          <div class="metric-description">$disk_usage / $disk_avaliable</div>
        </div>
        <div style="text-align: right;">
          <div class="metric-value">$disk_percent%</div>
          <div class="metric-status $DISK_STATUS_CLASS">$DISK_STATUS</div>
        </div>
      </div>
      <div class="progress-bar">
        <div class="progress-fill progress-disk" style="width: $disk_percent%"></div>
      </div>
    </div>
  </div>

  <div class="system-info">
    <h2>System Information</h2>
    <div class="info-grid">
      <div class="info-item"><div class="info-label">Operating System</div><div class="info-value">$OS</div></div>
      <div class="info-item"><div class="info-label">Hostname</div><div class="info-value">$HOST</div></div>
      <div class="info-item"><div class="info-label">Kernel</div><div class="info-value">$KERNEL</div></div>
      <div class="info-item"><div class="info-label">Architecture</div><div class="info-value">$ARCHITECTURE</div></div>
      <div class="info-item"><div class="info-label">Uptime</div><div class="info-value">$UPTIME</div></div>
      <div class="info-item"><div class="info-label">Load Average</div><div class="info-value">$LOAD_AVG</div></div>
    </div>
  </div>

  <div class="footer">Last updated: $LAST_UPDATE</div>
</div>

<pre> $TOP_PROCESSES </pre>
</body>
</html>
EOF

