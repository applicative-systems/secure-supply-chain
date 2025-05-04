{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.kernelParams = [ "console=ttyS0" ];

  documentation.man.enable = lib.mkForce false;
  documentation.doc.enable = lib.mkForce false;

  isoImage.edition = lib.mkForce "supply-chain";

  hardware.enableAllHardware = lib.mkForce false;
  hardware.enableRedistributableFirmware = lib.mkForce false;
  networking.wireless.enable = lib.mkForce false;
  boot.swraid.enable = lib.mkForce false;
}
