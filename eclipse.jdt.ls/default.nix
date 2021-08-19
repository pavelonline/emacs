{ stdenvNoCC, writeScriptBin, jre_headless }:
stdenvNoCC.mkDerivation rec {
  pname = "eclipse.jdt.ls";
  version = "1.4.0";

  src = builtins.fetchurl {
    url = "http://download.eclipse.org/jdtls/snapshots/jdt-language-server-${version}-202108180140.tar.gz";
    sha256 = "1pgwcibzwspvl75vncq1dxfz8w6ijd8iy1448xm9a9rw93b81y6q";
  };

  dontBuild = true;

  dontUnpack = true;

  outputs = ["out" "java"];

  java = writeScriptBin "jdtls-java-workdir.sh" ''
    tmpdir=$(mktemp -d jdt.workdir.XXXXX)
    trap "rm -rf $tmpdir" EXIT
    cd $tmpdir
    ${jre_headless}/bin/java "$@"
  '';

  installPhase = ''
    mkdir -p $out/share/java
    cd $out/share/java
    tar xzvf $src

    cp ${java} $java
  '';
}
