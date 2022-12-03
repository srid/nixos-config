{ config, lib, ... }:
{
  options = {
    myUserName = lib.mkOption {
      type = lib.types.str;
      description = "The canonical (only) user to add to all systems.";
    };
  };
}
