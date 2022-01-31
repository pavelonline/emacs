final: prev: {
  wrapWithPackages = final.callPackage ./wrapWithPackages.nix { };
  emacsSvrg = final.wrapWithPackages {
    emacs = final.callPackage ./package.nix { };
    packages = with final; [
      lldb
      yaml-language-server
      cmake-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-json-languageserver-bin
      python39Packages.python-lsp-server
      python39Packages.python-lsp-black
      python39Packages.pyls-isort
      python39Packages.rope
      rust-analyzer
      rnix-lsp
      gopls
      plantuml
      texlab
      metals
    ];
  };
}
