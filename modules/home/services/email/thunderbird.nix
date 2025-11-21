{ pkgs, ... }:
{
  programs.thunderbird = {
    enable = true;

    # Thunderbird package is unavailable for Darwin.
    # Install the app manually.
    package = pkgs.hello;

    profiles."default" = {
      isDefault = true;
    };
  };

  accounts.email.accounts = {
    "srid@srid.ca".thunderbird = {
      enable = true;
    };
    "sridhar.ratnakumar@juspay.in".thunderbird = {
      enable = true;
    };
  };
}
