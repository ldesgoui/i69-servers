{ config, ... }:
let
  rootConfig = config;
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

        perInstance = name: opts: {
          systemd.services."tf2ds-${name}" = {
            description = "Team Fortress 2 Dedicated Server - ${name}";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            inherit (opts) restartIfChanged;

            preStart = ''
              mkdir -p {tf/addons,.steam/sdk32}
              ${pkgs.findutils}/bin/find . -type l -delete

              ln -fns ${rootConfig.packages.gameinfo} tf/gameinfo.txt
              ln -fns ${rootConfig.packages.tf2ds}/bin/steamclient.so .steam/sdk32/

              ${lib.getExe pkgs.xorg.lndir} -silent ${rootConfig.packages.all-plugins} ./
            '';

            script = ''
              HOME=$STATE_DIRECTORY \
              LD_LIBRARY_PATH=${rootConfig.packages.tf2ds}/bin:${pkgs.pkgsi686Linux.ncurses5}/lib \
              exec -a "$STATE_DIRECTORY"/srcds_linux \
                ${rootConfig.packages.tf2ds}/srcds_linux \
                  ${rootConfig.tf2ds.lib.toArgs {
                    game = "tf";
                    ip = "0.0.0.0";
                    maxplayers = 24;
                    commands = [
                      "sv_pure 2"
                      "map itemtest"
                    ];
                    # TODO password, rcon
                    # TODO port, stvport, clientport, strictportbind
                    # TODO tv_enable, tv_password
                  }}
            '';

            serviceConfig = {
              Restart = "always";

              DynamicUser = "true";
              StateDirectory = "tf2ds/${name}";
              WorkingDirectory = "%S/tf2ds/${name}";
            };
          };

          networking.firewall = {
            allowedTCPPorts = [ opts.port ];
            allowedUDPPorts = [ opts.port opts.stvPort ];
          };
        };
      in
      {
        options.services.tf2ds = {
          enabled = mkOption {
            type = types.boolean;
            default = true;
          };

          instances = mkOption {
            type = types.attrsOf (types.submodule {
              options.port = mkOption { type = types.port; };
              options.stvPort = mkOption { type = types.port; };

              options.restartIfChanged = mkOption {
                type = types.boolean;
                default = false;
              };
            });

            default = { };
          };
        };

        config = lib.mkIf cfg.enabled (lib.mkMerge (
          lib.mapAttrsToList perInstance cfg.instances
        ));
      };

    tf2ds-matches = {
      services.tf2ds.instances = {
        match-1 = { port = 6901; stvPort = 6906; };
        match-2 = { port = 6902; stvPort = 6907; };
        match-3 = { port = 6903; stvPort = 6908; };
        match-4 = { port = 6904; stvPort = 6909; };
      };
    };
  };
}
