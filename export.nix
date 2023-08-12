{ config, lib, ... }:
let
  out =
    lib.pipe config.tf2ds.instances [
      (lib.mapAttrsToList (name: opts: rec {
        inherit name;
        inherit (opts) host port stvPort;
        hostname = "${name}.i71.tf";
      }))
      (lib.partition (x: lib.hasPrefix "match-" x.name))
      (xs: xs.right ++ xs.wrong)
    ];
in
{
  perSystem = { pkgs, ... }: {
    packages.export-server-connects = pkgs.writeShellScriptBin "export-server-connects" ''
      echo '"Server ID","Current Use","Connect","STV Connect","RCON","Relay Command"'
      ${lib.getExe pkgs.jq} -r --slurpfile pw ./passwords.json '
        .[] | $pw[0][.name] as $pw | [
          .name,
          "",
          "connect \(.hostname)"
            + if .port != 27015 then ":\(.port)" else "" end
            + if $pw.sv_password then "; password \($pw.sv_password)" else "" end,
          "connect \(.hostname):\(.stvPort)"
            + if $pw.tv_password then "; password \($pw.tv_password)" else "" end,
          if $pw.rcon_password then "rcon_address \(.hostname):\(.port); rcon_password \($pw.rcon_password)" else "" end,
          "rcon tv_relay \"\(.hostname):\(.stvPort)\"" + if $pw.tv_relaypassword then "; rcon password \"\($pw.tv_relaypassword)\"" else "" end
        ] | @csv
      ' ${pkgs.writeText "out.json" (builtins.toJSON out)}
    '';
  };
}
