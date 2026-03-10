{
  description = "Build nixos-ci dependencies for aarch64-linux (mirrors nixos-ci flake)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/2fc6539b481e1d2569f25f8799236694180c0993";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            # Mirror nixos-ci RPATH overlay: fix nix 2.28.5 broken RPATH
            nixVersions = prev.nixVersions // {
              nix_2_28 = prev.nixVersions.nix_2_28.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.patchelf ];
                postFixup = (old.postFixup or "") + ''
                  for rpath in ${final.boost}/lib ${final.zstd.out}/lib ${final.libarchive.out}/lib; do
                    patchelf --add-rpath "$rpath" $out/bin/nix
                    for lib in $out/lib/lib*.so; do
                      [ -f "$lib" ] && patchelf --add-rpath "$rpath" "$lib"
                    done
                  done
                '';
              });
            };
          })
        ];
      };
    in
    {
      packages.${system} = {
        inherit (pkgs.nixVersions) nix_2_28;
        inherit (pkgs) attic-client xonsh nix;
        default = pkgs.symlinkJoin {
          name = "nixos-ci-deps";
          paths = [
            pkgs.nixVersions.nix_2_28
            pkgs.attic-client
            pkgs.xonsh
            pkgs.nix
          ];
        };
      };
    };
}
