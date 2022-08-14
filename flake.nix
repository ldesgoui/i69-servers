{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; }
      ({ config, ... }:
        let
          rootConfig = config;
        in
        {
          systems = [ "x86_64-linux" ];

          imports = [
            ./servers.nix
          ];

          perSystem = { lib, pkgs, ... }: {
            imports = [
              ./depotdownloader.nix
              ./package-tf2ds.nix
              ./plugins.nix
              ./run-tf2ds.nix
            ];

            options.tf2ds.lib = lib.mkOption { type = lib.types.anything; };

            config.packages.vma =
              let
                nixos = pkgs.nixos {
                  imports = [
                    rootConfig.flake.nixosModules.server-common
                  ];

                  proxmox = {
                    qemuConf = rec {
                      cores = 5;
                      memory = cores * 4 * 1024;
                      name = "i69-servers-firestarter";
                    };
                  };
                };
              in
              nixos.VMA;
          };
        });

}
