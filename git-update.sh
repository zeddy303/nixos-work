#!/run/current-system/sw/bin/bash
cd /etc/nixos
/run/current-system/sw/bin/git add .
/run/current-system/sw/bin/git commit -m "Auto-update after nixos-rebuild at $(date)"
/run/current-system/sw/bin/git push origin main

