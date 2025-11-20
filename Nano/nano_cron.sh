#!/bin/bash

cd /home/nuntawt/mss2025-project-template/Nano

git checkout nano

./Student4_script.sh

git add .

git commit -m "Auto Update: $(date '+%Y-%m-%d %H:%M:%S')"

git push origin nano
