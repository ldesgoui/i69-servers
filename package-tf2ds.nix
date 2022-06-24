{
  perSystem = { config, lib, pkgs, ... }: {
    options.tf2ds =
      let
        inherit (lib) mkOption types;
        inherit (config.tf2ds) manifests;
      in
      {
        version = mkOption {
          type = types.str;
          default = "0+2022.06.23";
        };

        manifests = mkOption {
          type = with types; attrsOf str;
          default = {
            "232250" = "5494866935743571710";
            "232256" = "7216127081639525620";
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
                    default = manifests.${toString config.depot};
                  };

                  fileList = mkOption {
                    type = nullOr lines;
                    default = null;
                  };

                  hash = mkOption {
                    type = str;
                    default = lib.fakeHash;
                  };
                };
              })
            ];
          });

          default = [
            { depot = 232256; }
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

        fetchDepot = mkOption { type = types.raw; };
      };

    config.tf2ds.chunks = lib.importJSON ./chunks.json;

    config.tf2ds.fetchDepot = { app, depot, manifest, fileList, hash }:
      pkgs.runCommand "depot-${depot}.${manifest}"
        {
          buildInputs = [
            pkgs.cacert
            config.packages.depotdownloader
          ];

          outputHashAlgo = "sha256";
          outputHash = hash;
          outputHashMode = "recursive";

          inherit app depot manifest fileList;
          passAsFile = [ "fileList" ];
        }
        ''
          HOME=$(mktemp -d) DepotDownloader \
            -app "$app" \
            -depot "$depot" \
            -manifest "$manifest" \
            ${pkgs.lib.optionalString (fileList != null) ''-filelist "$fileListPath"''} \
            -dir "$out"

          rm -rf "$out/.DepotDownloader"
        '';

    config.packages.tf2ds = pkgs.symlinkJoin {
      name = "tf2-dedicated-server-${config.tf2ds.version}";
      inherit (config.tf2ds) version;
      paths = map config.tf2ds.fetchDepot config.tf2ds.chunks;
    };

    config.packages.prefetch-tf2ds-chunks =
      pkgs.writeShellScriptBin "prefetch-tf2ds-chunks" ''
        set -euo pipefail

        export PATH=${config.packages.depotdownloader}/bin:$PATH

        tmp=$(mktemp -d)

        ${lib.flip lib.concatImapStrings config.tf2ds.chunks (i: {app, depot, manifest, fileList, ...}: ''
          out=$tmp/${toString i}/depot-${depot}.${manifest}

          mkdir -p $out

          ${pkgs.lib.optionalString (fileList != null) ''
            fileListPath=$tmp/${toString i}/file-list.txt
            echo "${fileList}" > "$fileListPath"
          ''} 

          DepotDownloader \
            -app "${app}" \
            -depot "${depot}" \
            -manifest "${manifest}" \
            ${pkgs.lib.optionalString (fileList != null) ''-filelist "$fileListPath"''} \
            -dir "$out"

          rm -rf "$out/.DepotDownloader"

          hash=$(nix hash path "$out")

          nix store add-path "$out"

          cat > ${toString i}.json << END
          {
            "app": ${builtins.toJSON app},
            "depot": ${builtins.toJSON depot},
            "manifest": ${builtins.toJSON manifest},
            "fileList": ${builtins.toJSON fileList},
            "hash": "$hash"
          }
          END
        '')}
      '';
  };
}
