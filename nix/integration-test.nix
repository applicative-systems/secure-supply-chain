{
  name = "test-messages-server";

  nodes = {
    server = {
      imports = [
        ./modules/messages.nix
        ./profiles/application/messages.nix
      ];
    };
  };

  testScript = { nodes, ... }: ''
    from shlex import quote
    from unittest import TestCase

    t = TestCase()

    USER = "${nodes.server.services.messages.user}"
    WRITER_PORT = ${builtins.toString nodes.server.services.messages.writer-port}
    READER_PORT = ${builtins.toString nodes.server.services.messages.reader-port}

    def send_message(msg):
        return server.succeed(
            f"echo {msg} | nc -N localhost {WRITER_PORT}"
        )

    def sql_query(select):
        cmd = f"psql -d {USER} -tAc {quote(select)}"
        output = server.succeed(f"su -c {quote(cmd)} postgres")
        return output.splitlines()

    def get_messages(where=""):
        return sql_query(f"SELECT content FROM testcounter {where};")

    server.start()
    server.systemctl("start network-online.target")
    server.wait_for_unit("network-online.target")
    server.wait_for_unit("db-writer.service")
    server.wait_for_unit("db-reader.service")

    server.wait_until_succeeds(
        f"curl http://localhost:{READER_PORT}"
    )

    t.assertEqual(0, len(get_messages()))
    send_message("hello")
    t.assertEqual(1, len(get_messages()))

    t.assertIn("hello", server.succeed(
        f"curl http://localhost:{READER_PORT}"
    ))

    send_message("foobar")
    t.assertEqual(["hello", "foobar"], get_messages())
  '';
}
