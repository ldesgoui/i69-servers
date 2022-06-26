{ lib, pkgs, ... }:
let
  wantedVersion = "2.4.6";
in
{
  packages.depotdownloader =
    if lib.versionOlder wantedVersion pkgs.depotdownloader.version
    then
      pkgs.depotdownloader
    else
      pkgs.buildDotnetModule {
        pname = "depotdownloader";
        version = wantedVersion;

        src = pkgs.fetchFromGitHub {
          owner = "SteamRE";
          repo = "DepotDownloader";
          rev = "DepotDownloader_${wantedVersion}";
          sha256 = "sha256-wjRoi7zox3lF/blA9cva2uzgl4omm64izvo+KnPjJHE=";
        };

        projectFile = "DepotDownloader.sln";
        nugetDeps = ./depotdownloader-deps.nix;
      };
}
