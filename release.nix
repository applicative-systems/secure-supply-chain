let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./nix/overlay.nix)
    ];
  };
in

{
  inherit (pkgs)
    db-reader
    db-writer
    ;

  integration-test = pkgs.testers.runNixOSTest ./nix/integration-test.nix;

  iso = (pkgs.callPackage ./nix/iso.nix { }).isoImage;
}
