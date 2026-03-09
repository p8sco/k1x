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
        type = types.enum [ "process-compose" "overmind" "hivemind" ];
        default = "process-compose";
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
    packages = {
      process-compose = [ pkgs.process-compose ];
      overmind = [ pkgs.overmind ];
      hivemind = [ pkgs.hivemind ];
    }.${implementation};

    procfile = {
      process-compose = pkgs.writeText "process-compose.yaml"
        (builtins.toJSON {
          version = "0.5";
          processes = lib.mapAttrs (name: process: {
            command = process.exec;
          }) config.processes;
        });

      overmind = pkgs.writeText "procfile" (lib.concatStringsSep "\n"
        (lib.mapAttrsToList (name: process: "${name}: ${process.exec}")
          config.processes));

      hivemind = pkgs.writeText "procfile" (lib.concatStringsSep "\n"
        (lib.mapAttrsToList (name: process: "${name}: ${process.exec}")
          config.processes));
    }.${implementation};

    procfileEnv =
      pkgs.writeText "procfile-env" (lib.concatStringsSep "\n" envList);

    procfileScript = {
      process-compose = pkgs.writeShellScript "process-compose-up" ''
        echo "Starting processes ..." 1>&2
        echo "" 1>&2
        ${pkgs.process-compose}/bin/process-compose up -f ${config.procfile}
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
