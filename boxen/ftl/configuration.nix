# Edit this configuration file to define what should be installed on your system.
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Todo
# - homemanager
# - fingerprint stuff - not available until kde 5.24
# - terminal (and fonts)

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix  # Include the results of the hardware scan.
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make my mac bluetooth keboard have the same modifier key layout as the
  # builtin Framework keyboard.
  boot.kernelParams = [
    "hid_apple.swap_opt_cmd=1"
    "hid_apple.swap_fn_leftctrl=1"
  ];

  networking.networkmanager.enable = true;
  networking.hostName = "ftl"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Boise";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp170s0.useDHCP = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.systemPackages = with pkgs; [
    vim
    zsh
    firefox
    git
    plasma5Packages.kamoso # for testing the camera

    spotify
    zoom
    discord
  ];
  environment.variables = { EDITOR = "vim"; };

  programs.steam.enable = true;
  programs.zsh.enable = true;
  programs.kdeconnect.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # services.fprintd.enable = true; # not available until kde 5.24
  services.printing.enable = true;
  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager = {
      sddm.enable = true;
    }; 
    desktopManager.plasma5.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   pulse.enable = true;
  # };

  hardware.bluetooth.enable = true;

  users.groups.walt.gid = 1000;
  users.users.walt = {
    uid = 1000;
    group = "walt";
    isNormalUser = true;
    home = "/home/walt";
    description = "Walt";
    extraGroups = ["wheel" "networkmanager" "docker"];
    shell = pkgs.zsh;
  };
  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release from which the default settings for stateful data, like file locations and database 
  # versions on your system were taken. It‘s perfectly fine and recommended to leave this value at the release version of the first 
  # install of this system. Before changing this value read the documentation for this option (e.g. man configuration.nix or on 
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
