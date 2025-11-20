#!/bin/bash

# ==========================================
# System Monitor Generator (White Theme)
# ==========================================

# --- 1. Get System Data ---
LAST_UPDATED=$(LC_TIME=C date "+%d %b %Y %H:%M:%S")

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
# Fetching PID, USER, CPU, MEM, COMMAND
PROCESS_ROWS=""
raw_ps=$(ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6 | tail -n 5)

while read -r line; do
    pid=$(echo $line | awk '{print $1}')
    user=$(echo $line | awk '{print $2}')
    cpu=$(echo $line | awk '{print $3}')
    mem=$(echo $line | awk '{print $4}')
    cmd=$(echo $line | awk '{print $5}')
    
    PROCESS_ROWS+="<tr>
        <td><span class='pid-tag'>$pid</span></td>
        <td style='font-weight:bold;'>$user</td>
        <td class='text-pink'>$cpu%</td>
        <td class='text-orange'>$mem%</td>
        <td class='text-blue'>$cmd</td>
    </tr>"
done <<< "$raw_ps"

# --- 3. Generate HTML ---
OUTPUT_FILE="index.html"

cat <<EOF > $OUTPUT_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Monitor</title>
    <style>
        /* --- VARIABLES --- */
        :root {
            --bg-color: #f4f7f6;
            --card-bg: #ffffff;
            --text-main: #333333;
            --text-sub: #777777;
            --accent-pink: #ff2e63;
            --accent-orange: #ff9f1c;
            --accent-blue: #00d2fc;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            margin: 0;
            padding: 40px;
            display: flex;
            justify-content: center;
        }

        .container {
            width: 100%;
            max-width: 900px;
        }

        /* --- HEADER --- */
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        h1 { margin: 0; font-weight: 800; letter-spacing: -1px; color: #222; }
        .update-time { font-size: 0.9rem; color: var(--text-sub); background: #e0e0e0; padding: 5px 12px; border-radius: 20px; }

        /* --- METRIC CARDS --- */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .card {
            background: var(--card-bg);
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            transition: transform 0.2s;
            position: relative;
            overflow: hidden;
        }
        .card:hover { transform: translateY(-5px); }

        /* Colorful Top Borders */
        .card.pink { border-top: 5px solid var(--accent-pink); }
        .card.orange { border-top: 5px solid var(--accent-orange); }
        .card.blue { border-top: 5px solid var(--accent-blue); }

        .card h3 { margin: 0 0 10px 0; font-size: 0.9rem; text-transform: uppercase; color: var(--text-sub); letter-spacing: 1px; }
        .big-value { font-size: 3rem; font-weight: 800; margin: 5px 0; }
        .sub-value { font-size: 0.85rem; color: var(--text-sub); margin-bottom: 15px; }

        /* Progress Bars */
        .progress-track { width: 100%; height: 8px; background: #eee; border-radius: 4px; overflow: hidden; }
        .progress-fill { height: 100%; border-radius: 4px; }
        
        /* Colors */
        .text-pink { color: var(--accent-pink); }
        .text-orange { color: var(--accent-orange); }
        .text-blue { color: var(--accent-blue); }
        .bg-pink { background-color: var(--accent-pink); }
        .bg-orange { background-color: var(--accent-orange); }
        .bg-blue { background-color: var(--accent-blue); }

        /* --- TABLE --- */
        .table-container {
            background: var(--card-bg);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
        }
        .table-title { margin: 0 0 20px 0; font-size: 1.2rem; font-weight: 700; }
        
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; color: var(--text-sub); font-size: 0.8rem; padding: 10px; border-bottom: 2px solid #eee; }
        td { padding: 15px 10px; border-bottom: 1px solid #f0f0f0; font-size: 0.95rem; }
        tr:last-child td { border-bottom: none; }
        
        .pid-tag { background: #eee; padding: 3px 8px; border-radius: 5px; font-size: 0.8rem; font-weight: bold; color: #555; }
    </style>
</head>
<body>

    <div class="container">
        <header>
            <h1>System Status</h1>
            <div class="update-time">Updated: $LAST_UPDATED</div>
        </header>

        <div class="grid">
            <!-- CPU -->
            <div class="card pink">
                <h3>CPU Usage</h3>
                <div class="big-value text-pink">$CPU_LOAD%</div>
                <div class="progress-track">
                    <div class="progress-fill bg-pink" style="width: ${CPU_LOAD}%"></div>
                </div>
            </div>

            <!-- MEMORY -->
            <div class="card orange">
                <h3>Memory</h3>
                <div class="big-value text-orange">$MEM_PERCENT%</div>
                <div class="sub-value">$MEM_USED MB / $MEM_TOTAL MB</div>
                <div class="progress-track">
                    <div class="progress-fill bg-orange" style="width: ${MEM_PERCENT}%"></div>
                </div>
            </div>

            <!-- STORAGE -->
            <div class="card blue">
                <h3>Disk (/)</h3>
                <div class="big-value text-blue">$DISK_PERCENT%</div>
                <div class="sub-value">$DISK_USED / $DISK_TOTAL Used</div>
                <div class="progress-track">
                    <div class="progress-fill bg-blue" style="width: ${DISK_PERCENT}%"></div>
                </div>
            </div>
        </div>

        <div class="table-container">
            <h2 class="table-title">Top Processes</h2>
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

echo "Dashboard generated: $OUTPUT_FILE"
