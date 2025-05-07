#!/usr/bin/env bash

### CONFIGURATION ###
SCHEDULE_FILE="$HOME/signage-cron/signage_cron_schedule.txt"
LAST_URL_FILE="$HOME/signage-cron/signage_cron_last_url.txt"
CHROMIUM_BIN="chromium-browser"
CHROMIUM_FLAGS="
  --kiosk
  --incognito
  --noerrdialogs
  --disable-infobars
  --disable-session-crashed-bubble
  --disable-translate
  --disable-features=Translate
  --no-first-run
"

### READ SCHEDULE ###
urls=()
durations=()
while read -r url mins; do
  [[ -z "$url" || "$url" =~ ^# ]] && continue
  urls+=("$url")
  durations+=("$mins")
done < "$SCHEDULE_FILE"

### COMPUTE CYCLE POSITION ###
total=0
for d in "${durations[@]}"; do
  total=$(( total + d ))
done

now_sec=$(date +%s)
now_min=$(( now_sec / 60 ))
pos=$(( now_min % total ))

### PICK CURRENT URL ###
elapsed=0
for i in "${!urls[@]}"; do
  elapsed=$(( elapsed + durations[i] ))
  if (( pos < elapsed )); then
    active_url="${urls[i]}"
    break
  fi
done

### LAUNCH OR ROTATE ###
last_url=""
[[ -f "$LAST_URL_FILE" ]] && last_url=$(<"$LAST_URL_FILE")

if ! pgrep -f "$CHROMIUM_BIN" >/dev/null; then
  last_url=""
fi

if [[ "$active_url" != "$last_url" ]]; then
  pkill -f "$CHROMIUM_BIN"
  $CHROMIUM_BIN $CHROMIUM_FLAGS "$active_url" &
  echo "$active_url" > "$LAST_URL_FILE"
fi
