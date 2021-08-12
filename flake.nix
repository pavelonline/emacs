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
            emacsOrig = (makePkgs system).emacs;
            emacs = makeEmacsPackage system;
          in
            rec {
              defaultPackage = emacs;
              packages = {
                inherit emacsOrig;
              };
              defaultApp = {
                type = "app";
                program = "${emacs}/bin/emacs";
              };
              checks = { inherit emacs; };
            }
      );
}
