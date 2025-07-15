{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "metarank";
  version = "0.6.2";
  src = fetchurl {
    url = "https://github.com/metarank/metarank/releases/download/v0.6.2/metarank.jar";
    sha256 = "sha256-ABnfxLMtY8E5KqJkrtIlPB4ML7CSFvjizCabv7i7SbU=";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp $src $out/lib/metarank.jar
    cat > $out/bin/metarank <<EOF
    #!/bin/sh
    exec java -jar $out/lib/metarank.jar "\$@"
    EOF
    chmod +x $out/bin/metarank
  '';
}
