{ modulesPath, lib, ... }:

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
  ];

  # These settings totally brick the nix installation but we just want to
  # demo a nix-daemon-less system that doesn't need to rebuild itself.
  nix.enable = false;
  boot.postBootCommands = lib.mkForce "";

  # super dirty hack to disable `shellcheck` image-wide.
  # Shellcheck is written in Haskell and requires haskell runtime.
  # That's of course not generally a problem but for the source closure this
  # means including the haskell compiler source.
  nixpkgs.overlays = [
    (final: prev: {
      shellcheck-minimal = (prev.runCommand "shellcheck" {} ''
        mkdir -p $out/bin
        cat > $out/bin/shellcheck <<EOF
        #!${final.bash}/bin/bash
        true
        EOF
        chmod +x $out/bin/shellcheck
      '') // { compiler = final.hello; };
    })
  ];

  # inspired by modules/profiles/headless.nix
  boot.vesa = false;
  boot.loader.grub.splashImage = null;

  security.polkit.enable = lib.mkForce false;

  boot.kernelParams = [ "boot.panic_on_fail" ];

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  # We have no persistent file systems.
  boot.initrd.checkJournalingFS = false;

  # Additional minimization.
  environment.defaultPackages = [ ];
  boot.enableContainers = false;
  xdg.autostart.enable = false;
  xdg.icons.enable = false;
  xdg.menus.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
  programs.command-not-found.enable = false;
  system.fsPackages = lib.mkForce [ ];
}
