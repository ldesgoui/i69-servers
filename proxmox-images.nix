/* Proxmox Images
  The infra is operated by proxmox, we can easily generate VMAs for proxmox to consume,
  however, uploading images containing gigabytes of game assets is definitely counter-
  productive.
  We probably want to ship an image that does just enough to boot and accept SSH
  connections, and make it rebuild with all the services enabled.
*/

{
  flake.nixosModules.proxmox-firestarter = { config, modulesPath, ... }: {
    imports = [
      "${modulesPath}/virtualisation/proxmox-image.nix"
      "${modulesPath}/profiles/minimal.nix"
    ];

    # from modules/profiles/headless.nix
    boot.loader.grub.splashImage = null;

    proxmox = {
      qemuConf = rec {
        cores = 5;
        memory = cores * 4 * 1024;

        name = "i69-servers-firestarter";
      };
    };

    # Use cloud-init to set up network interfaces on boot
    services.cloud-init.network.enable = true;

    services.openssh = {
      enable = true;
    };

    networking.firewall = {
      allowedTCPPorts = config.services.openssh.ports;
    };

    users.users.root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK25ea20daUVvmTPmUL1nF/0DXEz/7tPBXOSerQNTf6+ me@ldesgoui.xyz"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC94Qd2XQoffOcrsEbZfwOzNPy8PZgyAchycchIohhYVnqx5EVwlBMbOBKR5VUnXXxiglFS+HvfAUmHJth5dBdnfuUr3f1wkth5w+KwjnWzIlrFW30+zsc1CsUfluUQc1kW2qx8Z/ytS28zgL/B14yEcRoTgMJBjmWkLe060lROx1VR8Elp3sRJjClTZ64o6CeM4QaxIaDd1ZL008KcAEcK1bcScpvCSfRGCUAu+TTwxz0/cyb9x21I9x67FpELlAegw3y/6A7tbpSFZY/WG+eRwrTeAXK799rzV6Brg5RadOVa3PAsxOpIjgLQ/klH+m487UNCuoNE+SiukoP3OUjh proto"
      ];
    };

    system.stateVersion = "22.11";
  };
}
