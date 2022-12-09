{ inputs, pkgs, lib, config, ... }:

{
  packages = [ (import ./src/k1x.nix { inherit pkgs; }) ];

  processes.build.exec = "${pkgs.watchexec}/bin/watchexec -e nix nix build";

  scripts.k1x-run-tests.exec = ''
    set -xe

    pushd examples/simple
      # this should fail since files already exist
      k1x init && exit 1
      rm k1x.nix
      k1x init
    popd
  '';

  pre-commit.hooks = {
    nixpkgs-fmt.enable = true;
    shellcheck.enable = true;
  };
}
