{ config, pkgs, lib, ... }:

let
  cfg = config.services.messages;
in
{
  options.services.messages = {
    enable = lib.mkEnableOption "the message services";
    user = lib.mkOption {
      type = lib.types.str;
      default = "messages";
    };
    writer-port = lib.mkOption {
      type = lib.types.port;
      default = 1300;
    };
    reader-port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.user;
      description = "messages service user";
      home = "/var/lib/messages";
      isSystemUser = true;
    };

    users.groups.${cfg.user} = { };

    systemd.services.db-writer = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.db-writer}/bin/db-writer ${builtins.toString cfg.writer-port}";
        User = cfg.user;
        Group = cfg.user;
      };
      environment.DATABASE_URL = "postgresql:///";
    };

    systemd.services.db-reader = {
      wantedBy = [ "multi-user.target" ];
      after = [ "db-writer.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.db-reader}/bin/db_reader ${builtins.toString cfg.reader-port}";
        User = cfg.user;
        Group = cfg.user;
      };
      environment.DATABASE_URL = "postgresql://${cfg.user}@/?host=/var/run/postgresql";
    };

  };
}
