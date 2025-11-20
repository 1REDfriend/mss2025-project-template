#!/bin/bash

cd /home/bambu/mss2025-project-template/Bambu/
git checkout bambu
./script.sh
git add .

git commit -m "Auto Update: $(date '+%Y-%m-%d %H:%M:%S')"

git push origin bambu
