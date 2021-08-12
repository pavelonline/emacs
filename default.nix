{ runCommand, emacs, rnix-lsp, yaml-language-server, nodePackages, python3 }:
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
        rnixLsp = rnix-lsp;
        yamlLanguageServer = yaml-language-server;
        bashLanguageServer = nodePackages.bash-language-server;
        vscodeJsonLanguageserverBin = nodePackages.vscode-json-languageserver-bin;
        jediLanguageServer = python3.pkgs.callPackage ./jedi-language-server.nix {
          docstring-to-markdown = python3.pkgs.callPackage ./docstring-to-markdown.nix {};
          jedi = python3.pkgs.callPackage ./jedi.nix {};
          pygls = with python3.pkgs; pygls.overridePythonAttrs (old: rec {
            version = "0.11.2";
            src =  fetchPypi {
              pname = "pygls";
              inherit version;
              sha256 = "sha256:110sf97vd074vdd5c8gbs44126s1r26hwhx51xqc1mzhkky2dphs";
            };
            propagatedBuildInputs = old.propagatedBuildInputs or [] ++ [
              setuptools_scm
              pydantic
              typeguard
            ];
          });
        };
      } ''
        mkdir -p $out/share/emacs/site-lisp
        substituteAll ${./emacs.el} $out/share/emacs/site-lisp/default.el
      ''
    )
    avy
    company
    company-nixos-options
    counsel
    fira-code-mode
    ivy
    json-mode
    lsp-docker
    lsp-latex
    lsp-jedi
    lsp-ui
    magit
    nix-mode
    nixos-options
    projectile
    swiper
    use-package
    which-key
    zerodark-theme
  ]
)
