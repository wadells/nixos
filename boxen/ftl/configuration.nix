# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # journalctl -u systemd-udev -b turned up records like:
  #
  # Dec 26 07:21:33 nix systemd-udevd[396]: error opening ATTR{/sys/devices/pci0000:00/0000:00:1d.7/usb2/2-1/2-1.1/2-1.1:1.0/host6/scsi_host/host6/link_power_management_policy} for writing: Permission denied
  #
  # these seemed to stem from the following rule in /etc/udev/rules.d/10-local.rules:
  #
  # SUBSYSTEM=="scsi_host", ACTION=="add", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
  #
  # 0000:00:1d.7 appeared to be the usb device managing the internal sd card reader:
  #
  # walt@nix:~$ sudo lsusb -v -s 1 | grep -B30 1d.7
  # Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
  # snip...
  #   iSerial                 1 0000:00:1d.7
  #
  # walt@nix:~$ lsusb -t
  # /:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=ehci-pci/8p, 480M
  #   |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/2p, 480M
  #       |__ Port 1: Dev 3, If 0, Class=Mass Storage, Driver=usb-storage, 480M
  #
  # walt@nix:~$ lsusb
  # Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
  # Bus 002 Device 002: ID 0424:2513 Standard Microsystems Corp. 2.0 Hub
  # Bus 002 Device 003: ID 05ac:8404 Apple, Inc. Internal Memory Card Reader
  powerManagement.scsiLinkPolicy = null;


  # not with GNOME3 which requires networkmanager
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true;
  networking.hostName = "nix";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "/etc/caps2esc.map";
    defaultLocale = "en_US.UTF-8";
  };

  # UTC #1 timezone for digital nomads
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile.
  #
  # Really most things go in my user profile. These are the things I want
  # around in the system/root account.
  environment.systemPackages = with pkgs; [
    acpi # power mgmt
    pciutils # introspect pci connections (e.g. network card)
    vim
    usbutils # introspect usb devices
    zsh
  ];


  # List services to enable:

  # Setup preferred desktop env
  services.xserver = {
    enable = true;

    displayManager.gdm = {
      enable = true;
      autoLogin.user = "walt";
      autoLogin.enable = false;
    };

    desktopManager.gnome3.enable = true;

    # enable touch pad
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      tapButtons = true;
      buttonsMap = [ 1 3 2 ];
      accelFactor = "0.01";
      palmDetect = true;
    };
  };

  # need this for walt's default shell to be zsh
  # taken from https://nixos.org/wiki/Using_the_ZSH_SHELL
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.walt = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    shell = "/run/current-system/sw/bin/zsh";
  };

  security.sudo.wheelNeedsPassword = false;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";

}
