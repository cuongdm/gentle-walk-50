#!/bin/zsh
# Captures every listed state on several simulators at once (one capture_states.sh per device, in
# parallel), in light, dark and the largest text size. Used for the final check of a milestone.
# Usage: iOS/scripts/capture_matrix.sh <out-root> <states-file> <name=udid> [name=udid ...]
#   <states-file>: one capture state per line (blank lines and "#" comments ignored).
#   Variants: VARIANTS="light dark xxl" (default); language via CAPTURE_LANG / CAPTURE_LOCALE as in
#   capture_states.sh. Shots land in <out-root>/<name>/<state>[-dark|-xxl].png, logs in <out-root>/<name>.log.
# The app must already be built into /tmp/gw-dd. Each device gets its own process, so devices never share
# a simulator; keep the total number of simulators within what the owner allowed.
set -u
root="$1"; states_file="$2"; shift 2
variants=(${=VARIANTS:-light dark xxl})
here="${0:A:h}"
states=()
while IFS= read -r line; do
  line="${line%%#*}"; line="${line// /}"
  [[ -n "$line" ]] && states+=("$line")
done < "$states_file"
items=()
for s in "${states[@]}"; do
  for v in "${variants[@]}"; do
    [[ "$v" == "light" ]] && items+=("$s") || items+=("$s@$v")
  done
done
pids=()
for pair in "$@"; do
  name="${pair%%=*}"; udid="${pair#*=}"
  mkdir -p "$root/$name"
  "$here/capture_states.sh" "$root/$name" "$udid" "${items[@]}" > "$root/$name.log" 2>&1 &
  pids+=($!)
  echo "started $name ($udid): ${#items[@]} shots"
done
fail=0
for p in "${pids[@]}"; do wait "$p" || fail=1; done
for pair in "$@"; do
  name="${pair%%=*}"
  echo "$name: $(ls "$root/$name" 2>/dev/null | wc -l | tr -d ' ') shots"
done
exit $fail
