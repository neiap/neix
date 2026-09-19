{
  config,
  lib,
  pkgs,
  ...
}:
let
  editorVersion = "2022.3.22f1";
  editorDir = "${config.home.homeDirectory}/Unity/Hub/Editor/${editorVersion}/Editor";

  launch = ''
    # the 784KB unlocked poiyomi base vertex snippet overruns the default task
    # timeout on this cpu and the compile fails outright, 0x80000008
    export UNITY_SHADER_COMPILER_TASK_TIMEOUT_MINUTES=30
    exec ${pkgs.unityhub.fhsEnv}/bin/unityhub-fhs-env "${editorDir}/Unity.real" -force-vulkan "$@"
  '';

  unity-editor = pkgs.writeShellScriptBin "unity-editor" launch;
  inPlaceWrapper = pkgs.writeShellScript "unity-fhs-wrapper" launch;
in
{
  home.packages = [ unity-editor ];

  # alcom rediscovers the hub editor path every start and launches it bare, with no
  # libGL/libX11, so whatever sits at that path has to enter the fhs env itself
  home.activation.unityEditorWrapper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${editorDir}" ]; then
      # a hub reinstall drops the real elf back at this name, shift it aside first
      if [ -e "${editorDir}/Unity" ] && [ "$(head -c2 "${editorDir}/Unity")" != '#!' ]; then
        run mv "${editorDir}/Unity" "${editorDir}/Unity.real"
      fi
      run install -m755 ${inPlaceWrapper} "${editorDir}/Unity"
    fi
  '';
}
