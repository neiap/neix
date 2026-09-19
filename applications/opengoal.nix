{ pkgs, ... }:
let
  version = "2.11.1";

  src = pkgs.fetchurl {
    url = "https://github.com/open-goal/launcher/releases/download/v${version}/OpenGOAL-Launcher_${version}_amd64.AppImage";
    hash = "sha256-e43pKfAurZoCxMHCD0HlY/odZfQS9fZjSxPjPpRJBak=";
  };

  # uruntime appimage packs its payload as dwarfs, so appimageTools.extract cannot read it
  contents =
    pkgs.runCommand "opengoal-launcher-${version}-extracted"
      { nativeBuildInputs = [ pkgs.dwarfs ]; }
      ''
        mkdir -p $out
        dwarfsextract -i ${src} -o $out -O auto
      '';

  opengoal-launcher = pkgs.appimageTools.wrapAppImage {
    pname = "opengoal-launcher";
    inherit version contents;

    extraInstallCommands = ''
      install -Dm444 ${contents}/OpenGOAL-Launcher.desktop -t $out/share/applications
      install -Dm444 ${contents}/OpenGOAL-Launcher.png \
        $out/share/icons/hicolor/256x256/apps/OpenGOAL-Launcher.png
      substituteInPlace $out/share/applications/OpenGOAL-Launcher.desktop \
        --replace-fail 'Exec=OpenGOAL-Launcher' 'Exec=opengoal-launcher'
    '';

    meta.mainProgram = "opengoal-launcher";
  };
in
{
  home.packages = [ opengoal-launcher ];
}
