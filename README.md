# Demonstrably Secure Software Supply Chain

This repository provides a robust solution for organizations needing to prove
the integrity of their software supply chain.
Using NixOS, it demonstrates how to define a complex system image, verify that
all source inputs are untampered, and rebuild the image offline from scratch.
This ensures auditable, tamper-proof software builds—ideal for regulatory
compliance or high-security environments.

## Who Benefits?

- **Developers and DevOps Teams**: Ensure reproducible, secure builds.
- **Compliance Officers**: Provide verifiable proof for audits.
- **Security Professionals**: Mitigate supply chain attacks with full
  transparency.

## Why This Matters

- **Prove Integrity**: Guarantee that this exact set of sources produced this
  image without third-party interference.
- **Comprehensive Source Tracking**: Includes all application sources and
  toolchains (e.g., compilers and their compilers) for complete transparency.
- **Auditable Outputs**: Exports all sources (a few GB of tarballs) for
  third-party audits, ensuring trust and accountability.

## What’s Included

A minimal NixOS image with realistic demo applications:

- **C++ Database Writer**: Listens on a TCP port, writes input to a PostgreSQL
  database.
- **Rust Database Reader**: Serves database content over HTTP.

The booted ISO runs these services, showcasing a secure, reproducible build.

## Key Features

### Create an Offline Source-Only Closure

Captures all source tarballs, Nix expressions, and bootstrap tools needed for offline rebuilding.

```console
$ ./scripts/source-closure.sh
```

Output: `source-export.closure`

This file can be imported into an offline system.
It can also be used for audit purposes.

### Rebuild Offline with Confidence

Reproduce the build on an offline system (e.g., via USB transfer)
that has never downloaded anything from a binary cache and hence
will have to rebuild everything from sources:

```console
$ nix-store --import < source-export.closure
$ nix-build
```

(We are not saying that Docker is good enough to perform supply chain
proofs - this is just for demoing the method itself.)

### Test in an Offline Docker Environment

Docker is a quick and simple way to simulate a fresh offline environment 
without having to setup a new computer or VM:

```console
$ docker run -it --network=none -v /path/to/repo:/src nixos/nix
# nix-store --import < /src/source-export.closure
# nix-build /src --option substituters ""
```

### Flakes Support

Prefer Nix flakes? These commands work with flakes in the Docker scenario:

```console
$ ./scripts/source-closure-flake.sh
$ docker run -it --network=none -v /path/to/repo:/src nixos/nix
# nix-store --import < /src/source-export.closure
# git config --global --add safe.directory /src
# nix build /src -L --option substituters "" --extra-experimental-features "nix-command flakes"
```
