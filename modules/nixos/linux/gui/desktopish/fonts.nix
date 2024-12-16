{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # NOTE: Some fonts may break colour emojis in Chrome
      # cf. https://github.com/NixOS/nixpkgs/issues/69073#issuecomment-621982371
      # If this happens , keep noto-fonts-emoji and try disabling others (nerdfonts, etc.)
      noto-fonts-emoji
      fira-code
      cascadia-code
      nerd-fonts._0xproto
      nerd-fonts.droid-sans-mono
      font-awesome
    ];
  };
}
