{ pkgs, nix }:

let
  examples = ../examples;
  lib = pkgs.lib;
  version = lib.fileContents ./version;
in pkgs.writeScriptBin "k1x" ''
  #!/usr/bin/env bash

  # we want subshells to fail the program
  set -e

  NIX_FLAGS="--show-trace --extra-experimental-features nix-command --extra-experimental-features flakes"
  CUSTOM_NIX=${nix.packages.${pkgs.system}.nix}
  export FLAKE_FILE=.k1x.flake.nix

  function assemble {
    export K1X_DIR="$(pwd)/.k1x"
    export K1X_GC="$K1X_DIR/gc"
    mkdir -p "$K1X_GC"

    cp -f ${import ./flake.nix { inherit pkgs; }} "$FLAKE_FILE"
    chmod +w "$FLAKE_FILE"
  }

  if [[ -z "$XDG_DATA_HOME" ]]; then
    GC_ROOT="$HOME/.k1x/gc"
  else 
    GC_ROOT="$XDG_DATA_HOME/k1x/gc"
  fi

  mkdir -p "$GC_ROOT"
  GC_DIR="$GC_ROOT/$(date +%s)"

  function add_gc {
    name=$1
    storePath=$2

    nix-store --add-root "$K1X_GC/$name" -r $storePath >/dev/null
    ln -sf $storePath "$GC_DIR-$name"
  }

  command=$1
  if [[ ! -z $command ]]; then
    shift
  fi

  case $command in
    up)
      assemble 
      eval "$env"
      procfilescript=$($CUSTOM_NIX/bin/nix $NIX_FLAGS build --no-link --print-out-paths --impure '.#procfileScript')
      cat $procfilescript
      if [ "$(cat $procfilescript|tail -n +2)" = "" ]; then
        echo "No 'processes' option defined"
        exit 1
      else
        add_gc procfilescript $procfilescript
        $procfilescript
      fi
      ;;
    init)
      if [ "$#" -eq "1" ]
      then
        target="$1"
        mkdir -p "$target"
        cd "$target"
      fi

      if [[ -f k1x.nix ]]; then
        echo "k1x.nix file already exists"
        exit 1
      fi

      echo "Creating k1x.nix"
      cat ${examples}/simple/k1x.nix > k1x.nix 
      echo "Appending .k1x* to .gitignore"
      echo ".k1x*" >> .gitignore
      echo "Done."
      ;;
    version)
      echo "k1x: ${version}"
      ;;
    *)
      echo "k1x - Reproducible Kubernetes environments for development and testing powered by Nix."
      echo
      echo "Usage: k1x <command> [options] [arguments]"
      echo
      echo "Commands:"
      echo
      echo "init:           Scaffold k1x.nix inside the current directory."
      echo "init TARGET:    Scaffold k1x.nix inside TARGET directory."
      echo "up:             Starts cluster in foreground."
      echo "version:        Display k1x version."
      echo
      exit 1
  esac
''

