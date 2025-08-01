{
  description = "Azure VPN Client package and NixOS module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { nixpkgs, ... }:
    let
      overlay = final: prev: {
        microsoft-azurevpnclient =
          prev.callPackage ./packages/microsoft-azurevpnclient.nix { };
      };

      systems = [ "x86_64-linux" ];

      # import nixpkgs with the overlay for each target system
      forAll = f: nixpkgs.lib.genAttrs systems (system:
        f (import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        })
      );
    in {
      inherit overlay;

      packages = forAll (pkgs: {
        azurevpnclient = pkgs.microsoft-azurevpnclient;
        default        = pkgs.microsoft-azurevpnclient;
      });

      devShells = forAll (pkgs: {
        default = pkgs.mkShell { packages = [ pkgs.microsoft-azurevpnclient ]; };
      });

      nixosModules.azurevpnclient = import ./modules/azurevpnclient.nix;
    };
}
