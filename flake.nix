{
  description = "Ruby-Conf";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "aarch64-linux"
    ] (system:
      nixpkgs.lib.fix (flake:
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

          callPackage = pkgs.newScope (flake.packages // { inherit lib callPackage; });
        in
        {
          packages = {
            ## Scripts
            clean = callPackage ./nix/scripts/clean.nix { };
            dev = callPackage ./nix/scripts/dev.nix {
              services = callPackage ./nix/services { };
            };

            ## Pinned packages
            go = pkgs.go_1_24;
            # nodejs = pkgs.nodejs_24;
            ruby = pkgs.ruby_3_4;
            postgresql = pkgs.postgresql_17;
            redis = pkgs.redis;
            google-cloud-sdk = pkgs.google-cloud-sdk;
            golangci-lint = pkgs.golangci-lint;
            glibcLocales = pkgs.glibcLocales;

            # ## Metarank CLI
            metarank = callPackage ./nix/services/metarank.nix { };

            ## Output package
            ruby-conf = callPackage ./. {
              buildGoModule = pkgs.buildGoModule.override {
                go = flake.packages.go;
              };
            };
          };

          defaultPackage = flake.packages.ruby-conf;

          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              flake.packages.go
              # flake.packages.nodejs
              pkgs.nodePackages.pnpm
              flake.packages.postgresql
              flake.packages.redis
              flake.packages.metarank 
              flake.packages.dev 
              flake.packages.clean 
              flake.packages.golangci-lint 
              flake.packages.glibcLocales
              flake.packages.google-cloud-sdk
              git
              protobuf
              protoc-gen-go
              protoc-gen-go-grpc
              go-migrate
              mkcert
              openjdk # needed for metarank
            ];

            shellHook = ''
              export PATH="./bin":$PATH
            '';
          };
        }
      )
    );
}
