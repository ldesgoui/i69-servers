{ config, lib, pkgs, ... }: {
  options.tf2ds =
    let
      inherit (lib) mkOption types;
    in
    {
      plugins = mkOption {
        type = types.lazyAttrsOf types.package;
      };
    };

  config.tf2ds.plugins = {
    mms = pkgs.runCommand "metamod-source"
      {
        src = pkgs.fetchzip {
          url = "https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1147-linux.tar.gz";
          sha256 = "sha256-dg2r5G9aCDb3lX4WQFSYqk7Zi/e7NkOggtgXl3+CA0M=";
        };
      }
      ''
        mkdir -p $out/tf/addons
        ${pkgs.xorg.lndir}/bin/lndir -silent $src $out/tf/addons/
      '';

    sm = pkgs.runCommand "sourcemod"
      {
        src = pkgs.fetchzip {
          url = "https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6544-linux.tar.gz";
          sha256 = "sha256-k7yFbGM22FM1M6cz+R5BKg5ptUzf2sd1l5MR7jLB50I=";
          stripRoot = false;
        };
      }
      ''
        mkdir -p $out/tf
        ${pkgs.xorg.lndir}/bin/lndir -silent $src $out/tf/
      '';

    dhooks = pkgs.runCommand "dhooks"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/peace-maker/DHooks2/releases/download/v2.2.0-detours17/dhooks-2.2.0-detours17-sm110.zip";
          sha256 = "sha256-LOFTaXalpm0fC1ZOG81RZHWcU1eGk0/p/ItdGuShy8Y=";
        };
      }
      ''
        mkdir -p $out/tf/addons/
        ${pkgs.xorg.lndir}/bin/lndir -silent $src $out/tf/addons/
      '';

    tf2-comp-fixes = pkgs.runCommand "tf2-comp-fixes"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/ldesgoui/tf2-comp-fixes/releases/download/v1.16.10/tf2-comp-fixes.zip";
          sha256 = "sha256-YzNyz/eq1rDdNojtsn0bmFPPC3KFrpk6Ac+ywqIjL0g=";
        };
      }
      ''
        mkdir -p $out/tf/addons/
        ${pkgs.xorg.lndir}/bin/lndir -silent $src $out/tf/addons/
      '';

    soap-dm = pkgs.runCommand "soap-dm"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/sapphonie/SOAP-TF2DM/releases/download/v4.4.5/soap.zip";
          sha256 = "sha256-M01Lsxc4o85mkOFUTGVIq7zW23fMovm7kOZnOQzAbMs=";
          stripRoot = false;
        };
      }
      ''
        mkdir -p $out/tf
        ${pkgs.xorg.lndir}/bin/lndir -silent $src $out/tf
      '';

    mgemod = pkgs.runCommand "mgemod"
      {
        src = pkgs.fetchFromGitHub {
          owner = "sapphonie";
          repo = "MGEMod";
          rev = "4cd33e59c1ca879fdeaf6d3374d4f860d33c6aa2";
          sha256 = "sha256-J0VFmeOwlPMbCmB0tHPjUwWEQrCiE0/bZDaDR4OZeNY=";
        };
      }
      ''
        mkdir -p $out/tf/{addons,maps}
        ${pkgs.xorg.lndir}/bin/lndir -silent $src/addons $out/tf/addons
        ${pkgs.xorg.lndir}/bin/lndir -silent $src/maps $out/tf/maps
      '';

    srctvplus = pkgs.runCommand "srctvplus"
      {
        so = pkgs.fetchurl {
          url = "https://github.com/dalegaard/srctvplus/releases/download/v2.0/srctvplus.so";
          sha256 = "sha256-Irl09DA2w2w2t9gZqEkE+ykSltIsVfRGMRZEXJVMZj8=";
        };
        vdf = pkgs.fetchurl {
          url = "https://github.com/dalegaard/srctvplus/releases/download/v2.0/srctvplus.vdf";
          sha256 = "sha256-Y1C0TvL82GJXQqUdvkudWN3qs2Gn8sJFJKa+lef1xfw=";
        };
      }
      ''
        mkdir -p $out/tf/addons
        ln -s $so $out/tf/addons/srctvplus.so
        ln -s $vdf $out/tf/addons/srctvplus.vdf
      '';


    etf2l-configs = pkgs.runCommand "etf2l-configs"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/ETF2L/gameserver-configs/releases/download/1.0.5/etf2l_configs.zip";
          sha256 = "sha256-aAi4Q88wlEkrgygViqFzUcRw0kKmELGOt4/9GQ0xesA=";
          stripRoot = false;
        };
      }
      ''
        mkdir -p $out/tf/cfg
        ${pkgs.xorg.lndir}/bin/lndir -silent $src $out/tf/cfg
      '';


    curl = pkgs.runCommand "curl"
      {
        src = pkgs.fetchzip {
          url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/sourcemod-curl-extension/curl_1.3.0.0.zip";
          sha256 = "sha256-fqXnS0Ef9R9owtjzOb830nrRy1UTfe3DHtxpjUY4Iec=";
          stripRoot = false;
        };
        so = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/spiretf/docker-comp-server/3d661a220be5186a5a2a86c5020a8fed976f2908/curl.ext.so";
          sha256 = "sha256-nDx/05NG57w757uG6LKfz++3A3euiOGdPpicsdcNmWE=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod
        ${pkgs.xorg.lndir}/bin/lndir -silent $src $out/tf/addons/sourcemod
        ln -sf $so $out/tf/addons/sourcemod/extensions/curl.ext.so
      '';

    demostf = pkgs.runCommand "demostf"
      {
        src = pkgs.fetchurl {
          url = "https://github.com/demostf/plugin/raw/241d1136eb0c786ca7609ba92f70888c422e3fd0/demostf.smx";
          sha256 = "sha256-3NNXe4/pvga5G4hqgeBfcgNiopg3O1zghAhXU8b6npY=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        ln -s $src $out/tf/addons/sourcemod/plugins/demostf.smx
      '';

    mapdownloader = pkgs.runCommand "mapdownloader"
      {
        src = pkgs.fetchurl {
          url = "https://github.com/spiretf/mapdownloader/raw/796f13f32b5632e244ec5622d6deb03a368568b6/plugin/mapdownloader.smx";
          sha256 = "sha256-nPvNLWrAtcgkdUPSKyiAxvyvrL98c6oqKwWjUIscTck=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        ln -s $src $out/tf/addons/sourcemod/plugins/mapdownloader.smx
      '';

    improved-round-timer = pkgs.runCommand "improved-round-timer"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/b4nnyBot/TF2-Improved-Round-Timer-Plugin/raw//942d87e714d426100622afc4dabde8b3c7314adc/Round%20Timer%20Override%20Plugin.zip";
          sha256 = "sha256-bcp6EdZiJeopY67KaqvJGGYyElyQAkHw6vHzdwZbdBs=";
          stripRoot = false;
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        ln -s $src/roundtimer_override.smx $out/tf/addons/sourcemod/plugins/
      '';
  };

  packages.tf2ds-with-plugins = pkgs.symlinkJoin {
    name = "tf2-dedicated-server-with-plugins-${config.tf2ds.version}";
    inherit (config.tf2ds) version;
    paths = [ config.packages.tf2ds ]
      ++ (lib.flip lib.getAttrs config.tf2ds.plugin [
      "mms"
      "sm"
    ]);
  };
}
