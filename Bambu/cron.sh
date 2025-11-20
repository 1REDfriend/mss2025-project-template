#!/bin/bash

git checkout bambu

cd /home/bambu/mss2025-project-template/Bambu/

./script.sh

cd /home/bambu/mss2025-project-template/

git add .

git commit -m "Auto Update: $(date '+%Y-%m-%d %H:%M:%S')"

git push origin bambu
