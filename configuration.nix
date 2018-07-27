{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/virtualbox-demo.nix> ];

  time.timeZone = "America/Toronto";

  environment = {
    systemPackages = with pkgs; [
      vim
      firefox
    ];
  };
} 
