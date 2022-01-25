{ lib
, emacsWithPackagesFromUsePackage
, emacsPgtk
}:
emacsWithPackagesFromUsePackage {
  package = emacsPgtk;
  config = ./emacs.el;
  override = epkgs: epkgs // {
    dap-mode = epkgs.melpaPackages.dap-mode.overrideAttrs (old: {
      patches = (lib.traceValFn builtins.attrNames old).patches or [] ++ [ ./dap-mode-make-process-accepts-list.patch ];
    });
  };
}
