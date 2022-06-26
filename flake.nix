{
  nixConfig = {
    extra-substituters = [
      "https://i69-servers.cachix.org"
    ];

    extra-trusted-public-keys = [
      "i69-servers.cachix.org-1:mH3TBiferuVUu5ufo3BFlY+aCyjNGK2oPa3XXHYDnGk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; }
      {
        systems = [ "x86_64-linux" ];

        perSystem = { lib, pkgs, ... }: {
          imports = [
            ./depotdownloader.nix
            ./package-tf2ds.nix
            ./run-tf2ds.nix
          ];

          options.tf2ds.lib = lib.mkOption { type = lib.types.anything; };

          config.devShells.default = pkgs.mkShellNoCC {
            packages = [
              pkgs.cachix
            ];
          };
        };
      };
}
