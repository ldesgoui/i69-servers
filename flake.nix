{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; }
      {
        systems = [ "x86_64-linux" ];
      };
}
