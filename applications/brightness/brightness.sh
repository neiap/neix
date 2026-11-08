STEP=10
runtime="${XDG_RUNTIME_DIR:-/tmp}"
lock="$runtime/brightness.lock"

# ddc writes take ~200ms, a held key queues them faster than the monitor accepts
exec 9>"$lock"
flock -n 9 || exit 0

monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
cache="$runtime/brightness-bus.$monitor"

[ -s "$cache" ] || brightness-probe
bus=$(cat "$cache" 2>/dev/null || true)

if [ -z "$bus" ]; then
  notify-send -t 3000 "Brightness" "no ddc/ci display on $monitor"
  exit 1
fi

case "${1:-}" in
up) ddcutil --bus "$bus" setvcp 10 + "$STEP" ;;
down) ddcutil --bus "$bus" setvcp 10 - "$STEP" ;;
get) : ;;
*)
  echo "usage: brightness up|down|get" >&2
  exit 2
  ;;
esac

level=$(ddcutil --bus "$bus" getvcp 10 | awk -F'=' '/current value/ { gsub(",", "", $2); print $2+0 }')

# synchronous hint replaces the previous popup instead of stacking one per keypress
notify-send -t 2000 -h string:x-canonical-private-synchronous:brightness \
  "Brightness" "$monitor  ${level}%"
