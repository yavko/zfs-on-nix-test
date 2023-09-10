{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    (import ./disko-config.nix {inherit lib;})
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.netbootxyz.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportRoot = false;
  boot.initrd.systemd.enable = true;
  boot.initrd.supportedFilesystems = ["zfs"];
  boot.bootspec.enable = true;
  boot.kernelModules = ["ipmi_devintf" "ipmi_si"];
  boot.kernelParams = ["elevator=none"];
  environment.systemPackages = [pkgs.ipmitool];
  boot.supportedFilesystems = ["zfs"];

  networking = {
    hostName = "theotokos";
    hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
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
      (pkgs.fetchurl {
        url = "https://github.com/nikolay.keys";
        sha256 = "sha256-UQuYnua/Y/SCk6w+pLSc62rXAkwbLwbLWv9flu8pQhU="; # curl -sL https://github.com/nikolay.keys | openssl sha256 -binary | base64 -
      })
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
}
