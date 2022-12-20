{ pkgs }:

let
  lib = pkgs.lib;
  version = lib.removeSuffix "\n" (builtins.readFile ./version);
  examples = ../examples;
in pkgs.writeScriptBin "k1x" ''
  #!/usr/bin/env bash

  set -e

  NIX_FLAGS="--show-trace --extra-experimental-features nix-command --extra-experimental-features flakes"

  command=$1
  if [[ ! -z $command ]]; then
    shift
  fi

  case $command in
    up)
      echo "Starting k1x ..." 1>&2
      shell
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

