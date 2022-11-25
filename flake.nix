{
  description = "k1x";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = { self, nixpkgs, pre-commit-hooks, ... }:
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
      mkPackage = pkgs: import ./src/k1x.nix { inherit pkgs; };
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in { k1x = mkPackage pkgs; });
    };
}
