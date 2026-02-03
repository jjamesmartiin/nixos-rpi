{ system ? "aarch64-linux"
, nixpkgs ? <nixpkgs> # can be overridden with a pinned nixpkgs
}:

let
  authorizedKeys = [ 
    # Add your SSH key here:
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrsBek1D273N2sLOXPEK1b3hpfdKM4fUUH7eLJHcxFr" 
  ];

  # Import nixpkgs with our overlays
  pkgs = import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ./overlays/bootloader.nix)
      (import ./overlays/vendor-kernel.nix)
      (import ./overlays/vendor-firmware.nix)
      (import ./overlays/linux-and-firmware.nix)
      (import ./overlays/vendor-pkgs.nix)
      (import ./overlays/pkgs.nix)
    ];
  };

  # Helper to build the system
  rpiSystem = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit system pkgs;
    modules = [
      # Basic configuration
      {
        system.stateVersion = "25.11"; # Adjust as needed
        networking.useDHCP = true;
      }
      
      # RPi Modules
      ./modules/raspberry-pi-5/default.nix
      ./modules/raspberry-pi-5/page-size-16k.nix
      ./modules/installer/sd-card/sd-image-raspberrypi.nix
      
      # Minimal user config to make it buildable
      {
      # hostname
      networking.hostName = "nixos-rpi-installer";

      # enable SSH access
      services.openssh.enable = true;
      services.openssh.settings.PermitRootLogin = "yes";
      users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
      users.users.nixos = {
        isNormalUser = true;
        initialPassword = "a";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = authorizedKeys;
      };
        # Need to disable the default sd-image module to avoid conflict if using the one from installer
        # But sd-image-raspberrypi.nix imports the standard one.
        # Let's check if we need to disable anything. 
        # The flake disabled: (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")
        # We are not importing that, so we should be fine.

      # get the gui working
      # services.xserver = {
      #   enable = true;
      #   desktopManager = {
      #     xterm.enable = false;
      #     xfce.enable = true;
      #   };
      # };
      # services.displayManager.defaultSession = "xfce";

      }
    ];
  };

in
  rpiSystem.config.system.build.sdImage
