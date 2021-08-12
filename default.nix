{ runCommand, emacs, rnix-lsp }:
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
    lsp-docker
    lsp-latex
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
