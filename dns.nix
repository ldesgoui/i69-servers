{ config, lib, inputs, ... }:

let
  inherit (inputs) dns;
  rootConfig = config;
in
{
  options.dns = {
    zone = lib.mkOption {
      type = lib.types.attrsOf dns.lib.types.zone;
    };
  };

  config.dns.zone."i69.tf" = { config, ... }:
    let
      inherit (dns.lib.combinators) letsEncrypt;
      cname = target: { CNAME = [ target ]; };

      nodes = config.subdomains.nodes.subdomains;
    in
    {
      TTL = 300;

      SOA = {
        nameServer = "ns1.gandi.net";
        adminEmail = "hostmaster@gandi.net";
        serial = 1661002392;
      };

      CAA = letsEncrypt "ldesgoui@gmail.com";

      subdomains = {
        nodes.subdomains = {
          # TODO: source of truth
          game-1.A = [ "10.10.11.31" ];
          game-2.A = [ "10.10.11.32" ];
          game-3.A = [ "10.10.11.33" ];
          game-4.A = [ "10.10.11.34" ];
          game-5.A = [ "10.10.11.35" ];
          game-6.A = [ "10.10.11.36" ];
          spec-1.A = [ "54.36.190.233" ];
        };

        mumble.SRV =
          let
            f = priority: target: {
              service = "mumble";
              proto = "tcp";
              port = 6900;
              inherit priority target;
            };
          in
          lib.imap1 f [
            "game-3.nodes"
            "game-2.nodes"
            "game-1.nodes"
          ];
      }
      // lib.mapAttrs (name: { host, ... }: cname "${host}.nodes") rootConfig.tf2ds.instances;
    };

  config.perSystem = { pkgs, system, ... }: {
    packages.dns-zones = lib.pipe config.dns.zone [
      (lib.mapAttrsToList (name: zone: pkgs.writeTextFile {
        name = "${name}.zone";
        text = toString zone;
      }))
      (pkgs.linkFarmFromDrvs "dns-zones")
    ];
  };
}
