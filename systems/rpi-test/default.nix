# rpi-test
{ config, ... }:
let
  inherit (import ./deps) nixpkgs pkgs; 

  theHostName = "rpi-test";
  theIPAddress = "10.1.1.22";
  theAuthorizedKeys = [ 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrsBek1D273N2sLOXPEK1b3hpfdKM4fUUH7eLJHcxFr" 

    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPc6FJlIexlHZz+HOczL04E9o/MeS4bObS48JTkViVzw" # paul

    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODYfEvTn5PsOaDZ05yWBf+D5AMAA3omt/3VAc05VsrA" # lucas
  ];
  theDnsServers = [
    "8.8.8.8"
  ];
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
  users.users.root.openssh.authorizedKeys.keys = theAuthorizedKeys;
  users.users.test = {
    isNormalUser = true;
    initialPassword = "a";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = theAuthorizedKeys;
  };

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

  networking.hostName = theHostName;
  networking.interfaces.end0.useDHCP = false;
  networking.interfaces.end0.ipv4.addresses = [ {
    address = theIPAddress;
    prefixLength = 24;
  } ];
  networking.defaultGateway = "10.1.1.1";
  networking.nameservers = theDnsServers;

  # Do not change this value
  system.stateVersion = "25.11";
}


