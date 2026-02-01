# able to use the flake bc of flake compat
# https://github.com/nvmd/nixos-raspberrypi/pull/100
let
  # latest pin from 260129
  commit = "24ac1a9b419b24a34dd720863cb204e6694e497f";
  sha256 = "sha256:0whiq8j3jcris2v71kvkfw3za9an7w8sidqrhnbrm1k10dnp61r5";
in
builtins.fetchTarball {
  name = "nixos-raspberrypi-${commit}";
  url = "https://github.com/nvmd/nixos-raspberrypi/archive/${commit}.tar.gz";
  inherit sha256;
}

