{
  description = "My customized emacs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    emacs-overlay.url = github:nix-community/emacs-overlay;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ emacs-overlay.overlay ];
        };
        emacs = pkgs.emacs.pkgs.withPackages (
          epkgs: with epkgs; [
            (
              pkgs.runCommand "default.el" {} ''
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
        );
      in
        rec {
          defaultPackage = emacs;
          defaultApp = {
            type = "app";
            program = "${emacs}/bin/emacs";
          };
          checks = { inherit emacs; };
        }
    );
}
