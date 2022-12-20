{ config, lib, pkgs, ... }:

let
  types = lib.types;
  processType = types.submodule ({ config, ... }: {
    options = {
      exec = lib.mkOption {
        type = types.str;
        description = "Bash code to run the process.";
      };
    };
  });
  implementation = config.process.implementation;
  implementation-options = config.process.${implementation};
  envList =
    (lib.mapAttrsToList (name: value: "${name}=${toString value}") config.env);
in {
  options = {
    processes = lib.mkOption {
      type = types.attrsOf processType;
      default = { };
      description =
        "Processes will get started with ``k1x up`` and run in foreground mode.";
    };

    process = {
      implementation = lib.mkOption {
        type = types.enum [ "honcho" "overmind" "hivemind" ];
        default = "honcho";
        example = "overmind";
      };
    };

    procfile = lib.mkOption {
      type = types.package;
      internal = true;
    };

    procfileEnv = lib.mkOption {
      type = types.package;
      internal = true;
    };

    procfileScript = lib.mkOption {
      type = types.package;
      internal = true;
    };
  };

  config = lib.mkIf (config.processes != { }) {
    packages = [ pkgs.${implementation} ];

    procfile = pkgs.writeText "procfile" (lib.concatStringsSep "\n"
      (lib.mapAttrsToList (name: process: "${name}: ${process.exec}")
        config.processes));

    procfileEnv =
      pkgs.writeText "procfile-env" (lib.concatStringsSep "\n" envList);

    procfileScript = {
      honcho = pkgs.writeShellScript "honcho-up" ''
        echo "Starting processes ..." 1>&2
        echo "" 1>&2
        ${pkgs.honcho}/bin/honcho start -f ${config.procfile} --env ${config.procfileEnv}
      '';

      overmind = pkgs.writeShellScript "overmind-up" ''
        OVERMIND_ENV=${config.procfileEnv} ${pkgs.overmind}/bin/overmind start --procfile ${config.procfile}
      '';

      hivemind = pkgs.writeShellScript "hivemind-up" ''
        ${pkgs.hivemind}/bin/hivemind --print-timestamps ${config.procfile}
      '';
    }.${implementation};
  };
}
