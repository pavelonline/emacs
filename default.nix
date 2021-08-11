{ emacs, runCommand }:
emacs.pkgs.withPackages (
  epkgs: with epkgs; [
    (
      runCommand "default.el" {} ''
        mkdir -p $out/share/emacs/site-lisp
        cp ${./emacs.el} $out/share/emacs/site-lisp/default.el
      ''
    )
    which-key
    company
    use-package
    company-nixos-options
    nix-mode
    nixos-options
    lsp-docker
    lsp-latex
    lsp-ui
    magit
    projectile
    ivy
    zerodark-theme
    counsel
    avy
    swiper
  ]
)
