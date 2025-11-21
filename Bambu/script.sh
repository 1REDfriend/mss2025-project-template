#!/bin/bash
cd /home/bambu/mss2025-project-template/Bambu

# ==========================================
# System Monitor Generator (Sakura Theme v2)
# ==========================================

# --- 1. Get System Data ---
LAST_UPDATED=$(LC_TIME=C date "+%d %b %Y %H:%M:%S")

# [NEW] Machine Information
HOST_NAME=$(hostname)
# ดึงชื่อ OS แบบสวยๆ จาก /etc/os-release
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$PRETTY_NAME
else
    OS_NAME=$(uname -o)
fi
KERNEL_VER=$(uname -r)
UPTIME_STR=$(uptime -p | sed 's/up //') # ลบคำว่า up ออกเพื่อให้สั้นลง
CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo | awk -F: '{print $2}' | sed 's/^[ \t]*//')

# CPU Calculation
CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - int($1)}' )

# Memory Calculation
MEM_TOTAL=$(free -m | awk 'NR==2{print $2}')
MEM_USED=$(free -m | awk 'NR==2{print $3}')
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))

# Disk Calculation (Root /)
DISK_TOTAL=$(df -h / | awk '$NF=="/"{print $2}')
DISK_USED=$(df -h / | awk '$NF=="/"{print $3}')
DISK_PERCENT=$(df -h / | awk '$NF=="/"{gsub(/%/,"",$5); print $5}')

# --- 2. Get Top 5 Processes ---
PROCESS_ROWS=""
raw_ps=$(ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6 | tail -n 5)

while read -r line; do
    pid=$(echo $line | awk '{print $1}')
    user=$(echo $line | awk '{print $2}')
    cpu=$(echo $line | awk '{print $3}')
    mem=$(echo $line | awk '{print $4}')
    cmd=$(echo $line | awk '{print $5}')
    
    PROCESS_ROWS+="<tr>
        <td><span class='pid-badge'>$pid</span></td>
        <td style='font-weight:600; color:#555;'>$user</td>
        <td class='text-sakura-dark'>$cpu%</td>
        <td class='text-sakura'>$mem%</td>
        <td style='color:#888;'>$cmd</td>
    </tr>"
done <<< "$raw_ps"

# --- 3. Generate HTML ---
OUTPUT_FILE="Bambu.html"

cat <<EOF > $OUTPUT_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sakura System Monitor</title>
    <style>
        /* --- VARIABLES --- */
        :root {
            --bg-gradient: linear-gradient(135deg, #fff0f5 0%, #ffe4e1 100%);
            --card-bg: #ffffff;
            --text-main: #5d4037; 
            --sakura-light: #ffb7b2;
            --sakura-main: #ff9aa2;
            --sakura-dark: #ff6f91;
            --sakura-accent: #c34a36;
        }

        body {
            font-family: 'Nunito', 'Segoe UI', sans-serif;
            background: var(--bg-gradient);
            color: var(--text-main);
            margin: 0;
            padding: 40px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
        }

        .container {
            width: 100%;
            max-width: 900px;
            background-color: rgba(255, 255, 255, 0.6);
            backdrop-filter: blur(10px);
            padding: 30px;
            border-radius: 25px;
            box-shadow: 0 15px 35px rgba(255, 183, 178, 0.2);
            border: 1px solid #fff;
        }

        /* --- HEADER --- */
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px dashed var(--sakura-light);
        }
        h1 { 
            margin: 0; 
            font-weight: 800; 
            color: var(--sakura-dark); 
            font-size: 1.8rem;
        }
        h1 span { font-size: 1.5rem; }
        
        .update-time { 
            font-size: 0.85rem; 
            color: #fff; 
            background: var(--sakura-main); 
            padding: 6px 15px; 
            border-radius: 20px; 
            box-shadow: 0 4px 10px rgba(255, 154, 162, 0.4);
        }

        /* --- NEW: INFO BAR --- */
        .info-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 30px;
            justify-content: center;
        }
        .info-pill {
            background: #fff;
            padding: 8px 15px;
            border-radius: 50px;
            font-size: 0.85rem;
            color: #666;
            border: 1px solid #ffecec;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.02);
        }
        .info-pill strong { color: var(--sakura-dark); }
        .icon { font-style: normal; }

        /* --- METRIC CARDS --- */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 35px;
        }

        .card {
            background: var(--card-bg);
            padding: 25px;
            border-radius: 20px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.03);
            transition: transform 0.3s ease;
            text-align: center;
            border: 1px solid #ffecec;
        }
        .card:hover { transform: translateY(-5px); box-shadow: 0 12px 25px rgba(255, 111, 145, 0.15); }

        .card h3 { margin: 0 0 15px 0; font-size: 1rem; color: #888; font-weight: 600; }
        
        .big-value { 
            font-size: 3rem; 
            font-weight: 800; 
            margin: 0; 
            background: -webkit-linear-gradient(45deg, var(--sakura-dark), var(--sakura-main));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .sub-value { font-size: 0.9rem; color: #aaa; margin-bottom: 20px; }

        /* Progress Bar */
        .progress-track { 
            width: 100%; 
            height: 10px; 
            background: #ffe6e9; 
            border-radius: 10px; 
            overflow: hidden; 
        }
        .progress-fill { height: 100%; border-radius: 10px; transition: width 1s ease; }
        
        .fill-1 { background: linear-gradient(90deg, #ff9a9e 0%, #fecfef 99%); }
        .fill-2 { background: linear-gradient(90deg, #a18cd1 0%, #fbc2eb 100%); }
        .fill-3 { background: linear-gradient(90deg, #fbc2eb 0%, #a6c1ee 100%); }

        /* --- TABLE --- */
        .table-container {
            background: #fff;
            padding: 25px;
            border-radius: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.02);
        }
        .table-title { 
            margin: 0 0 15px 0; 
            font-size: 1.2rem; 
            color: var(--text-main);
            border-left: 5px solid var(--sakura-main);
            padding-left: 10px;
        }
        
        table { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
        th { text-align: left; color: #999; font-size: 0.8rem; padding: 0 15px; font-weight: 600; }
        td { background: #fffbfc; padding: 15px; border-top: 1px solid #fff0f5; border-bottom: 1px solid #fff0f5; }
        td:first-child { border-top-left-radius: 10px; border-bottom-left-radius: 10px; border-left: 1px solid #fff0f5; }
        td:last-child { border-top-right-radius: 10px; border-bottom-right-radius: 10px; border-right: 1px solid #fff0f5; }
        
        .pid-badge { 
            background: #ffe4e1; 
            color: var(--sakura-accent); 
            padding: 4px 10px; 
            border-radius: 12px; 
            font-size: 0.75rem; 
            font-weight: bold; 
        }
        .text-sakura { color: var(--sakura-main); font-weight: bold; }
        .text-sakura-dark { color: var(--sakura-dark); font-weight: bold; }

    </style>
</head>
<body>

    <div class="container">
        <header>
            <h1><span>🌸</span> System Status</h1>
            <div class="update-time">$LAST_UPDATED</div>
        </header>

        <div class="info-bar">
            <div class="info-pill">
                <span class="icon">💻</span> <strong>Host:</strong> $HOST_NAME
            </div>
            <div class="info-pill">
                <span class="icon">🐧</span> <strong>OS:</strong> $OS_NAME
            </div>
            <div class="info-pill">
                <span class="icon">⚙️</span> <strong>Kernel:</strong> $KERNEL_VER
            </div>
            <div class="info-pill">
                <span class="icon">🧠</span> <strong>CPU:</strong> $CPU_MODEL
            </div>
            <div class="info-pill">
                <span class="icon">⏱️</span> <strong>Uptime:</strong> $UPTIME_STR
            </div>
        </div>

        <div class="grid">
            <div class="card">
                <h3>CPU Usage</h3>
                <div class="big-value">$CPU_LOAD%</div>
                <div class="sub-value">Processing Power</div>
                <div class="progress-track">
                    <div class="progress-fill fill-1" style="width: ${CPU_LOAD}%"></div>
                </div>
            </div>

            <div class="card">
                <h3>Memory</h3>
                <div class="big-value">$MEM_PERCENT%</div>
                <div class="sub-value">$MEM_USED MB / $MEM_TOTAL MB</div>
                <div class="progress-track">
                    <div class="progress-fill fill-2" style="width: ${MEM_PERCENT}%"></div>
                </div>
            </div>

            <div class="card">
                <h3>Disk (Root)</h3>
                <div class="big-value">$DISK_PERCENT%</div>
                <div class="sub-value">$DISK_USED / $DISK_TOTAL Used</div>
                <div class="progress-track">
                    <div class="progress-fill fill-3" style="width: ${DISK_PERCENT}%"></div>
                </div>
            </div>
        </div>

        <div class="table-container">
            <h2 class="table-title">Active Processes</h2>
            <table>
                <thead>
                    <tr>
                        <th>PID</th>
                        <th>USER</th>
                        <th>CPU</th>
                        <th>MEM</th>
                        <th>COMMAND</th>
                    </tr>
                </thead>
                <tbody>
                    $PROCESS_ROWS
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>
EOF

echo "Sakura Dashboard (with System Info) generated: $OUTPUT_FILE"
