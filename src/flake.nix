{ pkgs }:

pkgs.writeText "k1x-flake" ''
  {
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/release-22.04";
    };
    outputs = { nixpkgs, ... }@inputs:
      let
        pkgs = import nixpkgs { system = "${pkgs.system}"; };
        project = pkgs.lib.evalModules {
          specialArgs = inputs // { inherit inputs pkgs; };
          modules = [ ./k1x.nix ];
        };
        inherit (pkgs) lib;
        inherit (project) config;
      in {
        packages."${pkgs.system}" = {
          inherit (config) procfileScript procfileEnv procfile;
        };
      };
  }
''
