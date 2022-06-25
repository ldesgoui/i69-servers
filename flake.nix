{
  nixConfig = {
    extra-substituters = [
      "i69-servers.cachix.org"
    ];

    extra-trusted-public-keys = [
      "i69-servers.cachix.org-1:mH3TBiferuVUu5ufo3BFlY+aCyjNGK2oPa3XXHYDnGk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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

        perSystem = { pkgs, ... }: {
          devShells.default = pkgs.mkShellNoCC {
            packages = [
              pkgs.cachix
            ];
          };
        };
      };
}
