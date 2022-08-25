{ config, lib, self, ... }:
let
  packages = config.flake.packages.x86_64-linux;

  # TODO: dry
  toArgs = args @ { commands ? [ ], ... }:
    lib.escapeShellArgs
      (lib.cli.toGNUCommandLine
        { mkOptionName = k: "-${k}"; }
        (builtins.removeAttrs args [ "commands" ])
      ++ (map (c: "+${c}") commands));
in
{
  flake.nixosModules = {
    tf2ds = { config, lib, pkgs, ... }:
      let
        inherit (lib)
          mkOption
          types
          ;

        cfg = config.services.tf2ds;

        mkService = name: opts:
          let
            args = {
              game = "tf";
              ip = "0.0.0.0";
              scriptportbind = true;
              inherit (opts) port;
            }
            // opts.args
            // {
              commands = [
                ''hostname "i69.tf - ${name}"''
                "tv_port ${toString opts.stvPort}"
                "clientport ${toString (50000 + opts.port)}"
              ]
              ++ opts.args.commands;
            };
          in
          {
            "tf2ds-${name}" = {
              description = "Team Fortress 2 Dedicated Server - ${name}";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              inherit (opts) restartIfChanged;

              preStart = ''
                mkdir -p tf/{addons,cfg} .steam/sdk32
                ${pkgs.findutils}/bin/find . -type l -delete

                ln -fns ${packages.gameinfo} tf/gameinfo.txt
                ln -fns ${packages.tf2ds}/bin/steamclient.so .steam/sdk32/
                ln -fns ${config.age.secrets."apikeys.cfg".path} tf/cfg/

                ${lib.getExe pkgs.jq} -r --arg name "${name}" '
                  .[$name] | to_entries[] | "\(.key) \"\(.value)\""
                ' ${config.age.secrets."passwords.json".path} > tf/cfg/passwords.cfg

                ${lib.getExe pkgs.xorg.lndir} -silent ${packages.all-plugins} ./
              '';

              script = ''
                HOME=$STATE_DIRECTORY \
                LD_LIBRARY_PATH=${packages.tf2ds}/bin:${pkgs.pkgsi686Linux.ncurses5}/lib \
                exec -a "$STATE_DIRECTORY"/srcds_linux \
                  ${packages.tf2ds}/srcds_linux \
                    ${toArgs args}
              '';

              serviceConfig = {
                ExecStop = "${lib.getExe pkgs.rcon} -H 127.0.0.1 -p ${opts.port} -P $(${lib.getExe pkgs.jq} -r --arg name "${name}" '.[$name].rcon_password' ${config.age.secrets."passwords.json".path}) 'quit'";

                Restart = "always";

                DynamicUser = "true";
                SupplementaryGroups = "tf2ds";
                StateDirectory = "tf2ds/${name}";
                WorkingDirectory = "%S/tf2ds/${name}";
              };
            };
          };
      in
      {
        options.services.tf2ds = {
          instances = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                port = mkOption { type = types.port; };
                stvPort = mkOption { type = types.port; };

                restartIfChanged = mkOption {
                  type = types.bool;
                  default = false;
                };

                args = mkOption {
                  type = types.raw;
                  default = {
                    commands = [
                      "sv_pure 2"
                      "map itemtest"
                    ];
                  };
                };
              };
            });

            default = { };
          };
        };

        config = {
          age.secrets = {
            "apikeys.cfg" = {
              file = "${self}/cfg/apikeys.cfg.age";
              mode = "0440";
              group = "tf2ds";
            };

            "passwords.json" = {
              file = "${self}/passwords.json.age";
              mode = "0440";
              group = "tf2ds";
            };
          };

          networking.firewall = lib.mkMerge (
            lib.mapAttrsToList
              (_: opts: {
                allowedTCPPorts = [ opts.port ];
                allowedUDPPorts = [ opts.port opts.stvPort ];
              })
              cfg.instances
          );

          systemd.services = lib.mkMerge (
            lib.mapAttrsToList mkService cfg.instances
          );

          users.groups.tf2ds = { };
        };
      };
  };
}
