{ emacsWithPackagesFromUsePackage
, emacsPgtk
}:
emacsWithPackagesFromUsePackage {
  package = emacsPgtk;
  config = ./emacs.el;
}
