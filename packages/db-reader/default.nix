{ lib
, rustPlatform
}:
rustPlatform.buildRustPackage {
  name = "db-reader";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./Cargo.lock
      ./Cargo.toml
    ];
  };
  cargoHash = "sha256-uY4ShPq7vI6xFwvO7JdsAYiNP6Hb0QReeiImlM6X/LY=";
}
