#!/bin/bash

# --- CONFIGURATION ---
REPO_PATH="/home/nuntawat/mss2025-project-template/Nano"
BRANCH_NAME="nano"
HTML_FILE="Nano.html"
HISTORY_FILE="history_data.csv"
MAX_HISTORY_ENTRIES=5
# ---------------------
# Navigate to Repo once at the start
cd "$REPO_PATH" || exit

echo "Starting Infinite Monitor Loop..."
echo "Press [CTRL+C] to stop."

# ==========================
#    START INFINITE LOOP
# ==========================

    echo "--- [$(date)] Collecting Data... ---"

    # 1. COLLECT DATA
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    SHORT_TIME=$(date "+%H:%M")

    # Memory
    MEM_PERCENT=$(free -m | awk 'NR==2{printf "%.0f", $3*100/$2 }')
    MEM_TEXT=$(free -m | awk 'NR==2{printf "%s/%sMB", $3,$2 }')

    # Disk
    DISK_PERCENT=$(df -h | awk '$NF=="/"{printf "%d", $5}')
    DISK_TEXT=$(df -h | awk '$NF=="/"{printf "%d/%dGB", $3,$2}')

    # CPU
    CPU_LOAD=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}')
    CPU_PERCENT=$(echo "$CPU_LOAD * 20" | bc | awk '{printf "%.0f", $1}')
    if [ "$CPU_PERCENT" -gt 100 ]; then CPU_PERCENT=100; fi


    # 2. HANDLE HISTORY LOGGING
    if [ ! -f "$HISTORY_FILE" ]; then touch "$HISTORY_FILE"; fi

    # Append data
    echo "$SHORT_TIME,$CPU_LOAD,$MEM_PERCENT,$DISK_PERCENT" >> "$HISTORY_FILE"

    # Keep only last 5 lines
    tail -n $MAX_HISTORY_ENTRIES "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"

    # Generate Table Rows
    HISTORY_ROWS=$(awk -F, '{printf "<tr><td>%s</td><td>%s</td><td>%s%%</td><td>%s%%</td></tr>", $1, $2, $3, $4}' "$HISTORY_FILE")


    # 3. GENERATE HTML
    cat > "$HTML_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Matcha Monitor</title>
    <style>
        :root {
            --bg-color: #2b2b2b;
            --card-bg: #363636;
            --matcha-green: #badc58;
            --sakura-pink: #ff9ff3;
            --text-main: #f0f0f0;
            --text-dim: #a0a0a0;
        }
        body {
            background-color: var(--bg-color);
            color: var(--text-main);
            font-family: 'Courier New', Courier, monospace;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }
        h1 { color: var(--sakura-pink); text-transform: uppercase; letter-spacing: 2px; border-bottom: 2px solid var(--matcha-green); padding-bottom: 10px;}
        .timestamp { color: var(--matcha-green); margin-bottom: 30px; font-weight: bold; }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            width: 100%;
            max-width: 800px;
            margin-bottom: 30px;
        }
        .card {
            background-color: var(--card-bg);
            padding: 20px;
            border-radius: 15px;
            text-align: center;
            border: 1px solid var(--matcha-green);
            box-shadow: 0 4px 10px rgba(186, 220, 88, 0.1);
        }
        .icon { font-size: 2em; margin-bottom: 10px; display: block; }
        .stat-value { font-size: 1.8em; font-weight: bold; color: var(--sakura-pink); }
        .stat-label { color: var(--text-dim); font-size: 0.8em; margin-top: 5px;}
        .progress-bg {
            background-color: #555;
            height: 12px;
            border-radius: 10px;
            margin-top: 15px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background-color: var(--matcha-green);
            transition: width 0.5s ease-in-out;
        }
        .history-container {
            width: 100%;
            max-width: 800px;
            background-color: var(--card-bg);
            padding: 20px;
            border-radius: 15px;
            border-top: 4px solid var(--sakura-pink);
        }
        .history-title { color: var(--matcha-green); margin-top: 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { text-align: left; color: var(--sakura-pink); border-bottom: 1px solid #555; padding: 10px; }
        td { padding: 10px; border-bottom: 1px solid #444; color: var(--text-dim); }
        tr:last-child td { border-bottom: none; }
    </style>
</head>
<body>
    <h1>🌸 Server Monitor 🍵</h1>
    <div class="timestamp">Updated: $TIMESTAMP</div>
    <div class="dashboard-grid">
        <div class="card">
            <span class="icon">🧠</span>
            <div class="stat-value">$MEM_PERCENT%</div>
            <div class="stat-label">$MEM_TEXT</div>
            <div class="progress-bg"><div class="progress-fill" style="width: ${MEM_PERCENT}%;"></div></div>
        </div>
        <div class="card">
            <span class="icon">💾</span>
            <div class="stat-value">$DISK_PERCENT%</div>
            <div class="stat-label">$DISK_TEXT</div>
            <div class="progress-bg"><div class="progress-fill" style="width: ${DISK_PERCENT}%;"></div></div>
        </div>
        <div class="card">
            <span class="icon">⚙️</span>
            <div class="stat-value">$CPU_LOAD</div>
            <div class="stat-label">Avg Load</div>
            <div class="progress-bg"><div class="progress-fill" style="width: ${CPU_PERCENT}%;"></div></div>
        </div>
    </div>
    <div class="history-container">
        <h3 class="history-title">⏳ Last 5 Updates</h3>
        <table>
            <thead><tr><th>Time</th><th>CPU Load</th><th>RAM %</th><th>Disk %</th></tr></thead>
            <tbody>$HISTORY_ROWS</tbody>
        </table>
    </div>
</body>
</html>
EOF

    # 4. PUSH TO GITHUB
    #echo "--- Pushing to GitHub ---"
    #git add "$HTML_FILE" "$HISTORY_FILE"
    #git commit -m "Auto-update stats: $TIMESTAMP"
    #git push origin "$BRANCH_NAME"

    # 5. WAIT FOR NEXT CYCLE
    echo "--- Done. Waiting $SLEEP_INTERVAL seconds... ---"
    sleep "$SLEEP_INTERVAL"

