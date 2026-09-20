{
  inputs =
  {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { nixpkgs, nixpkgs-unstable, nix-vscode-extensions, ... }:
    let
      system = "x86_64-linux";

      unstablePkgs = import nixpkgs-unstable
      {
        inherit system;

        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.xmg = nixpkgs.lib.nixosSystem
      {
        inherit system;

        specialArgs =
        {
          inherit unstablePkgs nix-vscode-extensions;
        };

        modules =
        [
          ./hardware-configuration-xmg.nix
          ./xmg.nix
          ./configuration.nix
          ./gnome.nix
          ./vscode.nix
          ./gaming.nix
        ];
      };
    };
}
