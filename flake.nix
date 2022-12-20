{
  description = "k1x";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = { self, nixpkgs, nix, pre-commit-hooks, ... }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f:
        builtins.listToAttrs (map (name: {
          inherit name;
          value = f name;
        }) systems);
      mkPackage = pkgs: import ./src/k1x.nix { inherit pkgs nix; };
    in {
      modules = ./src/modules;
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in { default = mkPackage pkgs; });
    };
}
