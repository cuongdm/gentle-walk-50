#!/bin/zsh
# Captures screenshot states with the single capture hook (-ScreenshotMode <state>).
# Usage: iOS/scripts/capture_states.sh <out-dir> <device-name> <state> [state ...]
#   Suffixes: "<state>@dark" switches to dark mode, "<state>@xxl" to the largest accessibility text.
# The app must already be built into /tmp/gw-dd (see the BUILD command in the plan).
set -u
out="$1"; device="$2"; shift 2
app="/tmp/gw-dd/Build/Products/Debug-iphonesimulator/GentleWalk.app"
mkdir -p "$out"
xcrun simctl boot "$device" 2>/dev/null
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl install "$device" "$app"
xcrun simctl status_bar "$device" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 2>/dev/null
for item in "$@"; do
  state="${item%@*}"; variant=""
  [[ "$item" == *@* ]] && variant="${item#*@}"
  xcrun simctl ui "$device" appearance light
  xcrun simctl ui "$device" content_size large
  [[ "$variant" == "dark" ]] && xcrun simctl ui "$device" appearance dark
  [[ "$variant" == "xxl" ]] && xcrun simctl ui "$device" content_size accessibility-extra-extra-extra-large
  xcrun simctl launch --terminate-running-process "$device" com.kmd.gentlewalk -ScreenshotMode "$state" >/dev/null
  sleep 3
  name="$state"; [[ -n "$variant" ]] && name="$state-$variant"
  xcrun simctl io "$device" screenshot "$out/$name.png" >/dev/null 2>&1 && echo "$out/$name.png"
done
xcrun simctl ui "$device" appearance light
xcrun simctl ui "$device" content_size large
