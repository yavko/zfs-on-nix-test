{
  config,
  lib,
  pkgs,
  ...
}: let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in {
  imports = [
    ./hardware-configuration.nix
    "${impermanence}/nixos.nix"
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    (import ./disko-config.nix {lib = lib;})
    ./chaotic.nix
  ];
  fileSystems."/boot".device = lib.mkForce "/dev/disk/by-partlabel/disk-sda-esp";
  fileSystems."/var/persistent".neededForBoot = true;
  fileSystems."/var/residues".neededForBoot = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.netbootxyz.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.bootspec.enable = true;
  boot.kernelModules = ["ipmi_devintf" "ipmi_si"];
  environment.systemPackages = [pkgs.ipmitool];
  boot.supportedFilesystems = ["zfs"];

  networking = {
    hostName = "theotokos";
    hostId = "0aa4498d";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.nikolay = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      git
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSzZxIxZL/S5VVi4yjhXZO8iI4A67Uf23iurLuPtZjm"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "daily";
    };
    trim.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  chaotic.zfs-impermanence-on-shutdown = {
    enable = true;
    snapshot = "start";
    volume = "zroot/ROOT/empty";
  };

  environment.persistence."/var/persistent" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      "/etc/secureboot"
      "/var/cache/chaotic"
      "/var/cache/tailscale"
      "/var/lib/chaotic"
      "/var/lib/containers"
      "/var/lib/machines"
      "/var/lib/systemd"
      "/var/lib/upower"
    ];
    files = [
      "/var/lib/dbus/machine-id"
    ];
    users."root" = {
      home = "/root";
      directories = [
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };
    users."nikolay" = {
      directories = [
        ".ansible"
        ".config"
        ".local/share/containers"
        ".local/share/kwalletd"
        ".var"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };
  };

  # Not important but persistent files
  environment.persistence."/var/residues" = {
    hideMounts = true;
    directories = [
      "/var/cache"
      "/var/log"
    ];
    users.nikolay = {
      directories = [
        ".cache/nix-index"
        ".local/share/Trash"
      ];
    };
  };
}
