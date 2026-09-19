TRACKERS=(LHR-47B90BBC LHR-383B0B7D LHR-DA140F05 LHR-D03ECB7F)
IPC_SOCK="${XDG_RUNTIME_DIR}/wivrn/comp_ipc"

echo "== VR session startup =="
echo
echo "[1/5] Power on the lighthouse base stations, and make sure the trackers"
echo "      are charged/on and in line of sight of the base stations:"
printf '        %s\n' "${TRACKERS[@]}"
read -rp "      Press Enter once that's done... "

if systemctl --user is-active --quiet wivrn.service; then
  echo
  echo "!! wivrn.service (systemd) is running -- this conflicts with WiVRn"
  echo "   Dashboard over the IPC socket. Stopping it first."
  systemctl --user stop wivrn.service
fi

if ! pgrep -x wivrn-dashboard >/dev/null && ! pgrep -f wivrn-server >/dev/null; then
  echo
  echo "[2/5] Launching WiVRn Dashboard..."
  setsid wivrn-dashboard >/dev/null 2>&1 &
else
  echo
  echo "[2/5] WiVRn Dashboard/server already running."
fi

echo
echo "[3/5] Waiting for headset to connect (put it on now)..."
connected=false
for _ in $(seq 1 300); do
  if [ -S "$IPC_SOCK" ]; then
    connected=true
    break
  fi
  sleep 1
done
if ! $connected; then
  echo "!! Timed out after 5 minutes waiting for the headset to connect."
  echo "   Check the WiVRn Dashboard window for errors, then re-run this script."
  exit 1
fi
echo "      Headset connected."

echo
echo "[4/5] Applying saved tracker calibration (motoc continue)..."
if ! motoc --wait continue; then
  echo "!! motoc continue failed -- you may need a fresh calibration:"
  echo "     motoc monitor"
  echo "     sleep 5; motoc calibrate --src \"WiVRn HMD\" --dst \"<tracker serial>\" --continue"
  exit 1
fi

echo
echo "[5/5] Verifying trackers..."
show_out="$(motoc show)"
echo "$show_out"
missing=()
for t in "${TRACKERS[@]}"; do
  grep -q "$t" <<<"$show_out" || missing+=("$t")
done

echo
if [ "${#missing[@]}" -gt 0 ]; then
  echo "!! Missing trackers: ${missing[*]}"
  echo "   Spread them out / power-cycle them and restart WiVRn Dashboard."
  echo "   See ~/vr-startup.txt Troubleshooting section."
  exit 1
fi

echo "All 4 trackers found. VR ready -- launch VRChat as normal."
echo
echo "  REMINDER: to stop motoc, press Ctrl+C in its terminal -- do NOT close the window."
