# configuration.nix
# This file defines what should be installed on your NixOS system.
# Help is available in the `configuration.nix(5)` man page or at https://search.nixos.org/options.

{ config, lib, pkgs, ... }:

{
  ###########################################
  # System Imports and Hardware Configuration
  ###########################################

  imports = [
    <nixos-hardware/microsoft/surface-pro/9>  # Surface Pro 9 hardware configuration.
    ./hardware-configuration.nix             # Hardware scan results.
   # <home-manager/nixos>
  ];

  ###########################################
  # Boot and Kernel Configuration
  ###########################################

  # Boot loader configuration.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "surface_gpe" ];
  
  # Uncomment to use the latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel parameters.
  boot.kernelParams = ["pci=hpiosize=0" "acpi_enforce_resources=lax"];

  systemd.services.enable-acpi-wakeup = {
    description = "Enable ACPI wake-up devices";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c ''echo CNVW > /proc/acpi/wakeup; echo HDAS > /proc/acpi/wakeup''";
     # ExecStart = ''
     #   echo "CNVW" > /proc/acpi/wakeup
     #   echo "HDAS" > /proc/acpi/wakeup
     # '';
      Type = "oneshot";
    };
  };



  systemd.services.enable-usb-wakeup = {
    description = "Enable USB wake-up devices";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeText "enable-usb-wakeup.sh" ''
        #!/bin/bash
        for device in /sys/bus/usb/devices/*; do
          if [ -w "$device/power/wakeup" ]; then
            echo enabled > "$device/power/wakeup"
          fi
        done
      ''}";
      Type = "oneshot";
    };
  };

services.logind = {
  extraConfig = ''
    HandlePowerKey=ignore
    HandleSuspendKey=ignore
    HandleLidSwitch=ignore
  '';
};

  ###########################################
  # Networking
  ###########################################

  networking.hostName = "gesar";  # Define your hostname.

  # Network management.
  networking.networkmanager.enable = true;  # Preferred option for most distros.
  # Uncomment below if you need wireless support via wpa_supplicant.
  # networking.wireless.enable = true;

  # Proxy configuration (if needed).
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  ###########################################
  # Localization and Timezone
  ###########################################

  # Timezone configuration.
  time.timeZone = "America/Denver";

  # Uncomment and configure for internationalization.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true;  # Use xkb.options in tty.
  # };

  ###########################################
  # Desktop Environment and Display
  ###########################################

  nixpkgs.config.allowUnfree = true;

  # Desktop environment.
  services = {
    desktopManager.plasma6.enable = true;                # Plasma desktop.
    desktopManager.cosmic.enable = true;                # Cosmic desktop.
    desktopManager.cosmic.xwayland.enable = true;       # XWayland for Cosmic.
 #   displayManager.cosmic-greeter.enable = true;        # Cosmic greeter.
    # Uncomment for SDDM display manager (if needed).
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  # Exclude specific Plasma packages.
#  environment.plasma6.excludePackages = with pkgs.kdePackages; [
#    xwaylandvideobridge
#  ];

  ###########################################
  # Input Devices
  ###########################################

  # Enable touchpad and input support.
  services.libinput.enable = true;

  ###########################################
  # Printing and Sound
  ###########################################

  # Enable printing support.
  services.printing.enable = true;

  # Enable sound using PipeWire.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  ###########################################
  # Flatpak Support
  ###########################################

  services.flatpak.enable = true;

  ###########################################
  # User Configuration
  ###########################################

  # Define user accounts.
  users.users.zane = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];  # Enable sudo for the user.
    packages = with pkgs; [
      tree
    ];
  };

#users.users.zane.isNormalUser = true;
#home-manager.users.zane= { pkgs, ... }: {
#  extraGroups = [ "wheel" ];  # Enable sudo for the user. 
#  home.packages = [ pkgs.atool pkgs.httpie pkgs.pcloud];
#  programs.bash.enable = true;
#  home.stateVersion = "24.05"; # Please read the comment before changing. 
#  nixpkgs.config.allowUnfree = true;
#};

  ###########################################
  # Installed Programs and Packages
  ###########################################

  programs.firefox.enable = true;

  # System-wide installed packages.
  environment.systemPackages = with pkgs; [
    vim
    wget
    pcloud
    git
    vscode
    libwacom
  #  (pkgs.rstudioWrapper.override {
  #    packages = with pkgs.rPackages; [
  #      ggplot2
  #      dplyr
  #      xts
  #    ];
  #  })
  ];

  ###########################################
  # Systemd Configuration
  ###########################################

  # Extra systemd configurations.
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";

  ###########################################
  # Activation Scripts
  ###########################################

  # Automatically update the Git repository with configuration changes.
  #system.activationScripts.gitUpdate = "/etc/nixos/git-update.sh";

  ###########################################
  # Security and Firewall
  ###########################################

  # Uncomment below to enable OpenSSH.
  # services.openssh.enable = true;

  # Configure firewall (if needed).
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;  # Disable the firewall.

  ###########################################
  # System State Version
  ###########################################

  # This defines the first version of NixOS installed on this machine.
  # It ensures compatibility with older application data.
  system.stateVersion = "25.05";  # Do not change unless necessary.
}
