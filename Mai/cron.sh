#!/bin/bash
export HOME=/home/sarojphan

/usr/bin/git config --global --add safe.directory /home/sarojphan/mss2025-project-template

cd /home/sarojphan/mss2025-project-template/Mai
./student4_script.sh

cd /home/sarojphan/mss2025-project-template
/usr/bin/git add .
/usr/bin/git commit -m "Auto Update: $(date '+%Y-%m-%d %H:%M:%S')"
/usr/bin/git push origin Mai

