{
  description = "Build nix 2.28.5 and attic-client for aarch64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/2fc6539b481e1d2569f25f8799236694180c0993";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        nix_2_28 = pkgs.nixVersions.nix_2_28;
        attic-client = pkgs.attic-client;
        default = pkgs.attic-client;
      };
    };
}
