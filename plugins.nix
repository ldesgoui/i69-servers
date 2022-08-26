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
          url = "https://github.com/ETF2L/gameserver-configs/releases/download/1.0.6/etf2l_configs.zip";
          sha256 = "sha256-s8td1M9+f0TmEhAgP78ezlr0WNMJ33FLM4XFnLPXN7c=";
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

    # steamworks = pkgs.runCommand "steamworks"
    #   {
    #     src = pkgs.fetchzip {
    #       url = "https://github.com/hexa-core-eu/SteamWorks/releases/download/v1.2.3/package-linux.zip";
    #       sha256 = "sha256-7QhhnbAUorR5y47BJAo9Eey3R290biKZfwYpwe78BV0=";
    #     };
    #   }
    #   ''
    #     mkdir -p $out/tf
    #     cp -r $src/package/addons $out/tf/
    #   '';

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
          url = "https://github.com/sapphonie/SOAP-TF2DM/releases/download/v4.4.6/soap.zip";
          sha256 = "sha256-ufmKdfRBPWyWa2waWKlg+H2LzkteFQjGOxUEVLHW6nM=";
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

    logstf = pkgs.runCommand "logstf"
      {
        src = pkgs.fetchzip {
          url = "http://sourcemod.krus.dk/logstf.zip";
          sha256 = "sha256-QSwMq8penOKacFb2pvY5kbJ7CWjJPBCYaZUHAahnycY=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        cp -r $src/. $out/tf/addons/sourcemod/plugins/
      '';

    sup-stats = pkgs.runCommand "supstats2"
      {
        src = pkgs.fetchzip {
          url = "http://sourcemod.krus.dk/supstats2.zip";
          sha256 = "sha256-Y/lpVP0nV6XWg/scLnk4S1+q5qIOrF3CUmwvGD9vTeE=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        cp -r $src/. $out/tf/addons/sourcemod/plugins/
      '';

    medic-stats = pkgs.runCommand "medicstats"
      {
        src = pkgs.fetchzip {
          url = "http://sourcemod.krus.dk/medicstats.zip";
          sha256 = "sha256-hkp07m60AQCDbL8yu0xrTh6mGTCwcehFsSI1F8JSTo0=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        cp -r $src/. $out/tf/addons/sourcemod/plugins/
      '';

    record-stv = pkgs.runCommand "recordstv"
      {
        src = pkgs.fetchzip {
          url = "http://sourcemod.krus.dk/recordstv.zip";
          sha256 = "sha256-1flr1F4WydqTdmEzKpIOuEU6uMy19edMIEcQGmrgg2k=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        cp -r $src/. $out/tf/addons/sourcemod/plugins/
      '';

    afk-detector = pkgs.runCommand "afk"
      {
        src = pkgs.fetchzip {
          url = "http://sourcemod.krus.dk/afk.zip";
          sha256 = "sha256-PdYX+B/TmAxmQInyQ0EOIZQ0RjO0OkpdlNIfD8cx164=";
        };
      }
      ''
        mkdir -p $out/tf/addons/sourcemod/plugins
        cp -r $src/. $out/tf/addons/sourcemod/plugins/
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

    # This is fine.
    maps = pkgs.linkFarm "maps" (
      lib.mapAttrsToList
        (name: hash: {
          name = "tf/maps/${name}.bsp";
          path = pkgs.fetchurl {
            url = "https://dl.serveme.tf/maps/${name}.bsp";
            inherit hash;
          };
        })
        {
          cp_granary_pro_rc8 = "sha256-C9aOrbrBMarhNVGHov8UMo82dfYWms+wr+wA9M2k4Qc=";
          cp_gullywash_f9 = "sha256-BgaQbICXVuP0ChFrZtIi7ZKQc/Y2+cOxssXbv5y8mls=";
          cp_metalworks_f4 = "sha256-Ny0QfDUnbhVyLVyiVdW2y0Yv0OMiMWUDKo4ocdUd6HI=";
          cp_process_f11 = "sha256-vafHG1dTDTGouu5BlxiStLgD0v+BFHGzfz52YkN+hM4=";
          cp_snakewater_final1 = "sha256-YX1Ihx65bfyPZECp6O60GpR0Sq/YHfVh5/meEbZ3lXE=";
          cp_sunshine = "sha256-yprX0B9GESq7xbAvPRRPrYM+ag/zvYKh//OPqNPDJHQ=";
          koth_product_final = "sha256-82zj1DN3zHhoIcQ+RMzIjulUm3yzDW55PTFhNMa1mwM=";
        }
    );
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
