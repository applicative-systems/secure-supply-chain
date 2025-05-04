let
  sources = import ./nix/sources.nix { };
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./nix/overlay.nix)
    ];
  };

  iso = (pkgs.nixos [
    ./nix/modules/messages.nix
    ./nix/profiles/application/messages.nix
    ./nix/profiles/platform/iso.nix
  ]).isoImage;

in

{
  inherit (pkgs)
    db-reader
    db-writer
    ;

  integration-test = pkgs.testers.runNixOSTest ./nix/integration-test.nix;

  inherit iso;
}
