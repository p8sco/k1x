{
  description = "k1x - Reproducible Kubernetes environments powered by Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, ... }:
        let
          k1x = import ./src/k1x.nix { inherit pkgs; };
        in
        {
          packages = {
            inherit k1x;
            default = k1x;
          };

          devShells.default = pkgs.mkShell {
            packages = [ k1x pkgs.watchexec pkgs.nixpkgs-fmt pkgs.shellcheck ];
          };

          formatter = pkgs.nixpkgs-fmt;
        };

      flake = {
        modules = ./src/modules;
      };
    };
}
