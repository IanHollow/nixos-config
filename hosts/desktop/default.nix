{ lib, pkgs, vars, ... }:

{
  imports = [ ./hardware-configuration.nix ] ++
    (import ../../modules/desktops) ++
    (import ../../modules/programs) ++
    (import ../../modules/shell);
}
