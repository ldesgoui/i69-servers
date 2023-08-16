{ config, lib, self, inputs, ... }:
let
  rootConfig = config;
  modules = config.flake.nixosModules;
in
{
  flake.nixosModules = {
    common = { config, name, pkgs, ... }: {
      # from modules/profiles/headless.nix
      boot.loader.grub.splashImage = null;

      documentation = {
        enable = lib.mkForce false;
        dev.enable = lib.mkForce false;
        doc.enable = lib.mkForce false;
        man.enable = lib.mkForce false;
        nixos.enable = lib.mkForce false;
      };

      environment.systemPackages = [
        pkgs.htop
      ];

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

        certs."mumble.i71.tf" = {
          email = "ldesgoui@gmail.com";
          dnsProvider = "gandiv5";
          credentialsFile = config.age.secrets.gandi-creds.path;
          group = "murmur";
          reloadServices = [ "murmur" ];
        };
      };

      services.murmur =
        let
          certDir = config.security.acme.certs."mumble.i71.tf".directory;
        in
        {
          enable = true;
          bandwidth = 320000;
          bonjour = true;
          port = 6900;
          registerName = "mumble.i71.tf";
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

    game-1 = { deployment.targetHost = "10.10.11.31"; };
    game-2 = { deployment.targetHost = "10.10.11.32"; };
    game-3 = { deployment.targetHost = "10.10.11.33"; };
    game-4 = { deployment.targetHost = "10.10.11.34"; };
    game-5 = { deployment.targetHost = "10.10.11.35"; };
    game-6 = { deployment.targetHost = "10.10.11.36"; };
  };
}
