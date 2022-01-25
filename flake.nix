{
  description = "My customized emacs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    emacs-overlay.url = github:nix-community/emacs-overlay;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils }:
    {
      homeManagerModule = { pkgs, ... }:
        {
          nixpkgs.overlays = [ emacs-overlay.overlay (import ./overlay.nix) ];
          services.emacs = {
            enable = true;
            package = pkgs.emacsSvrg;
            client = {
              enable = true;
            };
            socketActivation.enable = true;
            extraConfig = ./emacs.el;
            defautEditor = true;
          };
          home.packages = with pkgs; [
            fira-code
            fira-code-symbols
          ];
        };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (import nixpkgs {
          inherit system;
          overlays = [
            (nixpkgs.lib.composeManyExtensions [
              emacs-overlay.overlay
              (import ./overlay.nix)
            ])
          ];
        })
          emacsSvrg;
      in
      {
        defaultPackage = emacsSvrg;
        defaultApp = {
          type = "app";
          program = "${emacsSvrg}/bin/emacs";
        };
      }
    );
}
