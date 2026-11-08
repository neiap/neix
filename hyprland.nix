{
  lib,
  osConfig,
  ...
}:
let
  mod = "SUPER";
  toLua = lib.generators.toLua { };
  lua = lib.generators.mkLuaInline;

  bindWith = opts: keys: dispatcher: {
    _args = [
      keys
      (lua dispatcher)
    ]
    ++ lib.optional (opts != { }) opts;
  };
  bind = bindWith { };
  exec = cmd: "hl.dsp.exec_cmd(${toLua cmd})";
  env = name: value: {
    _args = [
      name
      value
    ];
  };

  uwsmCmd = lib.optionalString osConfig.programs.uwsm.enable "uwsm app -- ";
  uwsmApp = cmd: uwsmCmd + cmd;
  uwsmSingleApp = cmd: "pgrep ${cmd} || ${uwsmCmd + cmd}";
  launch = keys: cmd: bind keys (exec (uwsmApp cmd));

  workspaces = map toString (lib.range 1 9);

  getBrightness = "ddcutil getvcp 10 | awk -F'=' '/current value/ { gsub(\",\", \"\", $2); print $2+0 }'";
in
{
  wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        gaps_in = 3;
        gaps_out = 6;
      };

      decoration = {
        shadow = {
          range = 8;
          render_power = 3;
          color = "rgba(00000055)";
        };
        dim_inactive = false;
        blur.enabled = true;
      };

      input.numlock_by_default = true;

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      animations.enabled = true;
    };

    env = [
      (env "LIBVA_DRIVER_NAME" "nvidia")
      (env "GBM_BACKEND" "nvidia-drm")
      (env "__GLX_VENDOR_LIBRARY_NAME" "nvidia")
      (env "__GL_VRR_ALLOWED" "1")
      (env "__GL_THREADED_OPTIMIZATIONS" "0")
    ];

    monitor = [
      {
        output = "desc:Ancor Communications Inc ROG PG279Q #ASPyoJ5sadfd";
        mode = "2560x1440@165";
        position = "0x0";
      }
      {
        output = "desc:ASUSTek COMPUTER INC VG27AQ1A S9LMQS05834";
        mode = "2560x1440@144";
        position = "auto-right";
      }
      {
        output = "desc:Philips Consumer Electronics Company PHL 241V8B UHB2327001622";
        mode = "1920x1080@100";
        position = "auto-left";
      }
    ];

    window_rule = lib.singleton {
      # elden ring fullscreen fix
      name = "elden-ring";
      match.class = "^(steam_app_1245620)$";
      float = true;
      fullscreen = true;
    };

    on = lib.singleton {
      _args = [
        "hyprland.start"
        (lua ''
          function()
            hl.exec_cmd("uwsm finalize")
          end'')
      ];
    };

    bind = [
      # use wev to find mouse button codes
      (bindWith { mouse = true; } "${mod} + mouse:272" "hl.dsp.window.drag()")
      (bindWith { mouse = true; } "${mod} + mouse:273" "hl.dsp.window.resize()")
      (bindWith { mouse = true; } "${mod} + CTRL + mouse:272" "hl.dsp.window.resize()")

      # compositor commands
      (bind "${mod} + Q" "hl.dsp.window.close()")
      (bind "${mod} + F" "hl.dsp.window.fullscreen_state({ internal = 2, client = -1 })") # fullscreen the window, don't inform the client it was fullscreened
      (bind "${mod} + SHIFT + F" "hl.dsp.window.fullscreen_state({ internal = -1, client = 2 })") # keep current fullscreen state, tell client it is fullscreened
      (bind "${mod} + R" ''hl.dsp.layout("togglesplit")'')
      (bind "${mod} + G" ''hl.dsp.window.float({ action = "toggle" })'')
      (bind "${mod} + A" "hl.dsp.group.toggle()")
      (bind "${mod} + SHIFT + A" "hl.dsp.group.lock()")
      (bind "ALT + TAB" "hl.dsp.group.next()")
      (bind "ALT + SHIFT + TAB" "hl.dsp.group.prev()")
      (bind "${mod} + T" "hl.dsp.window.pin()")
      (bind "CTRL + ALT + DELETE" (exec (uwsmApp "hyprctl kill")))
      (bind "CTRL + ALT + SHIFT + DELETE" (
        exec ''systemctl --user stop wayland-wm@hyprland\\x2duwsm.desktop.service''
      ))

      # utility
      ## terminal
      (launch "${mod} + RETURN" "kitty")
      ## lock screen
      (bind "${mod} + L" (exec (uwsmSingleApp "hyprlock")))
      ## launcher
      (bind "${mod} + S" (exec "vicinae toggle")) # not using uwsm as it introduces latency
      ## browser
      (launch "${mod} + W" "firefox")
      ## file explorer
      (launch "${mod} + E" "thunar")
      ## emoji picker
      (launch "${mod} + SHIFT + E" "emote")

      # move focus
      (bind "${mod} + LEFT" ''hl.dsp.focus({ direction = "left" })'')
      (bind "${mod} + RIGHT" ''hl.dsp.focus({ direction = "right" })'')
      (bind "${mod} + UP" ''hl.dsp.focus({ direction = "up" })'')
      (bind "${mod} + DOWN" ''hl.dsp.focus({ direction = "down" })'')

      # swap windows
      (bind "${mod} + SHIFT + LEFT" ''hl.dsp.window.swap({ direction = "left" })'')
      (bind "${mod} + SHIFT + RIGHT" ''hl.dsp.window.swap({ direction = "right" })'')
      (bind "${mod} + SHIFT + UP" ''hl.dsp.window.swap({ direction = "up" })'')
      (bind "${mod} + SHIFT + DOWN" ''hl.dsp.window.swap({ direction = "down" })'')

      # screenshot
      ## area
      (bind "${mod} + SHIFT + S" (exec "${uwsmSingleApp "grimblast"} --notify copy area"))
      ## current screen
      (bind "CTRL + PRINT" (exec "${uwsmSingleApp "grimblast"} --notify --cursor copy output"))
      (bind "${mod} + SHIFT + CTRL + S" (
        exec "${uwsmSingleApp "grimblast"} --notify --cursor copy output"
      ))

      # cycle workspaces
      (bind "${mod} + bracketleft" ''hl.dsp.focus({ workspace = "m-1" })'')
      (bind "${mod} + bracketright" ''hl.dsp.focus({ workspace = "m+1" })'')

      # cycle monitors
      (bind "${mod} + SHIFT + bracketleft" ''hl.dsp.focus({ monitor = "l" })'')
      (bind "${mod} + SHIFT + bracketright" ''hl.dsp.focus({ monitor = "r" })'')

      # send focused workspace to left/right monitors
      (bind "${mod} + SHIFT + ALT + bracketleft" ''hl.dsp.workspace.move({ monitor = "l" })'')
      (bind "${mod} + SHIFT + ALT + bracketright" ''hl.dsp.workspace.move({ monitor = "r" })'')

      # color picker
      (bind "${mod} + SHIFT + C" (exec "${uwsmSingleApp "hyprpicker"} --autocopy"))

      # display time as noficiation
      (bind "${mod} + D" (exec ''notify-send -t 5000 "$(date "+%a %-d %b %Y | %-I:%M%p")"''))

      # toggle mako dnd
      (bind "${mod} + SHIFT + D" (exec "makoctl mode -t do-not-disturb"))

      # ddcutil external monitor brightness
      (bind "${mod} + PAGE_UP" (exec "ddcutil setvcp 10 + 10"))
      (bind "${mod} + PAGE_DOWN" (exec "ddcutil setvcp 10 - 10"))
      (bind "${mod} + PRINT" (exec "notify-send -t 5000 \"Current Brightness: $(${getBrightness})%\""))

      # resize with arrowkeys
      (bindWith {
        repeating = true;
      } "${mod} + CTRL + UP" "hl.dsp.window.resize({ x = 0, y = -20, relative = true })")
      (bindWith {
        repeating = true;
      } "${mod} + CTRL + DOWN" "hl.dsp.window.resize({ x = 0, y = 20, relative = true })")
      (bindWith {
        repeating = true;
      } "${mod} + CTRL + LEFT" "hl.dsp.window.resize({ x = -20, y = 0, relative = true })")
      (bindWith {
        repeating = true;
      } "${mod} + CTRL + RIGHT" "hl.dsp.window.resize({ x = 20, y = 0, relative = true })")

      # media controls
      (bindWith { locked = true; } "XF86AudioPlay" (exec "playerctl play-pause"))
      (bindWith { locked = true; } "XF86AudioNext" (exec "playerctl next"))
      (bindWith { locked = true; } "XF86AudioPrev" (exec "playerctl previous"))
      (bindWith { locked = true; } "XF86AudioStop" (exec "playerctl stop"))

      # volume
      (bindWith { locked = true; } "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
      (bindWith { locked = true; } "XF86AudioMicMute" (
        exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ))
      (bindWith {
        locked = true;
        repeating = true;
      } "XF86AudioRaiseVolume" (exec "wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"))
      (bindWith {
        locked = true;
        repeating = true;
      } "XF86AudioLowerVolume" (exec "wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"))
    ]
    # workspace keys
    ++ map (ws: bind "${mod} + ${ws}" ''hl.dsp.focus({ workspace = "${ws}" })'') workspaces
    ++ map (
      ws: bind "${mod} + SHIFT + ${ws}" ''hl.dsp.window.move({ workspace = "${ws}" })''
    ) workspaces;
  };
}
