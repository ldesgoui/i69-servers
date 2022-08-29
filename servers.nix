{ config, lib, self, inputs, ... }:
let
  rootConfig = config;
  modules = config.flake.nixosModules;
in
{
  flake.nixosModules = {
    common = { config, name, ... }: {
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

      networking.firewall = {
        allowedTCPPorts = config.services.openssh.ports;
      };

      programs.command-not-found.enable = false;

      services.openssh = {
        enable = true;
        passwordAuthentication = false;

        hostKeys = [{
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }];
      };

      system.stateVersion = "22.05";

      time.timeZone = "Europe/London";

      users.users.root = {
        initialPassword = "toor";

        openssh.authorizedKeys.keyFiles = [
          "${self}/ssh/ldesgoui.pub"
          "${self}/ssh/proto.pub"
        ];
      };
    };

    game-server = { config, modulesPath, nodes, ... }: {
      imports = [
        "${modulesPath}/virtualisation/proxmox-image.nix"
      ];

      networking = {
        useDHCP = false;
        # cloud-init provides configuration using the "default" interface names
        usePredictableInterfaceNames = false;
      };

      # Use cloud-init to set up network interfaces on boot
      services.cloud-init = {
        enable = true;
        network.enable = true;
        config = builtins.readFile "${self}/cloud.cfg";
      };
    };

    ovh-vps = { modulesPath, ... }: {
      imports = [
        "${modulesPath}/profiles/qemu-guest.nix"
      ];

      boot.loader.grub.device = "/dev/sda";

      boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" "nvme" ];

      fileSystems."/" = {
        fsType = "ext4";
        device = "/dev/sda1";
      };
    };

    mumble = { config, ... }: {
      age.secrets.gandi-creds = {
        file = "${self}/gandi-creds.age";
        owner = "acme";
      };

      networking.firewall = {
        allowedTCPPorts = [ config.services.murmur.port ];
        allowedUDPPorts = [ config.services.murmur.port ];
      };

      security.acme = {
        acceptTerms = true;

        certs."mumble.i69.tf" = {
          email = "ldesgoui@gmail.com";
          dnsProvider = "gandiv5";
          credentialsFile = config.age.secrets.gandi-creds.path;
          group = "murmur";
          reloadServices = [ "murmur" ];
        };
      };

      services.murmur =
        let
          certDir = config.security.acme.certs."mumble.i69.tf".directory;
        in
        {
          enable = true;
          bandwidth = 320000;
          bonjour = true;
          port = 6900;
          registerName = "mumble.i69.tf";
          users = 420;

          sslCert = "${certDir}/cert.pem";
          sslKey = "${certDir}/key.pem";
        };
    };
  };

  flake.colmena = {
    meta.nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

    defaults = { name, ... }: {
      deployment = {
        allowLocalDeployment = true;
      };

      imports = [
        modules.age
        modules.common
        modules.tf2ds
        self.inputs.agenix.nixosModules.age
      ]
      ++ lib.optional (lib.hasPrefix "game-" name)
        modules.game-server;

      networking.hostName = name;

      services.tf2ds.instances =
        builtins.mapAttrs (_: i: removeAttrs i [ "host" ])
          (lib.filterAttrs (_: i: i.host == name) rootConfig.tf2ds.instances);
    };

    game-1 = {
      deployment.targetHost = "10.10.11.31";

      imports = [
        modules.mumble
      ];
    };

    game-2 = { deployment.targetHost = "10.10.11.32"; };
    game-3 = { deployment.targetHost = "10.10.11.33"; };
    game-4 = { deployment.targetHost = "10.10.11.34"; };
    game-5 = { deployment.targetHost = "10.10.11.35"; };
    game-6 = { deployment.targetHost = "10.10.11.36"; };

    spec-1 = { config, name, ... }: {
      deployment = {
        targetHost = "54.36.190.233";
        targetPort = 50022;
      };

      imports = [
        modules.ovh-vps
      ];

      networking.firewall.logRefusedConnections = false;

      services.openssh.ports = [ config.deployment.targetPort ];

      age.secrets.wg-key.file = "${self}/wg/${name}.age";

      networking.wireguard = {
        enable = true;
        interfaces.wg0 = {
          ips = [ "10.10.22.4/24" "fd00::10:97:4/112" ];
          privateKeyFile = config.age.secrets.wg-key.path;
          peers = [{
            publicKey = "fhEMM8Q5HtQOHIVBQHLZfiEs7Lw9KWxRZA21uCuPVxI=";
            persistentKeepalive = 25;
            allowedIPs = [ "10.10.11.0/24" ];
            endpoint = "game-vpn.as47671.net:51820";
          }];
        };
      };

      users.users.root = {
        openssh.authorizedKeys.keyFiles = [
          "${self}/ssh/host-game-1.pub"
          "${self}/ssh/host-game-2.pub"
          "${self}/ssh/host-game-3.pub"
          "${self}/ssh/host-game-4.pub"
          "${self}/ssh/host-game-5.pub"
          "${self}/ssh/host-game-6.pub"
        ];
      };
    };
  };
}
