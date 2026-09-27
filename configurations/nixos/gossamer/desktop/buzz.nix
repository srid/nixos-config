{ pkgs, lib, flake, ... }:
let
  # GitHub's release metadata supplies both the versioned URL and SHA-256.
  # Updating the buzz input advances them together, without manual hashes.
  release = builtins.fromJSON (builtins.readFile flake.inputs.buzz);
  asset = lib.findFirst
    (asset: lib.hasSuffix "_amd64.AppImage" asset.name)
    (throw "Buzz release has no x86_64 Linux AppImage")
    release.assets;
  pname = "buzz";
  version = lib.removePrefix "desktop-v" release.tag_name;
  src = assert lib.hasPrefix "sha256:" asset.digest; pkgs.fetchurl {
    url = asset.browser_download_url;
    sha256 = lib.removePrefix "sha256:" asset.digest;
  };
  contents = pkgs.appimageTools.extract { inherit pname version src; };
  buzz = pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = p: [
      p.elfutils
      p.zstd
      p.gst_all_1.gst-plugins-good
      p.gst_all_1.gst-libav
    ];
    # WebKit needs the plugins provided by the FHS runtime, including audio sinks.
    profile = ''
      export GST_PLUGIN_PATH_1_0=/usr/lib/gstreamer-1.0
    '';
    extraInstallCommands = ''
      install -Dm644 ${contents}/Buzz.desktop "$out/share/applications/buzz.desktop"
      substituteInPlace "$out/share/applications/buzz.desktop" \
        --replace-fail 'Exec=buzz-desktop' 'Exec=buzz %U' \
        --replace-fail 'Categories=' 'Categories=Network;Chat;'
      mkdir -p "$out/share/icons"
      cp -a ${contents}/usr/share/icons/hicolor "$out/share/icons/"
    '';
    meta = {
      description = "Buzz workspace for people and AI agents";
      homepage = "https://buzz.xyz";
      license = lib.licenses.asl20;
      platforms = [ "x86_64-linux" ];
      mainProgram = "buzz";
    };
  };
in
{
  home-manager.sharedModules = [
    {
      home.packages = [ buzz ];
      xdg.mimeApps.defaultApplications."x-scheme-handler/buzz" = [ "buzz.desktop" ];
    }
  ];
}
