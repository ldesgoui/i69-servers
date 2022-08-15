{ config, lib, self, inputs, ... }: {
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

      i18n.supportedLocales = lib.mkForce [ "en_US.UTF-8/UTF-8" ];

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

        openssh.authorizedKeys.keyFiles = [
          "${self}/ssh/ldesgoui.pub"
          "${self}/ssh/proto.pub"
        ];
      };
    };
  };
}
