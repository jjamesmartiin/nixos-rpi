{ pkgs, lib, ... }:
let
  nixos-raspberrypi = import (import ./nixos-raspberrypi.nix);
in
{
  disabledModules = [ "rename.nix" ]; # had to turn this off, it was not working and throwing an error

  # rename.nix provides this alias, which is used by internal modules. 
  # Since we disable rename.nix to fix the raspberryPi conflict, we must re-declare this.
  options.environment.checkConfigurationOptions = lib.mkOption {
    default = true;
    example = false;
    type = lib.types.bool;
    description = "Checks that all option definitions have matching declarations.";
  };

  imports = [
    nixos-raspberrypi.lib.inject-overlays
    nixos-raspberrypi.nixosModules.nixpkgs-rpi
    nixos-raspberrypi.nixosModules.raspberry-pi-5.base
    nixos-raspberrypi.nixosModules.raspberry-pi-5.display-vc4
    nixos-raspberrypi.nixosModules.usb-gadget-ethernet
  ];
}


