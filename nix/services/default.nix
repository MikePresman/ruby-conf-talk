{ lib
, callPackage
}:

[
  (callPackage ./postgres.nix { })
  (callPackage ./redis.nix { })
  (callPackage ./vite.nix { })
  (callPackage ./rails.nix { })

]