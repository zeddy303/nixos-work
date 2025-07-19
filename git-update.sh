#!/run/current-system/sw/bin/bash
cd /etc/nixos
git add .
git commit -m "Auto-update after nixos-rebuild at $(date)"
git push origin main

