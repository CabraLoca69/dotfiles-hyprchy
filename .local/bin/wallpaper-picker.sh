#!/bin/bash
ASSETS="/mnt/ssd/SteamLibrary/steamapps/common/wallpaper_engine/assets"
WORKSHOP="/mnt/ssd/SteamLibrary/steamapps/workshop/content/431960"
STATE_DIR="$HOME/.config/wallpaperengine"
STATE="$STATE_DIR/last_wallpaper.json"
mkdir -p "$STATE_DIR"

[ ! -f "$STATE" ] && echo '{"mode":"span","dp1":"","dp3":""}' > "$STATE"

TARGET=$(printf 'Ambos (span)\nDP-1 (izquierdo)\nDP-3 (derecho)\nReset servicio (reset-failed)\nReiniciar wallpaper' | fzf --prompt="Acción > ")
[ -z "$TARGET" ] && exit 0

# Reset rápido, sin elegir wallpaper
if [ "$TARGET" = "Reset servicio (reset-failed)" ]; then
  systemctl --user reset-failed wallpaperengine.service
  echo "✓ Servicio reseteado"
  exit 0
fi

#resetar el wallpaper 
if [ "$TARGET" = "Reiniciar wallpaper" ]; then
  bash .local/bin/wallpaper-on-start.sh
  echo "wallpaper reseteado"
  exit 0
fi

selected=$(for dir in "$WORKSHOP"/*/; do
  id=$(basename "$dir")
  title=$(jq -r '.title // "sin título"' "$dir/project.json" 2>/dev/null)
  echo "$id -> $title"
done | fzf --prompt="Wallpaper > " | cut -d' ' -f1)
[ -z "$selected" ] && exit 0

current=$(cat "$STATE")
case "$TARGET" in
  "Ambos (span)")
    new_state=$(echo "$current" | jq --arg id "$selected" '{mode:"span", dp1:$id, dp3:$id}')
    ;;
  "DP-1 (izquierdo)")
    new_state=$(echo "$current" | jq --arg id "$selected" '.mode="independent" | .dp1=$id')
    ;;
  "DP-3 (derecho)")
    new_state=$(echo "$current" | jq --arg id "$selected" '.mode="independent" | .dp3=$id')
    ;;
esac
echo "$new_state" > "$STATE"

systemctl --user stop wallpaperengine.service 2>/dev/null
sleep 0.3

mode=$(echo "$new_state" | jq -r '.mode')
dp1=$(echo "$new_state"  | jq -r '.dp1')
dp3=$(echo "$new_state"  | jq -r '.dp3')

if [ "$mode" = "span" ]; then
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
  systemd-run --user --unit=wallpaperengine "${CMD[@]}"
fi

echo "✓ Wallpaper aplicado en: $TARGET"
