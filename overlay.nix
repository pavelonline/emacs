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
      (python39.withPackages
        (ps: with ps; [
          jedi
          python-lsp-server
          python-lsp-black
          pyls-isort
          rope
        ]))
      rust-analyzer
      rnix-lsp
      gopls
      plantuml
      texlab
      metals
    ];
  };
}
