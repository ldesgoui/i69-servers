{ config, lib, pkgs, ... }: {
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
        keys = [ "mod" "game" "game_write" ];
        path = "tf";
      }
      {
        keys = [ "mod" ];
        path = "${config.packages.tf2ds}";
      }
      {
        # Keyed `mod` because the game searches for `<mod>/scripts/item/items_game.txt`
        keys = [ "mod" "game" ];
        path = "${config.packages.tf2ds}/tf";
      }
      {
        keys = [ "game" ];
        path = "${config.packages.tf2ds}/hl2";
      }
      {
        keys = [ "mod" "game" ];
        path = "${config.packages.all-configs}/tf";
      }
      {
        keys = [ "mod" "game" ];
        path = "${config.packages.all-addons}/tf";
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
          lib.concatMapStringsSep "\n      "
            ({ keys, path }: ''"${lib.concatStringsSep "+" keys}" "${path}"'')
            config.tf2ds.searchPaths;
      in
      pkgs.writeText "gameinfo.txt" ''
        // This file was auto-generated

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

      gen_pass() { head -c 10 /dev/urandom | base32; }

      state=$(realpath "''${TF2DS_STATE:-./tf2ds}")
      password=''${PASSWORD:-$(gen_pass)}
      rcon_password=''${RCON_PASSWORD:-$(gen_pass)}

      echo "---"
      echo "--- State dir:     $state"
      echo "--- Password:      $password"
      echo "--- Rcon password: $rcon_password"
      echo "---"

      mkdir -p "$state"/{tf/addons,.steam/sdk32}
      ${pkgs.findutils}/bin/find "$state" -type l -delete

      ln -fns ${config.packages.gameinfo} "$state"/tf/gameinfo.txt
      ln -fns ${config.packages.tf2ds}/bin/steamclient.so "$state"/.steam/sdk32/

      ${lib.getExe pkgs.xorg.lndir} -silent ${config.packages.all-plugins} "$state"

      HOME=$state \
      LD_LIBRARY_PATH=${config.packages.tf2ds}/bin:${pkgs.pkgsi686Linux.ncurses5}/lib \
      exec -a "$state"/srcds_linux \
        ${config.packages.tf2ds}/srcds_linux \
          ${config.tf2ds.lib.toArgs {
            game = "tf";
            ip = "0.0.0.0";
            maxplayers = 24;
            commands = [
              "sv_pure 2"
              "map itemtest"
            ];
          }} \
          "+sv_password $password" "+rcon_password $rcon_password" \
          $@
    '';
  };
}
