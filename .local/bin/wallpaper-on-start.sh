#!/bin/bash
ASSETS="/mnt/ssd/SteamLibrary/steamapps/common/wallpaper_engine/assets"
WORKSHOP="/mnt/ssd/SteamLibrary/steamapps/workshop/content/431960"
STATE="$HOME/.config/wallpaperengine/last_wallpaper.json"

[ ! -f "$STATE" ] && exit 0

mode=$(jq -r '.mode // "span"' "$STATE")
dp1=$(jq -r  '.dp1  // empty' "$STATE")
dp3=$(jq -r  '.dp3  // empty' "$STATE")

if [ "$mode" = "span" ]; then
  [ -z "$dp1" ] || [ ! -d "$WORKSHOP/$dp1" ] && exit 0
  systemd-run --user --unit=wallpaperengine \
    linux-wallpaperengine \
    --silent --fps 30 --disable-mouse \
    --assets-dir "$ASSETS" \
    --scaling fill --screen-span DP-1,DP-3 \
    --bg "$WORKSHOP/$dp1/"
else
  CMD=(linux-wallpaperengine --silent --fps 30 --disable-mouse --assets-dir "$ASSETS")
  [ -n "$dp1" ] && [ -d "$WORKSHOP/$dp1" ] && CMD+=(--scaling fill --screen-root DP-1 --bg "$WORKSHOP/$dp1/")
  [ -n "$dp3" ] && [ -d "$WORKSHOP/$dp3" ] && CMD+=(--scaling fill --screen-root DP-3 --bg "$WORKSHOP/$dp3/")
  [ ${#CMD[@]} -eq 5 ] && exit 0  # solo el base, sin monitores
  systemd-run --user --unit=wallpaperengine "${CMD[@]}"
fi
