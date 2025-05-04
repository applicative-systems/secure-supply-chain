# compared to iso.nix, we drop a lot of things here to reduce the source closure
{ pkgs, config, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
  ];

  isoImage.isoName = "supply-demo-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.appendToMenuLabel = " supply chain security demo";
}
