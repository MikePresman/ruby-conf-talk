{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "metarank";
  version = "0.7.2";
  src = fetchurl {
    url = "https://github.com/metarank/metarank/releases/download/0.7.2/metarank-0.7.2.jar";
    sha256 = "sha256-x5EaQH1ZvcY3xSiRQfXd8wYYPfJjh5VD2CCkoHT4vOk=";
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
