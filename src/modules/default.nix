{ config, pkgs, lib, ... }:

let types = lib.types;
in {
  imports = [ ./cluster.nix ./processes.nix ];
  options = {
    version = lib.mkOption {
      type = types.str;
      default = "0.0.1";
      description = "Version of the application";
    };
    cluster = lib.mkOption {
      description = "Cluster configuration";
      type = with types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              type = types.str;
              description = "An arbitrary name for the cluster";
            };
            provider = lib.mkOption {
              type = types.str;
              description = "Cluster provisioner";
              default = "k3d";
            };
            nativeConfig = lib.mkOption {
              type = types.attrs;
              description = "Cluster provisioner configuration";
              default = { };
            };
          };
        });
    };
  };
}
