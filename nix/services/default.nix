{ callPackage }:

let
  postgres = callPackage ./postgres.nix { };
  redis = callPackage ./redis.nix { };
  rails = callPackage ./rails.nix { };
in

builtins.trace "✅ Loaded services: ${builtins.toJSON [ postgres.name redis.name rails.name ]}" [
  postgres
  redis
  rails
]
