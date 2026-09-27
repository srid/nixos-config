{ pkgs, lib, flake, ... }:
let
  # The official Linux download is pinned by flake.lock. nixpkgs' chatgpt
  # currently packages macOS only.
  app = pkgs.stdenvNoCC.mkDerivation {
    name = "chatgpt-linux-unwrapped";
    src = flake.inputs.chatgpt;
    nativeBuildInputs = [ pkgs.dpkg ];
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      dpkg-deb -x "$src" extracted
      mkdir -p "$out/lib" "$out/share"
      cp -a extracted/usr/lib/chatgpt "$out/lib/chatgpt"
      cp -a extracted/usr/share/pixmaps "$out/share/pixmaps"
      runHook postInstall
    '';
  };
  launcher = pkgs.writeShellScript "chatgpt-launch" ''
    exec ${app}/lib/chatgpt/ChatGPT \
      --ozone-platform=wayland \
      --user-data-dir="''${XDG_CONFIG_HOME:-$HOME/.config}/chatgpt" "$@"
  '';
  desktop = pkgs.makeDesktopItem {
    name = "chatgpt";
    desktopName = "ChatGPT";
    comment = "ChatGPT by OpenAI";
    exec = "chatgpt %U";
    icon = "chatgpt";
    categories = [ "Utility" "Development" ];
    mimeTypes = [ "x-scheme-handler/codex" ];
    startupWMClass = "chatgpt";
  };
  chatgpt = pkgs.buildFHSEnv {
    name = "chatgpt";
    # Keep upstream's bundled Electron and native helpers together, supplying
    # their Linux libraries through the runtime tested on Niri.
    targetPkgs = p: with p; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      glib
      gdk-pixbuf
      gtk3
      libnotify
      nspr
      nss
      pango
      libdrm
      libgbm
      libxkbcommon
      libGL
      openssl
      systemd
      libusb1
      tpm2-tss
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
      stdenv.cc.cc.lib
      zlib
      wayland
      xdg-utils
    ];
    runScript = launcher;
    extraInstallCommands = ''
      mkdir -p "$out/share"
      ln -s ${app}/share/pixmaps "$out/share/pixmaps"
      ln -s ${desktop}/share/applications "$out/share/applications"
    '';
    meta = {
      description = "Official ChatGPT desktop app for Linux";
      homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "chatgpt";
    };
  };
in
{
  home-manager.sharedModules = [
    {
      home.packages = [ chatgpt ];
      xdg.mimeApps.defaultApplications."x-scheme-handler/codex" = [ "chatgpt.desktop" ];
    }
  ];
}
