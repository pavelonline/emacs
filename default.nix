{ runCommand
, cmake-language-server
, emacs
, gopls
, jre_headless
, metals
, nodePackages
, plantuml
, python3
, rnix-lsp
, rust-analyzer
, yaml-language-server
}:
(
  (
    emacs.override {
      withGTK3 = true;
      withGTK2 = false;
      withMotif = false;
    }
  ).overrideAttrs (
    attrs: {
      postInstall = (attrs.postInstall or "") + ''
        rm $out/share/applications/emacs.desktop
      '';
    }
  )
).pkgs.withPackages (
  epkgs: with epkgs; [
    (
      runCommand "default.el" {
        inherit gopls plantuml;
        rnixLsp = rnix-lsp;
        rustAnalyzer = rust-analyzer;
        cmakeLanguageServer = cmake-language-server;
        yamlLanguageServer = yaml-language-server;
        bashLanguageServer = nodePackages.bash-language-server;
        metalsServer = metals;
        sqlsServer = callPackage ./sqls {};
        vscodeJsonLanguageserverBin = nodePackages.vscode-json-languageserver-bin;
        jre = jre_headless;
        jediLanguageServer = python3.pkgs.callPackage ./jedi-language-server.nix {
          docstring-to-markdown = python3.pkgs.callPackage ./docstring-to-markdown.nix {};
          jedi = python3.pkgs.callPackage ./jedi.nix {};
          pygls = with python3.pkgs; pygls.overridePythonAttrs (
            old: rec {
              version = "0.11.2";
              src = fetchPypi {
                pname = "pygls";
                inherit version;
                sha256 = "sha256:110sf97vd074vdd5c8gbs44126s1r26hwhx51xqc1mzhkky2dphs";
              };
              propagatedBuildInputs = old.propagatedBuildInputs or [] ++ [
                setuptools_scm
                pydantic
                typeguard
              ];
            }
          );
        };
      } ''
        mkdir -p $out/share/emacs/site-lisp
        substituteAll ${./emacs.el} $out/share/emacs/site-lisp/default.el
      ''
    )
    go-mode
    avy
    company
    company-nixos-options
    counsel
    envrc
    fira-code-mode
    ivy
    json-mode
    lsp-docker
    lsp-latex
    lsp-metals
    lsp-java
    lsp-jedi
    lsp-ui
    magit
    multiple-cursors
    nix-mode
    nixos-options
    nord-theme
    plantuml-mode
    projectile
    python-black
    rustic
    swiper
    telega
    undo-tree
    use-package
    which-key
    yasnippet
  ]
)
