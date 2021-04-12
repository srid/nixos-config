{ pkgs, inputs, ... }: {
  nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];
  environment.systemPackages = with pkgs; [
    emacsUnstable
  ];
}
