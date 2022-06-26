{
  nixConfig = {
    extra-substituters = [
      "https://i69-servers.cachix.org"
      "https://nixpkgs-unfree.cachix.org"
    ];

    extra-trusted-public-keys = [
      "i69-servers.cachix.org-1:mH3TBiferuVUu5ufo3BFlY+aCyjNGK2oPa3XXHYDnGk="
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:numtide/nixpkgs-unfree/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; }
      {
        systems = [ "x86_64-linux" ];

        imports = [
          ./depotdownloader.nix
          ./package-tf2ds.nix
        ];

        perSystem = { lib, pkgs, ... }: {
          options.tf2ds.lib = lib.mkOption { type = lib.types.anything; };

          config.devShells.default = pkgs.mkShellNoCC {
            packages = [
              pkgs.cachix
            ];
          };
        };
      };
}
