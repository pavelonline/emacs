{ lib, buildPythonPackage, fetchPypi, pydantic, docstring-to-markdown, jedi, pygls, parso }:

buildPythonPackage rec {
  pname = "jedi-language-server";
  version = "0.34.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256:0b8wc9240jazffx94zhxyih292y8kb8fxmi2lvfs3snxvnzbws2k";
  };

  doCheck = false;

  propagatedBuildInputs = [
    pydantic
    docstring-to-markdown
    jedi
    pygls
    parso
  ];

  meta = with lib; {
    homepage = "https://github.com/pappasam/jedi-language-server";
    description = ''
    A Language Server for the latest version(s) of Jedi. If using Neovim/Vim,
    we recommend using with coc-jedi. Supports Python versions 3.6 and newer.
    '';
    license = licenses.mit;
  };
}
