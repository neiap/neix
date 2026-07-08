{ config, pkgs, ... }:

{
  imports = [./hyprland.nix];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "neia";
  home.homeDirectory = "/home/neia";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland
  wayland.windowManager.hyprland.settings = {
    # VirtualBox has no real 3D-accelerated GPU: vboxvideo only provides KMS
    # scanout, so any app doing real OpenGL rendering (kitty via glfw) crashes
    # with a "wl_surface.attach: invalid arguments" protocol error. Force
    # llvmpipe software GL for everything Hyprland execs. WLR_NO_HARDWARE_CURSORS
    # works around the same VM's lack of a hardware cursor plane.
    env = [
      "WLR_NO_HARDWARE_CURSORS,1"
      "LIBGL_ALWAYS_SOFTWARE,1"
    ];
  };
  wayland.windowManager.hyprland.configType = "hyprlang";
  # Optional, hint Electron apps to use Wayland:
  home.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.vicinae = {
  enable = true;
  systemd.enable = true;
};

  # VirtualBox has no real 3D-accelerated GPU, only software (llvmpipe) rendering.
  # Vicinae's Qt Quick window crashes the whole daemon on open with a
  # "wl_surface.attach: invalid arguments" Wayland protocol error when it tries
  # to use the GL/RHI backend here, so force the software Qt Quick backend.
  systemd.user.services.vicinae.Service.Environment = [
    "QSG_RHI_BACKEND=software"
    "QT_QUICK_BACKEND=software"
    "LIBGL_ALWAYS_SOFTWARE=1"
  ];
}
