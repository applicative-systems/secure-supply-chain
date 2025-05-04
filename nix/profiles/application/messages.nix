{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.services.messages)
    user
    reader-port
    writer-port
    ;
in
{
  networking.firewall.allowedTCPPorts = [
    reader-port
    writer-port
  ];

  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "postgres-initScript" ''
      CREATE ROLE ${user} WITH CREATEDB LOGIN;
      CREATE DATABASE ${user} WITH OWNER ${user};
    '';
  };

  services.messages.enable = true;
}
