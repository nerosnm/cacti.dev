{
  description = "cacti.dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , flake-utils
    , ...
    } @ inputs:
    let
      inherit (flake-utils.lib) eachSystem;
      supportedSystems = [ "x86_64-linux" ];
    in
    eachSystem supportedSystems (system:
    let
      pkgs = import nixpkgs { inherit system; };

      format-pkgs = with pkgs; [
        nixpkgs-fmt
      ];
    in
    rec {
      defaultPackage = packages.cacti-dev;
      packages = {
        cacti-dev = pkgs.callPackage ./default.nix { };
      };

      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          zola
        ] ++ format-pkgs;
      };

      checks = {
        inherit (packages) neros-dev neros-dev-wip;

        format = pkgs.runCommand
          "check-format"
          { buildInputs = format-pkgs; }
          ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            touch $out
          '';
      };
    });
}
