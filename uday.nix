{ self }:
{
  users.users.uday.isNormalUser = true;
  home-manager.users."uday" = {
    imports = [
      self.homeModules.common-linux
      (import ./home/git.nix {
        userName = "Uday Kiran";
        userEmail = "udaycruise2903@gmail.com";
      })
    ];
  };
}
