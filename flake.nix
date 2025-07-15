{
  description = "Ruby-Conf";

# source nix. We're using Flakes
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  # Flakes are the modern way to define and share Nix projects — with lock files, versioning, and better reproducibility built in.

# A flake is like a Gemfile + gemspec + Rakefile + Dockerfile — all in one file.



# ✅ outputs = { ... }:
# This is the main export of the flake — similar to def in Ruby or a return value from a module.

# It must return a set of outputs like:

# packages

# devShells

# defaultPackage

# ✅ flake-utils.lib.eachSystem [...] (system: ...)
# This says:

# “For each target system architecture (Mac/Linux/ARM/Intel), run this function and generate system-specific outputs.”

# So it produces a matrix like:

# nix
# Copy
# {
#   x86_64-darwin = { packages = ...; devShell = ... };
#   aarch64-linux = { packages = ...; devShell = ... };
#   ...
# }
# Multi system support !!!!
  outputs = { self, flake-utils, nixpkgs }:
    (flake-utils.lib.eachSystem [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "aarch64-linux"
    ]

# ✅ nixpkgs.lib.fix (flake: let ... in { ... })
# This is a trick that allows the flake variable (the thing we’re returning) to refer to itself — so it can use its own outputs inside the body (e.g., flake.packages.go).
      (system: nixpkgs.lib.fix (flake:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          lib = pkgs.lib // {
            maintainers = pkgs.lib.maintainers // {
              mikepresman = {
                name = "Mike Presman";
                email = "mikepresman@gmail.com";
                github = "mikepresman";
                githubId = 30190842;
              };
            };
          };


# Sneaky but Powerful
# ✅ (flake.packages // { inherit lib callPackage; })
# This means:

  # Use everything inside flake.packages (like go, nodejs, redis, clean, dev)
  # Plus also pass:
    # lib (from pkgs.lib)
    # callPackage (recursive reference — this is what lets nested imports work)
  # So now any Nix script you import with this custom callPackage will have access to:
    # Your pinned packages (Go, Node, etc.)
    # Your custom utilities (dev, clean)
     # lib
     # The callPackage function itself for importing more stuff

          callPackage = pkgs.newScope (flake.packages // { inherit lib callPackage; });
        in
        {
          # Variables
          packages = {
            ## ruby-conf development scripts

            clean = callPackage ./nix/scripts/clean.nix { };

            dev = callPackage ./nix/scripts/dev.nix {
              # dev takes a variable services
              services = callPackage ./nix/services { };
            };

            ## Pinned packages from nixpkgs

            # Comes from here nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
            go = pkgs.go_1_24;

            nodejs = pkgs.nodejs_24;
            
            ruby = pkgs.ruby_3_4;

            postgresql = pkgs.postgresql_17;

            # todo - add cowsay
            cowsay = pkgs.cowsay;

            redis = pkgs.redis;

            google-cloud-sdk = pkgs.google-cloud-sdk;

            golangci-lint = pkgs.golangci-lint;

            glibcLocales = pkgs.glibcLocales;

            ## ruby-conf outputs
            ruby-conf = callPackage ./. {
              buildGoModule = pkgs.buildGoModule.override {
                go = flake.packages.go;
              };
            };
          };

          defaultPackage = flake.packages.ruby-conf;

          # This is our Magic !!!
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              flake.packages.go
              pkgs.nodePackages.pnpm
              flake.packages.postgresql
              flake.packages.redis
              # flake.packages.cowsay
              flake.packages.dev
              flake.packages.clean
              flake.packages.golangci-lint
              flake.packages.glibcLocales
              flake.packages.google-cloud-sdk

    # Comes from here as well -> Just we dont evaluate customize it with a variable in the packages step 
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
              git
              protobuf
              protoc-gen-go
              protoc-gen-go-grpc
              go-migrate
              mkcert
            ];

          #executed each time devshell starts
            shellHook = ''
              # prepend the built binaries to the $PATH
              export PATH="./bin":$PATH
            '';
          };
        }
      )));
}

# direnv allow
# nix develop --profile /tmp/direnv-profile-$HASH --show-trace --impure