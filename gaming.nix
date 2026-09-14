{ pkgs, ... }:

{
  # 32-bit graphics support needed by Windows games/Wine.
  hardware.graphics.enable32Bit = true;

  environment.systemPackages = with pkgs;
  [
    lutris
  ];
}
