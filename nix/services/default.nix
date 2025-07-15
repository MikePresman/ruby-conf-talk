{ lib
, callPackage
}:

[
  (callPackage ./postgres.nix { })
  (callPackage ./redis.nix { })
  (callPackage ./metarank.nix { })
  # (callPackage ./rails.nix { })
  # (callPackage ./vite.nix {})

]