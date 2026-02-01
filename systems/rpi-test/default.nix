# rpi-test
{ config, ... }:
let
  inherit (import ./deps) nixpkgs pkgs; 
in
{
  imports =
    [ 
      #./modules/basic
      ./modules/basic-rpi5
      ./hardware-configuration.nix
    ];

  # these need to be here I think
  boot.loader.raspberry-pi.bootloader = "kernel";
  nixpkgs.hostPlatform = "aarch64-linux";

  # get the gui working
  nixpkgs.config.pulseaudio = true; # if you use pulseaudio
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";

  # enable SSH access
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root.openssh.authorizedKeys.keys = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrsBek1D273N2sLOXPEK1b3hpfdKM4fUUH7eLJHcxFr" 
  ];

  # install some basic programs
  environment.systemPackages = with pkgs; [
    firefox

    # general use
    nmap
    ncdu # checking storage
    vim # for when I need to use it on root
    htop

    wget

    fastfetch
  ];

  networking.nameservers = [
    "10.1.1.3"
    "8.8.8.8"
  ];

  # Do not change this value
  system.stateVersion = "25.11";
}


