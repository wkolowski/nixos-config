{ pkgs, ... }:

{
  # 32-bit graphics support needed by Windows games/Wine.
  hardware.graphics.enable32Bit = true;

  nixpkgs.config.allowUnfree = true;

  programs.steam =
  {
    enable = true;

    extraPackages = with pkgs;
    [
      adwaita-icon-theme
    ];
  };

  environment.systemPackages = with pkgs;
  [
    lutris
    protonup-qt
    heroic
  ];
}
