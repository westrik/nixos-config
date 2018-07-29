{ config, pkgs, ... }:

{
  imports = [ ./hardware/x250.nix ];

  users.extraUsers.westrik = {
    isNormalUser = true;
    uid = 1000;
    description = "Matthew Westrik";
    extraGroups = [ "wheel" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "thnixpad"; 
  networking.networkmanager.enable = true;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_CA.UTF-8";
  };

  time.timeZone = "America/Toronto";

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # System tools
    wget htop vim git vscode 

    # Desktop applications
    firefox tdesktop dropbox

    # Toolchains
    stack bazel protobuf elmPackages.elm
  ];

  # Program configuration
  programs.bash.enableCompletion = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ ];
  #networking.firewall.allowedUDPPorts = [ ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  #services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Only change this when NixOS release notes say so
  system.stateVersion = "18.03";

}
