{ self, ... }: {
  flake.nixosModules.age = { config, lib, pkgs, name, ... }: {
    deployment.keys = {
      ssh_host_ed25519_key = {
        keyCommand = [ (lib.getExe pkgs.rage) "-i" "${self}/root.age" "-d" "${self}/ssh/host-${name}.age" ];
        destDir = "/etc/ssh";
        uploadAt = "post-activation";
      };

      "ssh_host_ed25519_key.pub" = {
        keyFile = "${self}/ssh/host-${name}.pub";
        destDir = "/etc/ssh";
        uploadAt = "post-activation";
      };
    };
  };
}

