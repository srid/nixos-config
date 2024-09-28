{ pkgs, ... }:

# TODO: Upstream as home-manager module: https://github.com/nix-community/home-manager/issues/2890
#
# FIXME: Powershell launch is quite slow, on macOS. So not using it as default shell.
{
  home.packages = with pkgs; [
    powershell
  ];

  home.file.".config/powershell/Microsoft.PowerShell_profile.ps1".text = ''
    $Env:PATH += ":/etc/profiles/per-user/''${Env:USER}/bin"
    $Env:PATH += ":/run/current-system/sw/bin/"
    $Env:PATH += ":/Applications/Docker.app/Contents/Resources/bin/"

    # starship
    Invoke-Expression (&starship init powershell)

    # zoxide
    Invoke-Expression (& {
        $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
        (zoxide init --hook $hook powershell | Out-String)
    })
  '';
}
