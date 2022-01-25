{ lib, makeWrapper, runCommand }:
{ emacs
, packages
}:
runCommand "emacs-with-deps"
{
  buildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin/
  set -x
  makeWrapper ${emacs}/bin/emacs $out/bin/emacs --prefix PATH : ${lib.makeBinPath packages}
  ln -s ${emacs}/bin/emacsclient $out/bin/
''
