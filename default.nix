let
  # deps
  inherit (import ./deps/default.nix) nixpkgs pkgs;
  agenix = (import ./deps/agenix.nix);
  nixos-raspberrypi = (import ./deps/nixos-raspberrypi.nix);

  system = builtins.getEnv "SYSTEM"; # can be run manually with nix-build by setting `export SYSTEM='<systemName>'` in bash

  configuration = pkgs.stdenvNoCC.mkDerivation rec {
    name = "configuration";
    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];

    # get all the parts we need to make symbolic links work
    # don't include this folder, since it might have a result link or other junk that changes!
    #    src = ./systems/pi2;
    src = ./systems + "/${system}";
    modules = ./modules;
    #secrets = ./secrets;
    #defs = ./defs;
    deps = ./deps;

    build-script =
      pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe

      # copy dependencies 
      #cp -r $defs $TMP/defs
      cp -r $modules $TMP/modules
      #cp -r $secrets $TMP/secrets
      cp -r $deps $TMP/deps

      # make systems dir
      mkdir -p $TMP/systems # not sure if needed
      cp -r --no-preserve=mode $src $TMP/systems/${system}
      
      # copy the system folder 
      cp -r --dereference --no-preserve=mode $TMP/systems/${system} $out
    '';
  };

  # Optionally use emulated build
  # build_options = { 
  #     configuration = "${configuration}";
  #   } //
  #     (
  #       if (builtins.hasAttr "system" system_defs)
  #       then { system = system_defs.system; }
  #       else {  }
  #     );
  # This builds the configuration locally.
  # profile = (import "${nixpkgs}/nixos" build_options).config.system.build.toplevel;
  #
  # without emulated build
  profile = (import "${nixpkgs}/nixos" { configuration="${configuration}"; }).config.system.build.toplevel;

  # Script that switches to the new configuration.
  # could we re-write this to read a file? then we can store it as a .sh script? 
  rebuild-command = pkgs.writeShellScript "switch" ''
    store_path="$(dirname "$0")"
    cd $store_path
    echo "Ready to rebuild/switch to $store_path/configuration on host $(hostname)."
    echo "This will also be linked as a GC root in /etc/nixos/current-configuration."
    mkdir -p /var/log/nixos-deploy # make the /var/log/nixos-deploy dir if it doesn't exist yet
    (
      echo `TZ="America/Los_Angeles" date`
      echo $1 # user
      echo $2 # commit
    ) > /var/log/nixos-deploy/$(date +%y%m%d-%H%M%S)

    # this should work I think... 250508
    # at least it's similar ot how I can get it working when I just run it manually before build-and-deploy.sh
    # yeah this is where we need it not build-and-deploy.sh
    export NIXPKGS_ALLOW_UNFREE=1

    sudo rm /etc/nixos/current-configuration
    sudo -E HOME=/root nix-store --add-root /etc/nixos/current-configuration --realize $store_path
    sudo -E HOME=/root NIX_PATH=nixpkgs=./nixpkgs:nixos-config=${configuration}/default.nix nixos-rebuild switch

  '';
in
  assert system != "";

  pkgs.stdenvNoCC.mkDerivation rec {
    name = "nixos-deploy";

    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];
    src = configuration;

    inherit agenix;
    inherit nixos-raspberrypi;

    build-script = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe

      mkdir $out
      cp -r --no-preserve=mode $src $out/configuration
      ln -s ${nixpkgs} $out/nixpkgs
      ln -s ${profile} $out/profile

      cp -a ${rebuild-command} $out/nixos-rebuild-switch
    '';
  }


