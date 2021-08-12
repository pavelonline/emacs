{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "docstring-to-markdown";
  version = "0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256:0wg1g3gaq55wbxj2w8niz88lm09za5pzd0k1vq72szbk2rp0x08b";
  };

  doCheck = false;

  propagatedNativeBuildInputs = [];

  meta = with lib; {
    homepage = "https://github.com/krassowski/docstring-to-markdown";
    description = "On the fly conversion of Python docstrings to markdown";
    license = licenses.lgpl21;
  };
}
