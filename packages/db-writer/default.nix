{
  stdenv,
  lib,
  libpqxx,
  boost,
  cmake,
  pkg-config,
}:

stdenv.mkDerivation {
  name = "db-writer";
  version = "1.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./CMakeLists.txt
    ];
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    boost
    libpqxx
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp db-writer $out/bin/
  '';
}
