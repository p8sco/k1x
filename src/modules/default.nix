{ config, pkgs, lib, ... }:

let
  types = lib.types;
  mkNakedShell = pkgs.callPackage ./mkNakedShell.nix { };
in {
  imports = [ ./cluster.nix ./processes.nix ];
  options = {
    version = lib.mkOption {
      type = types.str;
      default = "0.0.1";
      description = "Version of the application";
    };
  };
  config = { shell = mkNakedShell { }; };
}
