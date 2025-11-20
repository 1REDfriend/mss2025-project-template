#!/bin/bash

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' )
Last_Update=$(date +"%Y-%m-%d %H:%M:%S")
KERNEL=$(uname -r)
OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
UPTIME=$(uptime -p)
HOSTNAME=$(hostname)
CPU_MODEL=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)

cat <<EOF > student3.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Information Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 24px;
            padding: 40px;
            max-width: 1000px;
            width: 100%;
            box-shadow: 
                0 20px 60px rgba(0, 0, 0, 0.08),
                0 0 0 1px rgba(0, 0, 0, 0.02);
            backdrop-filter: blur(20px);
        }

        .header {
            text-align: center;
            margin-bottom: 40px;
            padding-bottom: 24px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.06);
        }

        .header h1 {
            color: #1a1a1a;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
        }

        .header .subtitle {
            color: #6b7280;
            font-size: 0.95rem;
            font-weight: 500;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }

        .info-card {
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, 0.06);
            border-radius: 16px;
            padding: 24px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .info-card:hover {
            transform: translateY(-4px);
            box-shadow: 
                0 12px 24px rgba(0, 0, 0, 0.06),
                0 0 0 1px rgba(0, 0, 0, 0.02);
        }

        .info-label {
            color: #6b7280;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-value {
            color: #1a1a1a;
            font-size: 1.1rem;
            font-weight: 500;
            word-break: break-word;
            line-height: 1.5;
        }

        .progress-card {
            position: relative;
        }

        .progress-wrapper {
            margin-top: 16px;
        }

        .progress-bar-container {
            width: 100%;
            height: 32px;
            background: #f3f4f6;
            border-radius: 16px;
            overflow: hidden;
            position: relative;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.04);
        }

        .progress-bar {
            height: 100%;
            transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            background: linear-gradient(90deg, 
                var(--bar-color-start) 0%, 
                var(--bar-color-end) 100%);
            border-radius: 16px;
            box-shadow: 
                0 2px 8px var(--bar-shadow);
        }

        .progress-text {
            position: absolute;
            top: 50%;
            right: 16px;
            transform: translateY(-50%);
            color: #1a1a1a;
            font-size: 0.85rem;
            font-weight: 700;
            z-index: 1;
        }

        .cpu-card { 
            --bar-color-start: #3b82f6; 
            --bar-color-end: #2563eb;
            --bar-shadow: rgba(59, 130, 246, 0.3);
        }
        
        .mem-card { 
            --bar-color-start: #10b981; 
            --bar-color-end: #059669;
            --bar-shadow: rgba(16, 185, 129, 0.3);
        }
        
        .disk-card { 
            --bar-color-start: #8b5cf6; 
            --bar-color-end: #7c3aed;
            --bar-shadow: rgba(139, 92, 246, 0.3);
        }

        .cpu-card .info-label { color: #3b82f6; }
        .mem-card .info-label { color: #10b981; }
        .disk-card .info-label { color: #8b5cf6; }

        .timestamp {
            background: linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%);
            border: 1px solid rgba(0, 0, 0, 0.06);
            border-radius: 16px;
            padding: 24px;
            text-align: center;
        }

        .timestamp .info-label {
            color: #6b7280;
            margin-bottom: 8px;
            font-size: 0.85rem;
            justify-content: center;
        }

        .timestamp .info-value {
            color: #1a1a1a;
            font-size: 1rem;
            font-weight: 600;
        }

        .footer {
            margin-top: 32px;
            text-align: center;
            color: #9ca3af;
            font-size: 0.8rem;
            padding-top: 24px;
            border-top: 1px solid rgba(0, 0, 0, 0.06);
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Server Monitor</h1>
            <div class="subtitle">Real-time System</div>
        </div>

        <div class="info-grid">
            <div class="info-card progress-card cpu-card">
                <div class="info-label">CPU Usage</div>
                <div class="progress-wrapper">
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: ${CPU_USAGE}%"></div>
                        <div class="progress-text">${CPU_USAGE}%</div>
                    </div>
                </div>
            </div>

            <div class="info-card progress-card mem-card">
                <div class="info-label">Memory Usage</div>
                <div class="progress-wrapper">
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: ${MEM_USAGE}%"></div>
                        <div class="progress-text">${MEM_USAGE}%</div>
                    </div>
                </div>
            </div>

            <div class="info-card progress-card disk-card">
                <div class="info-label">Disk Usage</div>
                <div class="progress-wrapper">
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: ${DISK_USAGE}"></div>
                        <div class="progress-text">${DISK_USAGE}</div>
                    </div>
                </div>
            </div>

            <div class="info-card">
                <div class="info-label">Hostname</div>
                <div class="info-value">${HOSTNAME}</div>
            </div>

            <div class="info-card">
                <div class="info-label">Operating System</div>
                <div class="info-value">${OS}</div>
            </div>

            <div class="info-card">
                <div class="info-label">Kernel Version</div>
                <div class="info-value">${KERNEL}</div>
            </div>

            <div class="info-card">
                <div class="info-label">Uptime</div>
                <div class="info-value">${UPTIME}</div>
            </div>

            <div class="info-card">
                <div class="info-label">CPU Model</div>
                <div class="info-value">${CPU_MODEL}</div>
            </div>
        </div>

        <div class="timestamp">
            <div class="info-label">Last Updated</div>
            <div class="info-value">${Last_Update}</div>
        </div>
    </div>
</body>
</html>
EOF


