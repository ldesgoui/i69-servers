{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.tf2ds;
in
{
  options.tf2ds = {
    version = mkOption {
      type = types.str;
      default = "2023.07.28";
    };

    manifests = mkOption {
      type = with types; attrsOf str;
      default = {
        # https://steamdb.info/depot/232250/
        "232250" = "3243767659984921464";
        # https://steamdb.info/depot/232256/
        "232256" = "794676031397025408";
      };
    };

    chunks = mkOption {
      type = with types; listOf (submoduleWith {
        modules = [
          ({ config, ... }: {
            options = {
              app = mkOption {
                type = str;
                default = "232250";
              };

              depot = mkOption {
                type = str;
                default = "232250";
              };

              manifest = mkOption {
                type = str;
                default = cfg.manifests.${toString config.depot};
              };

              fileList = mkOption {
                type = nullOr lines;
                default = null;
              };

              hash = mkOption {
                type = str;
                default = lib.fakeHash;
              };

              patch = mkOption {
                type = bool;
                default = false;
              };
            };
          })
        ];
      });

      default = [
        { depot = "232256"; patch = true; }
        {
          fileList = ''
            hl2/hl2_misc_dir.vpk
            tf/cfg/pure_server_full.txt
            tf/cfg/pure_server_minimal.txt
            tf/cfg/trusted_keys_base.txt
            tf/gameinfo.txt
            tf/maps/itemtest.bsp
            tf/scripts/items/items_game.txt
            tf/scripts/items/items_game.txt.sig
            tf/scripts/protodefs/proto_defs.vpd
            tf/scripts/protodefs/proto_defs.vpd.sig
            tf/steam.inf
            tf/tf2_misc_dir.vpk
          '';
        }
        { fileList = "hl2/hl2_misc_000.vpk"; }
        { fileList = "hl2/hl2_misc_001.vpk"; }
        { fileList = "hl2/hl2_misc_002.vpk"; }
        { fileList = "hl2/hl2_misc_003.vpk"; }
        { fileList = "tf/tf2_misc_000.vpk"; }
        { fileList = "tf/tf2_misc_001.vpk"; }
        { fileList = "tf/tf2_misc_002.vpk"; }
        { fileList = "tf/tf2_misc_003.vpk"; }
        { fileList = "tf/tf2_misc_004.vpk"; }
        { fileList = "tf/tf2_misc_005.vpk"; }
        { fileList = "tf/tf2_misc_006.vpk"; }
        { fileList = "tf/tf2_misc_007.vpk"; }
        { fileList = "tf/tf2_misc_008.vpk"; }
        { fileList = "tf/tf2_misc_009.vpk"; }
        { fileList = "tf/tf2_misc_010.vpk"; }
        { fileList = "tf/tf2_misc_011.vpk"; }
        { fileList = "tf/tf2_misc_012.vpk"; }
        { fileList = "tf/tf2_misc_013.vpk"; }
        { fileList = "tf/tf2_misc_014.vpk"; }
        { fileList = "tf/tf2_misc_015.vpk"; }
        { fileList = "tf/tf2_misc_016.vpk"; }
        { fileList = "tf/tf2_misc_017.vpk"; }
        { fileList = "tf/tf2_misc_018.vpk"; }
        { fileList = "tf/tf2_misc_019.vpk"; }
        { fileList = "tf/tf2_misc_020.vpk"; }
        { fileList = "tf/tf2_misc_021.vpk"; }
        { fileList = "tf/tf2_misc_022.vpk"; }
        { fileList = "tf/tf2_misc_023.vpk"; }
        { fileList = "tf/tf2_misc_024.vpk"; }
      ];
    };
  };

  config.tf2ds = {
    chunks = lib.mkIf (builtins.pathExists ./chunks.json) (lib.importJSON ./chunks.json);

    lib.chunkName = { depot, manifest, ... }:
      "depot-${depot}.${manifest}";

    lib.chunkToArgs = chunk @ { fileList, ... }:
      lib.concatStringsSep " "
        (lib.cli.toGNUCommandLine
          { mkOptionName = k: "-${k}"; }
          {
            inherit (builtins.mapAttrs (_: lib.escapeShellArg) chunk) app depot manifest;
            filelist = lib.optional (fileList != null) ''"$fileListPath"'';
            dir = ''"$out"'';
          });

    lib.fetchDepot = chunk:
      let
        depot = pkgs.runCommand (cfg.lib.chunkName chunk)
          {
            buildInputs = [
              pkgs.cacert
              pkgs.depotdownloader
            ];

            outputHashAlgo = "sha256";
            outputHash = chunk.hash;
            outputHashMode = "recursive";

            inherit (chunk) app depot manifest fileList;
            passAsFile = [ "fileList" ];
          }
          ''
            HOME=$(mktemp -d) DepotDownloader ${cfg.lib.chunkToArgs chunk}
            rm -rf "$out/.DepotDownloader"
          '';

        mkPatched = { stdenv, autoPatchelfHook, curl }:
          stdenv.mkDerivation {
            inherit (depot) name;

            src = depot;

            dontUnpack = true;
            dontStrip = true;

            nativeBuildInputs = [
              autoPatchelfHook
            ];

            buildInputs = [
              stdenv.cc.cc.lib
              (curl.override { gnutlsSupport = true; opensslSupport = false; })
            ];

            installPhase = ''
              cp -r $src/. $out
            '';
          };
      in
      if chunk.patch then
        pkgs.pkgsi686Linux.callPackage mkPatched { }
      else
        depot;
  };

  config.packages = {
    tf2ds = pkgs.symlinkJoin {
      name = "tf2-dedicated-server-${cfg.version}";
      inherit (cfg) version;
      paths = map cfg.lib.fetchDepot cfg.chunks;
    };

    prefetch-tf2ds-chunks =
      pkgs.writeShellScriptBin "prefetch-tf2ds-chunks" ''
        set -euo pipefail

        export PATH=${pkgs.depotdownloader}/bin:${pkgs.jq}/bin:$PATH

        tmp=$(mktemp -dt prefetch-tf2ds.XXX)

        ${lib.flip lib.concatImapStrings cfg.chunks (i: chunk: ''
          echo '--- Fetching chunk #${toString i}'

          dir=$tmp/chunk-${toString i}
          mkdir -p $dir

          out=$dir/${cfg.lib.chunkName chunk}

          ${pkgs.lib.optionalString (chunk.fileList != null) ''
            fileListPath=$dir/file-list.txt
            echo ${lib.escapeShellArg chunk.fileList} > "$fileListPath"
          ''}

          DepotDownloader ${cfg.lib.chunkToArgs chunk}
          rm -rf "$out/.DepotDownloader"

          hash=$(nix hash path "$out")
          nix store add-path "$out"

          jq --arg hash "$hash" '.hash = $hash' > "$tmp/${toString (1000 + i)}.json" << END
          ${builtins.toJSON { inherit (chunk) app depot manifest fileList patch; }}
          END

        '')}

        jq -s '.' "$tmp"/*.json > chunks.json
      '';
  };
}
