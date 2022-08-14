{ lib, ... }: {
  flake.nixosModules = {
    server-common = { config, modulesPath, ... }: {
      imports = [
        "${modulesPath}/virtualisation/proxmox-image.nix"
      ];

      # from modules/profiles/headless.nix
      boot.loader.grub.splashImage = null;

      documentation = {
        enable = lib.mkForce false;
        dev.enable = lib.mkForce false;
        doc.enable = lib.mkForce false;
        man.enable = lib.mkForce false;
        nixos.enable = lib.mkForce false;
      };

      networking = {
        useDHCP = false;
        # cloud-init provides configuration using the "default" interface names
        usePredictableInterfaceNames = false;
      };

      networking.firewall = {
        allowedTCPPorts = config.services.openssh.ports;
      };

      programs.command-not-found.enable = false;

      # Use cloud-init to set up network interfaces on boot
      services.cloud-init = {
        enable = true;
        network.enable = true;
      };

      services.openssh = {
        enable = true;
        passwordAuthentication = false;
      };

      system.stateVersion = "22.11";

      time.timeZone = "Europe/London";

      users.users.root = {
        initialPassword = "toor";

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK25ea20daUVvmTPmUL1nF/0DXEz/7tPBXOSerQNTf6+ me@ldesgoui.xyz"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC94Qd2XQoffOcrsEbZfwOzNPy8PZgyAchycchIohhYVnqx5EVwlBMbOBKR5VUnXXxiglFS+HvfAUmHJth5dBdnfuUr3f1wkth5w+KwjnWzIlrFW30+zsc1CsUfluUQc1kW2qx8Z/ytS28zgL/B14yEcRoTgMJBjmWkLe060lROx1VR8Elp3sRJjClTZ64o6CeM4QaxIaDd1ZL008KcAEcK1bcScpvCSfRGCUAu+TTwxz0/cyb9x21I9x67FpELlAegw3y/6A7tbpSFZY/WG+eRwrTeAXK799rzV6Brg5RadOVa3PAsxOpIjgLQ/klH+m487UNCuoNE+SiukoP3OUjh proto"
        ];
      };
    };
  };
}
