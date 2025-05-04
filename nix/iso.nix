{ nixos }:

nixos [
  ./modules/messages.nix
  ./profiles/application/messages.nix
  ./profiles/platform/iso.nix
  ./profiles/platform/no-ghc.nix
  ./profiles/platform/size-reduction.nix
]
