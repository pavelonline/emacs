final: prev: {
  wrapWithPackages = final.callPackage ./wrapWithPackages.nix { };
  emacsSvrg = final.wrapWithPackages {
    emacs = final.callPackage ./package.nix { };
    packages = with final; [
      lldb
      taplo-lsp
      yaml-language-server
      cmake-language-server
      nodePackages.bash-language-server
      (
        final.writeScriptBin "vscode-json-languageserver" ''
          #!${final.runtimeShell}
          exec ${nodePackages.vscode-json-languageserver-bin}/bin/json-languageserver "$@"
        ''
      )
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
      terraform-ls
      metals
    ];
  };
}
