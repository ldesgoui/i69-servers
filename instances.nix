{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.tf2ds.instances;

  relay = match: {
    host = "spec-1";
    inherit (match) port stvPort;
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
      };
    });
  };

  # game-* port ranges:
  # mumble:    6900
  # match:     6901 - 6940
  # match STV: 6941 - 6980
  # other:     6981 - 6989
  # other STV: 6991 - 6999

  config.tf2ds.instances = {
    match-01 = { host = "game-2"; port = 6901; stvPort = 6941; };
    match-02 = { host = "game-2"; port = 6902; stvPort = 6942; };
    match-03 = { host = "game-2"; port = 6903; stvPort = 6943; };
    match-04 = { host = "game-2"; port = 6904; stvPort = 6944; };

    match-05 = { host = "game-3"; port = 6905; stvPort = 6945; };
    match-06 = { host = "game-3"; port = 6906; stvPort = 6946; };
    match-07 = { host = "game-3"; port = 6907; stvPort = 6947; };
    match-08 = { host = "game-3"; port = 6908; stvPort = 6948; };

    match-09 = { host = "game-4"; port = 6909; stvPort = 6949; };
    match-10 = { host = "game-4"; port = 6910; stvPort = 6950; };
    match-11 = { host = "game-4"; port = 6911; stvPort = 6951; };
    match-12 = { host = "game-4"; port = 6912; stvPort = 6952; };

    match-13 = { host = "game-5"; port = 6913; stvPort = 6953; };
    match-14 = { host = "game-5"; port = 6914; stvPort = 6954; };
    match-15 = { host = "game-5"; port = 6915; stvPort = 6955; };
    match-16 = { host = "game-5"; port = 6917; stvPort = 6956; };

    match-17 = { host = "game-6"; port = 6917; stvPort = 6957; };
    match-18 = { host = "game-6"; port = 6918; stvPort = 6958; };
    match-19 = { host = "game-6"; port = 6919; stvPort = 6959; };
    match-20 = { host = "game-6"; port = 6920; stvPort = 6960; };

    mge /***/ = { host = "game-1"; port = 6989; stvPort = 6999; };
    dm-1 /**/ = { host = "game-1"; port = 6981; stvPort = 6991; };
    dm-2 /**/ = { host = "game-1"; port = 6982; stvPort = 6992; };
    dm-3 /**/ = { host = "game-1"; port = 6983; stvPort = 6993; };

    relay-01 = relay cfg.match-01;
    # relay-02 = relay cfg.match-02;
    # relay-03 = relay cfg.match-03;
    # relay-04 = relay cfg.match-04;
    # relay-05 = relay cfg.match-05;
    # relay-06 = relay cfg.match-06;
    # relay-07 = relay cfg.match-07;
    # relay-08 = relay cfg.match-08;
    # relay-09 = relay cfg.match-09;
    # relay-10 = relay cfg.match-10;
    # relay-11 = relay cfg.match-11;
    # relay-12 = relay cfg.match-12;
    # relay-13 = relay cfg.match-13;
    # relay-14 = relay cfg.match-14;
    # relay-15 = relay cfg.match-15;
    # relay-16 = relay cfg.match-16;
    # relay-17 = relay cfg.match-17;
    # relay-18 = relay cfg.match-18;
    # relay-19 = relay cfg.match-19;
    # relay-20 = relay cfg.match-20;
  };
}
