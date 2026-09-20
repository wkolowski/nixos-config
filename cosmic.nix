{ pkgs, ... }:

let
  cosmicDefaults = pkgs.runCommand "cosmic-defaults" {}
  ''
    mkdir -p $out/share/cosmic/com.system76.CosmicComp/v1

    cat > $out/share/cosmic/com.system76.CosmicComp/v1/xkb_config <<'EOF'
    (
      rules: "",
      model: "",
      layout: "pl,us",
      variant: ",altgr-intl",
      options: None,
      repeat_delay: 600,
      repeat_rate: 25,
    )
    EOF
  '';
in
{
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  environment.systemPackages =
  [
    cosmicDefaults
  ];
}
