{ lib
, callPackage
}:

[
  (callPackage ./postgres.nix { })
  (callPackage ./redis.nix { })
  # (callPackage ./rails.nix { })
  # (callPackage ./vite.nix {})

]