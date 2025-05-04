# Demonstrably Secure Software Supply Chain

This repository demonstrates how to define a complex system image with NixOS.
As an additional step after building and testing it, it demonstrates how to
export all sources of the image to rebuild it offline from scratch.

This can then be used as a proof to authorities that *this set of sources* led
to *this image* without any manipulation inbetween.

"All sources" means not only the sources of the applications that go into the
image, but also all sources of all the toolchains that were needed to build it.
(Yes, you can prove that the compiler of your compiler has not been tampered
with! This is a very thorough method of proving)

The exported sources (a few GB of source tarballs) could be realistically
audited by third parties.

## Content

This repository defines a somewhat minimal NixOS image with some halfway
realistic demo applications:

- Database writer C++ app
  - Listens on a TCP port and writes input to a postgres DB
- Database reader Rust app
  - Listens on an HTTP port and dumps all content in the postgres DB to the client

The booted ISO image runs these services.

## Create Offline Source-Only Closure

"Source-Only" means:

- all source tarballs (including everything, even the source of the compilers' compiler)
- all Nix expressions needed to evaluate the output on an offline machine again
- bootstrap tarball ([definition](https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/linux/make-bootstrap-tools.nix))

Create the offline closure of the image:

```console
$ ./scripts/source-closure.sh
```

You will now find the source closure in the file `source-export.closure`

## Try out/Demonstrate offline rebuild of everything

Create/find some system that has Nix installed but is completely offline.
Then, add the source closure and original nix expression that defines your
build target, to the system via USB, for example.

Reproduce the whole build in two steps:

```console
$ nix-store --import < /path/to/source-export.closure
$ nix-build path/to/original/nix/expression.nix
```

### Try it in an offline Docker image

Quick and easy:

```sh
$ docker run -it --network=none -v /path/to/your/repo/with/closure:/src nixos/nix
# nix-store --import < /src/source-export.closure
# nix-build /src --option substituters ""
```
