# Configuration for my M1 Macbook Max (using nix-darwin)
{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
    "${self}/modules/nixos/shared/github-runner.nix"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "appreciate";

  security.pam.enableSudoTouchIdAuth = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  # See https://github.com/ryan4yin/nix-darwin-kickstarter/blob/main/rich-demo/modules/system.nix
  system.defaults = {
    dock = {
      autohide = true;
      # customize Hot Corners(触发角, 鼠标移动到屏幕角落时触发的动作)
      wvous-tl-corner = 2; # top-left - Mission Control
      wvous-tr-corner = 13; # top-right - Lock Screen
      wvous-bl-corner = 3; # bottom-left - Application Windows
      wvous-br-corner = 4; # bottom-right - Desktop
    };

    finder = {
      _FXShowPosixPathInTitle = true; # show full path in finder title
      AppleShowAllExtensions = true; # show all file extensions
      FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
      QuitMenuItem = true; # enable quit menu item
      ShowPathbar = true; # show path bar
      ShowStatusBar = true; # show status bar
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
