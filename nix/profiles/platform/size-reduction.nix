{ modulesPath, lib, pkgs, ... }:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

  # These settings totally brick the nix installation but we just want to
  # demo a nix-daemon-less system that doesn't need to rebuild itself.
  nix.enable = false;
  boot.postBootCommands = lib.mkForce "";

  # let's disable a few settings that are either on by default or enabled by
  # the minimal installer

  boot.supportedFilesystems = lib.mkForce [];
  environment.systemPackages = lib.mkForce [
    pkgs.systemd
    pkgs.bash
  ];

  security.polkit.enable = lib.mkForce false;

  systemd.enableEmergencyMode = false;

  boot.initrd.checkJournalingFS = false;

  networking.firewall.enable = false;

  environment.defaultPackages = [ ];
  boot.enableContainers = false;
  xdg.menus.enable = false;
  programs.command-not-found.enable = false;
  programs.git.enable = lib.mkForce false;
  system.fsPackages = lib.mkForce [ ];
}
