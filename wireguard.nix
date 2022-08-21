{ config, lib, self, ... }:
let
  inherit (lib) mkOption types;
  rootConfig = config;
in
{
  options.wireguard-peers = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        ip = mkOption {
          type = types.str;
        };

        endpoint = mkOption {
          type = types.nullOr (types.submodule {
            options = {
              host = mkOption {
                type = types.str;
              };

              port = mkOption {
                type = types.port;
              };
            };
          });

          default = null;
        };
      };
    });
  };

  config.wireguard-peers = {
    game-1 = { ip = "10.69.0.1"; };
    game-2 = { ip = "10.69.0.2"; };
    game-3 = { ip = "10.69.0.3"; };
    game-4 = { ip = "10.69.0.4"; };
    game-5 = { ip = "10.69.0.5"; };
    game-6 = { ip = "10.69.0.6"; };

    spec-1 = {
      ip = "10.69.0.101";
      endpoint = {
        host = "spec-1.nodes.i69.tf";
        port = 51820;
      };
    };
  };

  config.flake.nixosModules.wireguard = { config, pkgs, name, ... }:
    let
      peers = rootConfig.wireguard-peers;
      not-me = lib.filterAttrs (n: _: name != n) peers;
    in
    {
      deployment.keys = {
        ssh_host_ed25519_key = {
          keyCommand = [ (lib.getExe pkgs.rage) "-i" "${self}/root.age" "-d" "${self}/ssh/host-${name}.age" ];
          destDir = "/etc/ssh";
          uploadAt = "post-activation";
        };

        "ssh_host_ed25519_key.pub" = {
          keyFile = "${self}/ssh/host-${name}.pub";
          destDir = "/etc/ssh";
          uploadAt = "post-activation";
        };
      };

      age.secrets.wg-key.file = "${self}/wg/${name}.age";

      networking.wireguard = {
        enable = true;
        interfaces.wg69 = {
          ips = [ "10.69.0.0/24" ];
          listenPort = peers.${name}.endpoint.port or null;
          privateKeyFile = config.age.secrets.wg-key.path;
          peers = lib.mapAttrsToList
            (peer-name: peer: {
              publicKey = lib.removeSuffix "\n" (builtins.readFile "${self}/wg/${peer-name}.pub");
              persistentKeepalive = 25;
              allowedIPs = [ peer.ip ];
              endpoint =
                if peer.endpoint != null then
                  "${peer.endpoint.host}:${toString peer.endpoint.port}"
                else
                  null;
            })
            not-me;
        };
      };
    };
}
