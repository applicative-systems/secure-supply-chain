{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.self.overlays.default ];
      };
    in {
      packages.${system} = {
        default = (pkgs.callPackage ./nix/iso.nix { }).isoImage;
        inherit (pkgs)
          db-reader
          db-writer
          ;
      };
      checks.${system} = inputs.self.packages.${system} // {
        integration-test = pkgs.testers.runNixOSTest ./nix/integration-test.nix;
      };
      overlays.default = import ./nix/overlay.nix;
    };
}
