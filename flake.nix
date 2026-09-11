{
  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";

      unstablePkgs = import nixpkgs-unstable
      {
        inherit system;

        config =
        {
          allowUnfree = true;
          allowBroken = true;
        };
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem
      {
        inherit system;

        specialArgs =
        {
          inherit unstablePkgs;
        };

        modules =
        [
          ./configuration.nix
          ./hardware-configuration-xmg.nix
        ];
      };
    };
}
