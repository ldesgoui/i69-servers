{ config, lib, pkgs, ... }: {
  options.tf2ds =
    let
      inherit (lib) mkOption types;
    in
    {
      addons = mkOption {
        type = types.lazyAttrsOf types.package;
      };

      configs = mkOption {
        type = types.lazyAttrsOf types.package;
      };

      plugins = mkOption {
        type = types.lazyAttrsOf types.package;
      };
    };

  config.tf2ds.addons = {
    mms = pkgs.runCommand "metamod-source"
      {
        src = pkgs.fetchzip {
          url = "https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1147-linux.tar.gz";
          sha256 = "sha256-AcsHetmsoxuWhAoyiaOxslKDmTH+yeVF/8r7x6OH1yM=";
        };
      }
      ''
        mkdir -p $out/tf/addons
        cp -r $src/. $out/tf/addons
      '';

    srctvplus = pkgs.runCommand "srctvplus"
      {
        so = pkgs.fetchurl {
          url = "https://github.com/dalegaard/srctvplus/releases/download/v2.0/srctvplus.so";
          sha256 = "sha256-KoFLjTQXY1nDzdG3x7eU/nTcmEqSH7tdqxFNyI2WCRg=";
        };

        vdf = pkgs.fetchurl {
          url = "https://github.com/dalegaard/srctvplus/releases/download/v2.0/srctvplus.vdf";
          sha256 = "sha256-iGKHyREgDB8vDv/CMv0BdAzAkTzZJyP98nzzxShUvro=";
        };
      }
      ''
        mkdir -p $out/tf/addons
        cp $so $out/tf/addons/srctvplus.so
        cp $vdf $out/tf/addons/srctvplus.vdf
      '';
  };

  config.tf2ds.configs = {
    etf2l-configs = pkgs.runCommand "etf2l-configs"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/ETF2L/gameserver-configs/releases/download/1.0.5/etf2l_configs.zip";
          sha256 = "sha256-dZyeh9B7EBweQHjswpb7KtRspJ3nmYRQ5ASNPUpZnlo=";
          stripRoot = false;
        };
      }
      ''
        mkdir -p $out/tf/cfg
        cp -r $src/. $out/tf/cfg
      '';

    our-configs = pkgs.runCommand "our-configs" { } ''
      mkdir -p $out/tf/cfg
      cp -r ${./cfg}/. $out/tf/cfg
    '';
  };

  config.tf2ds.plugins = {
    sm = pkgs.runCommand "sourcemod"
      {
        src = pkgs.fetchzip {
          url = "https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6544-linux.tar.gz";
          sha256 = "sha256-pdIstFAztwbK361Xnb1DKGawGf5olFI9mM8BV/fIf9o=";
          stripRoot = false;
        };
      }
      ''
        mkdir -p $out/tf
        cp -r $src/. $out/tf/
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
        cp -r $src/. $out/tf/addons/
      '';

    steamworks = pkgs.runCommand "steamworks"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/KyleSanderson/SteamWorks/releases/download/1.2.3c/package-lin.tgz";
          sha256 = "sha256-/q7JMSrzCL77qn/q2zcqtNZem5Z0hRsHtK6UynXSxr4=";
        };
      }
      ''
        mkdir -p $out/tf
        cp -r $src/. $out/tf/
      '';

    curl = pkgs.runCommand "curl"
      {
        so = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/spiretf/docker-comp-server/3d661a220be5186a5a2a86c5020a8fed976f2908/curl.ext.so";
          sha256 = "sha256-nDx/05NG57w757uG6LKfz++3A3euiOGdPpicsdcNmWE=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/extensions
        cp $so $out/tf/addons/sourcemod/extensions/curl.ext.so
      '';

    tf2-comp-fixes = pkgs.runCommand "tf2-comp-fixes"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/ldesgoui/tf2-comp-fixes/releases/download/v1.16.10/tf2-comp-fixes.zip";
          sha256 = "sha256-7nuHm0XdhK5sP7qHf1XQyrrrmYxGT8NJYDKRzRRV2ks=";
        };
      }
      ''
        mkdir -p $out/tf/addons/
        cp -r $src/. $out/tf/addons/
      '';

    soap-dm = pkgs.runCommand "soap-dm"
      {
        src = pkgs.fetchzip {
          url = "https://github.com/sapphonie/SOAP-TF2DM/releases/download/v4.4.5/soap.zip";
          sha256 = "sha256-7nk92SAkNAzOg1OaP9Zg61QnHgUpYxBWhyLqFL2Jvac=";
          stripRoot = false;
        };
      }
      ''
        mkdir -p $out/tf
        cp -r $src/. $out/tf
      '';

    mgemod = pkgs.runCommand "mgemod"
      {
        src = pkgs.fetchFromGitHub {
          owner = "sapphonie";
          repo = "MGEMod";
          rev = "4cd33e59c1ca879fdeaf6d3374d4f860d33c6aa2";
          sha256 = "sha256-hHwemZ1cWL0kR6KvrSEks/MgPSe5dMuwPzemN6we1ak=";
        };
      }
      ''
        mkdir -p $out/tf/{addons,maps}
        cp -r $src/addons/. $out/tf/addons
        cp -r $src/maps/. $out/tf/maps
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
        cp $src $out/tf/addons/sourcemod/plugins/demostf.smx
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
        cp $src $out/tf/addons/sourcemod/plugins/mapdownloader.smx
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
        cp $src/roundtimer_override.smx $out/tf/addons/sourcemod/plugins/
      '';
  };

  config.packages = {
    all-addons = pkgs.symlinkJoin {
      name = "all-addons";
      paths = builtins.attrValues config.tf2ds.addons;
    };

    all-configs = pkgs.symlinkJoin {
      name = "all-configs";
      paths = builtins.attrValues config.tf2ds.configs;
    };

    all-plugins = pkgs.symlinkJoin {
      name = "all-plugins";
      paths = builtins.attrValues config.tf2ds.plugins;
    };
  };
}
