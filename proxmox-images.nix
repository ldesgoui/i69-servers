/* Proxmox Images
  The infra is operated by proxmox, we can easily generate VMAs for proxmox to consume,
  however, uploading images containing gigabytes of game assets is definitely counter-
  productive.
  We probably want to ship an image that does just enough to boot and accept SSH
  connections, and make it rebuild with all the services enabled.
*/

{
  flake.nixosModules.proxmox-firestarter = { modulesPath, ... }: {
    imports = [
      "${modulesPath}/virtualisation/proxmox-image.nix"
      "${modulesPath}/profiles/minimal.nix"
    ];

    # from modules/profiles/headless.nix
    boot.loader.grub.splashImage = null;

    proxmox = {
      qemuConf = rec {
        cores = 24;
        memory = cores * 4 * 1024;

        name = "i69-servers-firestarter";
      };
    };

    # Use cloud-init to set up network interfaces on boot
    services.cloud-init.network.enable = true;

    system.stateVersion = "22.11";
  };
}

