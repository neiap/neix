runtime="${XDG_RUNTIME_DIR:-/tmp}"
prefix="$runtime/brightness-bus"

# a disconnected monitor must not leave its old bus behind
rm -f "$prefix".*

# nvidia exposes no ddc sysfs link, so the map costs a full scan rather than a sysfs read
(ddcutil detect 2>/dev/null || true) | awk '
  /^ *I2C bus:/ { n = $NF; sub(/.*i2c-/, "", n); bus = n }
  /^ *DRM_connector:/ {
    c = $NF
    sub(/^card[0-9]+-/, "", c)
    if (bus != "") print c, bus
    bus = ""
  }
' | while read -r connector bus; do
  # answering detect does not mean 0x10 is implemented
  ddcutil --bus "$bus" getvcp 10 >/dev/null 2>&1 || continue
  tmp=$(mktemp "$prefix.$connector.XXXXXX")
  printf '%s' "$bus" >"$tmp"
  mv -f "$tmp" "$prefix.$connector"
done
