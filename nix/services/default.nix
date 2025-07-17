{ lib
, callPackage
}:

[
  (callPackage ./metarank-runner.nix { })
  (callPackage ./postgres.nix { })
  (callPackage ./redis.nix { })
  (callPackage ./rails.nix { })
  # (callPackage ./vite.nix { })

]
