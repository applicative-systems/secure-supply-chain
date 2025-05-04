{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
  documentation.man.enable = lib.mkForce false;
  documentation.doc.enable = lib.mkForce false;

  isoImage.edition = lib.mkForce "supply-chain";

  hardware.enableAllHardware = lib.mkForce false;
  networking.wireless.enable = lib.mkForce false;
  boot.swraid.enable = lib.mkForce false;
}
