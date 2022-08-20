{ config, lib, self, inputs, ... }:
let
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

    wireguard = { config, name, ... }: {
      deployment.keys = {
        ssh_host_ed25519_key = {
          keyCommand = [ "age" "-i" "/home/ldesgoui/.ssh/id_ed25519" "-d" "ssh/host-${name}.age" ];
          destDir = "/etc/ssh";
        };
      };

      age.secrets.wg-key.file = "${self}/wg/${name}.age";

      networking.wireguard = {
        enable = true;
        interfaces.wg69 = {
          ips = [ "10.69.0.0/24" ];
          listenPort = 51820;
          privateKeyFile = config.age.secrets.wg-key.path;
          # TODO: peers
        };
      };
    };

    mumble = { config, ... }: {
      networking.firewall = {
        allowedTCPPorts = [ config.services.murmur.port ];
        allowedUDPPorts = [ config.services.murmur.port ];
      };

      services.murmur = {
        enable = true;
        bandwidth = 320000;
        port = 6900;
        registerName = "mumble.i69.lan.tf";
        users = 420;
      };
    };
  };

  flake.colmena = {
    meta.nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

    defaults = { name, ... }: {
      deployment.targetPort = 50022;

      imports = [
        modules.common
        modules.wireguard
        self.inputs.agenix.nixosModules.age
      ]
      ++ lib.optional (lib.hasPrefix "game-" name)
        modules.game-server;

      networking.hostName = name;
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

    spec-1 = { config, ... }: {
      deployment = {
        targetHost = "54.36.190.233";
        targetPort = 50022;
      };

      imports = [
        modules.ovh-vps
      ];

      services.openssh.ports = [ config.deployment.targetPort ];
    };
  };
}
