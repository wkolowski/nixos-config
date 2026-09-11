{
  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/0c88e1f2bdb93d5999019e99cb0e61e1fe2af4c5";

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
