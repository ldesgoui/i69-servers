{
  perSystem = { config, lib, pkgs, ... }: {
    options.tf2ds =
      let
        inherit (lib) mkOption types;
      in
      {
        searchPaths = mkOption {
          type = with types; listOf (submodule {
            options.keys = mkOption { type = listOf str; };
            options.path = mkOption { type = str; };
          });
        };
      };

    config.tf2ds = {
      lib.toArgs = args @ { commands ? [ ], ... }:
        lib.escapeShellArgs
          (lib.cli.toGNUCommandLine
            { mkOptionName = k: "-${k}"; }
            (builtins.removeAttrs args [ "commands" ])
          ++ (map (c: "+${c}") commands));

      searchPaths = [
        {
          keys = [ "game" "mod" "vgui" ];
          path = "${config.packages.tf2ds}/tf/tf2_misc.vpk";
        }
        {
          keys = [ "game" "vgui" ];
          path = "${config.packages.tf2ds}/hl2/hl2_misc.vpk";
        }
        {
          keys = [ "gamebin" ];
          path = "${config.packages.tf2ds}/tf/bin";
        }
        {
          keys = [ "mod" "mod_write" "default_write_path" ];
          path = ".";
        }
        {
          keys = [ "game" "game_write" ];
          path = "tf";
        }
        {
          keys = [ "mod" ];
          path = "${config.packages.tf2ds}";
        }
        {
          keys = [ "mod" "game" ];
          path = "${config.packages.tf2ds}/tf";
        }
        {
          keys = [ "mod" "game" ];
          path = "${config.packages.tf2ds}/hl2";
        }
        {
          keys = [ "game" "download" ];
          path = "tf/download";
        }
      ];
    };

    config.packages = {
      gameinfo =
        let
          paths =
            lib.concatMapStringsSep "\n"
              ({ keys, path }: ''"${lib.concatStringsSep "+" keys}" "${path}"'')
              config.tf2ds.searchPaths;
        in
        pkgs.writeText "gameinfo.txt" ''
          #base "${config.packages.tf2ds}/tf/gameinfo.txt"

          GameInfo {
            FileSystem {
              SearchPaths {
                ${paths}
              }
            }
          }
        '';

      run = pkgs.writeShellScriptBin "run-tf2ds" ''
        set -euo pipefail

        state=$(realpath "''${TF2DS_STATE:-./tf2ds}")

        mkdir -p "$state"/tf
        ln -fns ${config.packages.tf2ds} "$state"/.drv
        ln -fns ${config.packages.gameinfo} "$state"/tf/gameinfo.txt

        exec \
        ${lib.getExe pkgs.steam-run-native} \
        ${lib.getExe pkgs.strace} -o "$state"/.trace \
        sh << END
        LD_LIBRARY_PATH=${config.packages.tf2ds}/bin:\$LD_LIBRARY_PATH \
          exec -a "$state"/srcds_run \
            ${config.packages.tf2ds}/srcds_linux \
              -game tf \
              $@
        END
      '';
    };
  };
}

