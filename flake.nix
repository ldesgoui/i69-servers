{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      ({ config, ... }:
        let
          rootConfig = config;
        in
        {
          systems = [ "x86_64-linux" ];

          imports = [
            ./dns.nix
            ./export.nix
            ./instances.nix
            ./servers.nix
            ./service.nix
          ];

          perSystem = { lib, pkgs, inputs', ... }: {
            imports = [
              ./package-tf2ds.nix
              ./plugins.nix
              ./run-tf2ds.nix
            ];

            options.tf2ds.lib = lib.mkOption { type = lib.types.anything; };

            config.packages.vma =
              let
                nixos = pkgs.nixos {
                  imports = [
                    rootConfig.flake.nixosModules.common
                    rootConfig.flake.nixosModules.game-server
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

            config.devShells.default = pkgs.mkShellNoCC {
              packages = [
                pkgs.colmena

                pkgs.age
                inputs'.agenix-cli.packages.agenix-cli

                pkgs.knot-dns

                pkgs.rcon
              ];
            };
          };
        });

}
