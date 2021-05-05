# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
      # Use the systemd-boot EFI boot loader.
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;

      # Enable DHCP so networking will work in Stage 1.
      # This is needed so enough entropy can be collected to recompute the YubiKey challenge-response salt.
      kernelParams = [
        "ip=:::::enp4s0:dhcp"
      ];

      # Load the ZFS kernel modules.
      supportedFilesystems = [ "zfs" ];

      initrd = {
        # Install kernel modules needed for networking and YubiKey challenge-response.
        availableKernelModules = ["igb"];
        kernelModules = ["vfat" "nls_cp437" "nls_iso8859-1" "usbhid" "igb"];
        network.enable = true;

        luks = {
          yubikeySupport = true;

          devices = {
            cryptroot = {
              device = "/dev/nvme0n1p2";
              preLVM = false;
              yubikey = {
                slot = 2;
                twoFactor = false;
                keyLength = 64; # Set to $KEY_LENGTH/8
                saltLength = 64; # Set to $SALT_LENGTH
                storage = {
                  device = "/dev/nvme0n1p1";
                };
              };
            };
          };
        };
      };
    };


  # ------- Locale -------
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";


  # ------- Networking -------
  networking.hostName = "kepchup";
  networking.hostId = "546f7696";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [
    445   # SMB
    139   # SMB
    22    # SSH
    80    # HTTP
    443   # HTTPS
    32469 # Plex DLNA
    3000  # Grafana
    8000 # Test web service
    2222 # debian container SSH
  ];
  networking.firewall.allowedUDPPorts = [
    137   # NetBIOS
    138   # NetBIOS
    5353  # mDNS (Bonjour)
  ];


  # ------- Dependencies -------
  # required for nvidia driver, plex, roon, etc.
  nixpkgs.config.allowUnfree = true;
  # required for steam w/ native libraries
  nixpkgs.config.allowBroken = true;
  nixpkgs.overlays = [
    # required to upgrade roon to >=1.7
    ( import ./overlays/roon-server.nix )
  ];
  environment.systemPackages = with pkgs; [
    (steam.override { nativeOnly = true; })

    # backups
    borgbackup
    rclone

    # utilities
    curl
    fd
    htop
    jq
    ripgrep
    unzip
    wget

    # security
    gnupg
    yubikey-personalization

    # media
    imagemagick
    youtube-dl

    # networking
    tailscale

    # development tools
    gitFull
    neovim
    tmux
    tokei

    # development toolchains
    binutils # ar, etc.
    bubblewrap
    clang
    cmake
    gnumake
    libcap
    nodejs
    python3
    python37Packages.pip
    rustup
    yarn

    # podman stack
    # TODO(20.09): replace with virtualisation.podman.enable (see https://nixos.wiki/wiki/Podman)
    podman
    runc
    conmon
    slirp4netns
    fuse-overlayfs

    # datastores
    postgresql
    mysql
    libmysqlclient
    sqlite

  ];

  # Configure shell to use forwarded GPG agent
  # environment.shellInit = ''
  #   export GPG_TTY="$(tty)"
  #   gpg-connect-agent /bye
  #   export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
  # '';

  environment.shellInit = ''
    eval "$(direnv hook bash)"
  '';

  programs.ssh = {
    startAgent = false;
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
  };

  # ------- Services -------
  services.xserver = {
    enable = true;
    layout = "us";
    videoDrivers = [ "nvidia" ];
    desktopManager.xfce.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # needed for steam
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  services.openssh = {
    enable = true;
    forwardX11 = true;
    permitRootLogin = "no";
  };

  services.tailscale.enable = true;

  services.samba = {
    enable = true;
    enableWinbindd = false;
    shares.media = {
       path = "/media";
       "valid users" = "matt";
       "force user" = "matt";
       public = "no";
       writable = "yes";
       "fruit:aapl" = "yes";
       # store macOS metadata
       "fruit:metadata" = "stream";
    };
    shares.backups = {
       path = "/backups";
       "valid users" = "matt betty";
       public = "no";
       writeable = "yes";
       "fruit:aapl" = "yes";
       # store macOS metadata
       "fruit:metadata" = "stream";
       # allow time machine backup
       "fruit:time machine" = "yes";
       "vfs objects" = "catia fruit streams_xattr";
    };
    extraConfig = ''
      # Disable printing
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
    '';
  };

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.roon-server = {
    enable = true;
    openFirewall = true;
  };

  services.apcupsd.enable = true;

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "logind"
      "systemd"
    ];
    disabledCollectors = [
      "textfile"
    ];
    openFirewall = true;
  };

  virtualisation.docker.enable = true;

  # ------- Users & Groups -------
  users.users.matt = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    # TODO(20.09): remove these (for podman)
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };
  users.users.betty = { isNormalUser = true; };

  # allow remote builds
  nix.extraOptions = ''
    trusted-users = root matt
  '';

  # grant access to media files
  users.users.roon-server = { extraGroups = [ "users" ]; };
  users.users.plex = { extraGroups = [ "users" ]; };


  # ------- Release -------
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
