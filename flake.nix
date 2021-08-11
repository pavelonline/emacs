{
  description = "My customized emacs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    emacs-overlay.url = github:nix-community/emacs-overlay;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils }:
    let
      makeEmacsPackage = (
        system: (
          import nixpkgs {
            inherit system;
            overlays = [ emacs-overlay.overlay ];
          }
        ).callPackage ./. {}
      );
    in
      {
        nixosModule = { pkgs, ... }: {
          services.emacs = {
            enable = true;
            package = makeEmacsPackage pkgs.system;
            defaultEditor = true;
            install = true;
          };
        };
      } // flake-utils.lib.eachDefaultSystem (
        system:
          let
            emacs = makeEmacsPackage system;
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
