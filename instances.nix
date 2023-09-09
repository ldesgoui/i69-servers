{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.tf2ds.instances;

  dm = {
    port = 27015;
    restartIfChanged = true;
    args.maxplayers = 8;
    args.commands = [
      "sv_pure 2"
      "exec dm"
      "map itemtest_dm"
    ];
  };
in
{
  options.tf2ds.instances = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        host = mkOption {
          type = types.str;
        };

        port = mkOption {
          type = types.port;
        };

        stvPort = mkOption {
          type = types.port;
        };

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
  };

  # game-* port ranges:
  # mumble:    6900
  # match:     6901 - 6940
  # match STV: 6941 - 6980
  # other:     27015
  # other STV: 6991 - 6999

  config.tf2ds.instances = {
    match-01 = { host = "game-1"; port = 6901; stvPort = 6941; };
    match-02 = { host = "game-1"; port = 6902; stvPort = 6942; };
    match-03 = { host = "game-1"; port = 6903; stvPort = 6943; };

    match-04 = { host = "game-2"; port = 6904; stvPort = 6944; };
    match-05 = { host = "game-2"; port = 6905; stvPort = 6945; };
    match-06 = { host = "game-2"; port = 6906; stvPort = 6946; };

    match-07 = { host = "game-3"; port = 6907; stvPort = 6947; };
    match-08 = { host = "game-3"; port = 6908; stvPort = 6948; };
    match-09 = { host = "game-3"; port = 6909; stvPort = 6949; };

    match-10 = { host = "game-4"; port = 6910; stvPort = 6950; };
    match-11 = { host = "game-4"; port = 6911; stvPort = 6951; };
    match-12 = { host = "game-4"; port = 6912; stvPort = 6952; };

    match-13 = { host = "game-5"; port = 6913; stvPort = 6953; };
    match-14 = { host = "game-5"; port = 6914; stvPort = 6954; };
    match-15 = { host = "game-5"; port = 6915; stvPort = 6955; };

    match-16 = { host = "game-6"; port = 6916; stvPort = 6956; };
    match-17 = { host = "game-6"; port = 6917; stvPort = 6957; };
    match-18 = { host = "game-6"; port = 6918; stvPort = 6958; };

    dm-1 = { host = "game-1"; stvPort = 6991; } // dm;
    dm-2 = { host = "game-2"; stvPort = 6992; } // dm;
    dm-3 = { host = "game-3"; stvPort = 6993; } // dm;
    dm-4 = { host = "game-4"; stvPort = 6994; } // dm;
    # dm-5 = { host = "game-5"; stvPort = 6995; } // dm;

    pub = {
      host = "game-5";
      port = 27015;
      stvPort = 6998;
      args.unrestricted_maxplayers = true;
      args.maxplayers = 100;
      args.commands = [
        "exec pub"
        "map pl_badwater"
      ];
    };

    mge = {
      host = "game-6";
      port = 27015;
      stvPort = 6999;
      # restartIfChanged = true;
      args.commands = [
        "sv_pure 2"
        "exec mge"
        "map itemtest"
      ];
    };
  };
}
