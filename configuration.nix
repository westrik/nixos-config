# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "spinch";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true;

  environment = {
    systemPackages = let pkgsUnstable = import
    (
      fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz
      #fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
    )
    {
	config.allowUnfree = true;
    };
    in
    with pkgs; [
	adobeReader
	clang
	clipit
	cmake
	consul
	curl
	ffmpeg
	firefox
	gcc
	gdb
	gitFull
	gnumake
	gnupg
	inconsolata
	jdk
	jq
	kdeApplications.spectacle
	kitty
	neovim
	nodejs
	packer
	#pkgsUnstable.steam
	pulseaudioFull
	python3
	python37Packages.pip
	qemu
	ripgrep
	rustup
	spotify
	stack
	sysbench
	tdesktop
	terraform
	tmux
	unzip
	vim
	wget
	yarn
	yubikey-personalization

	# QEMU
	dmg2img
	kvm
	libvirt
	virtmanager
	qemu

#      bind
#      chromium
#      discord
#      ffmpeg
#      file
#      freerdp
#      git
#      git-review
#      gnome3.gnome-calculator
#      gnumake
#      gnutls
#      gparted
#      gss
#      hexchat
#      irssi
#      jre
#      krb5Full
#      ksuperkey
#      libreoffice
#      libu2f-host
#      ncurses
#      netcat-openbsd
#      ntfs3g
#      ntp
#      openssl
#      patchelf
#      pavucontrol
#      pciutils
#      pcsctools
#      plasma-nm
#      plasma-workspace-wallpapers
#      psmisc
#      python27
#      python27Packages.pip
#      python27Packages.virtualenv
#      python3
#      python36Packages.flake8
#      python36Packages.lxml
#      python36Packages.pymongo
#      rednotebook
#      rpm
#      tmux
#      trojita
#      unzip
#      usbutils
#      which
#      xclip
#      xmlstarlet
#      xscreensaver
#      zlib
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  programs.zsh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  hardware = {
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    bluetooth.enable = false;
  };


  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.plasma5.enable = true;
    desktopManager.default = "plasma5";
    videoDrivers = [ "mesa" ];
  };

#  services.xserver = {
#    enable = true;
#    layout = "us";
#
#    desktopManager = {
#      default = "none";
#      xterm.enable = false;
#    };
#
#    windowManager.i3 = {
#      enable = true;
#      extraPackages = with pkgs; [
#        dmenu #application launcher most people use
#        i3status # gives you the default i3 status bar
#        i3lock #default i3 screen locker
#        i3blocks #if you are planning on using i3blocks over i3status
#     ];
#    };
#  };

  # Enable yubikey
  services.pcscd.enable = true;
  services.udev.packages = [
    pkgs.libu2f-host
    pkgs.yubikey-personalization
  ];

  services.samba = {
    enable = true;
    nsswins = true;
  };

  users.users.matt = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
