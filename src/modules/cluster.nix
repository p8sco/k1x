{ pkgs, config, lib, ... }:

let
  inherit (lib) types mkOption;
  cfg = config.cluster;
  createK3dCluster = pkgs.writeShellScriptBin "create-k3d-cluster" ''
    set -euo pipefail
    ${pkgs.kube3d}/bin/k3d cluster create ${cfg.name}
  '';
in {
  options.cluster = {
    name = mkOption {
      type = types.str;
      default = "k8s-cluster";
      description = "Name of the cluster";
    };
  };
  config = {
    packages = with pkgs; [ kube3d kubectl ];
    processes.k3d = { exec = "${createK3dCluster}/bin/create-k3d-cluster"; };
  };
}
