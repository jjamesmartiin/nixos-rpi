# deps/default.nix

## to use this:
## make a symlink and then add this in the system

# let 
#   inherit (import ./defs/nixos-2511.nix) nixpkgs pkgs;
# in

let
  commit = "30a3c519afcf3f99e2c6df3b359aec5692054d92";
  hash   = "sha256:13rp7g4ivphc70z6fdb2gf6angzr6qm2vrx32nk286nli991117h"; 
  branch = "nixos-25.11";

in rec {
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
    sha256 = hash;
    name = "${branch}-${commit}";
  };
  pkgs = (import nixpkgs { config.allowUnfree = true; }).pkgs; 
}

