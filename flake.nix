{
  description = "My customized emacs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    emacs-overlay.url = github:nix-community/emacs-overlay;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils }:
    let
      makePkgs = system: (
        import nixpkgs {
          inherit system;
          overlays = [ emacs-overlay.overlay ];
        }
      );
      makeEmacsPackage = system: (makePkgs system).callPackage ./. {};
    in
      {
        nixosModule = { pkgs, ... }: {
          services.emacs = {
            enable = true;
            package = makeEmacsPackage pkgs.system;
            defaultEditor = true;
            install = true;
          };
          fonts.fonts = with pkgs; [
            fira-code
            fira-code-symbols
          ];
        };
      } // flake-utils.lib.eachDefaultSystem (
        system:
          let
            pkgs = makePkgs system;
            emacsOrig = pkgs.emacs;
            emacs = makeEmacsPackage system;
            snap = pkgs.snapTools.makeSnap {
              meta = {
                name = "svrg-emacs";
                apps.svrg-emacs = {
                  command = "${emacs}/bin/emacs";
                  plugs = [
                    "desktop"
                    "home"
                    "network"
                    "x11"
                  ];
                };
                confinement = "strict";
              };
            };
          in
            rec {
              defaultPackage = emacs;
              packages = {
                inherit emacsOrig snap;
              };
              defaultApp = {
                type = "app";
                program = "${emacs}/bin/emacs";
              };
              checks = { inherit emacs snap; };
            }
      );
}
