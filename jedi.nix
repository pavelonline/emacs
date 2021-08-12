{ lib, buildPythonPackage, fetchPypi, parso }:

buildPythonPackage rec {
  pname = "jedi";
  version = "0.18.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256:01q7xla9ccjra3j4nhb1lvn4kv8z8sdfqdx1h7cgx2md9d00lmcj";
  };

  doCheck = false;

  propagatedNativeBuildInputs = [
    parso
  ];

  meta = with lib; {
    homepage = "https://github.com/davidhalter/jedi";
    description = ''
    Jedi - an awesome autocompletion, static analysis and refactoring library for Python
    '';
  };
}
