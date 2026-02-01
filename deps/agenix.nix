let
  # latest pin from 260129
  commit = "0814fdc0dea23e6c2656109e66d69e056f466358";
  sha256 = "1m6c5kgaim5n5wa5x5cpqmv8mlw4fvcfyfv469gwn1avysjwaxc5";
in
builtins.fetchTarball {
  name = "agenix-${commit}";
  url = "https://github.com/ryantm/agenix/archive/${commit}.tar.gz";
  inherit sha256;
}

