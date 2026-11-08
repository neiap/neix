runtime="${XDG_RUNTIME_DIR:-/tmp}"
sock=""
sig="${HYPRLAND_INSTANCE_SIGNATURE:-}"

if [ -n "$sig" ] && [ -S "$runtime/hypr/$sig/.socket2.sock" ]; then
  sock="$runtime/hypr/$sig/.socket2.sock"
fi

tries=0
while [ -z "$sock" ] && [ "$tries" -lt 30 ]; do
  for s in "$runtime"/hypr/*/.socket2.sock; do
    if [ -S "$s" ]; then
      sock="$s"
      break
    fi
  done
  [ -n "$sock" ] && break
  tries=$((tries + 1))
  sleep 1
done

if [ -z "$sock" ]; then
  echo "brightness-watch: hyprland socket2 not found" >&2
  exit 1
fi

# hotplug is the only thing that invalidates the bus map
socat -u "UNIX-CONNECT:$sock" - | while IFS= read -r line; do
  case "$line" in
  monitoradded* | monitorremoved*) brightness-probe ;;
  esac
done
