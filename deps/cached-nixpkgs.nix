let
  # latest pin from upstream lock file as of 2026-02-02
  commit = "87f37c7a374071ec0924b99b846c1a7cc44a8c6c";
  sha256 = "sha256:1h50g9dq6wd016q02kbfj101s79j188w9a89d7b4j84i48rxh43d"; # Placeholder, likely needs correct hash or use tarball fetching which might not require strict SRI if using builtins.fetchTarball without it, but fetchTarball usually wants one for purity or cache. Wait, the plan had a hash.
  # The plan had: sha256-T5VGtbz2X+waw2P1dYvLa56osxj3cNZArfa5aRBVT+s=
  # Let's use that.
  
  hash = "sha256-T5VGtbz2X+waw2P1dYvLa56osxj3cNZArfa5aRBVT+s=";
  
  # Upstream uses nvmd/nixpkgs
  owner = "nvmd";
  repo = "nixpkgs";
in
fetchTarball {
  url = "https://github.com/${owner}/${repo}/archive/${commit}.tar.gz";
  sha256 = hash;
  name = "cached-nixpkgs-${commit}";
}
