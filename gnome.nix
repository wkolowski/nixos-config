{ pkgs, lib, ... }:

{
  services =
  {
    # GNOME desktop.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Turn off GNOME's SSH agent.
    gnome.gcr-ssh-agent.enable = false;
  };

  environment.systemPackages = with pkgs;
  [
    # Manage buttons in the top-right menu.
    gnomeExtensions.power-off-options

    # Declutter the system calendar.
    gnomeExtensions.just-perfection
  ];

  # Remove clutter apps.
  environment.gnome.excludePackages = with pkgs;
  [
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-color-manager
    gnome-connections
    gnome-console
    gnome-contacts
    gnome-disk-utility
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-text-editor
    gnome-tour
    gnome-weather
    decibels
    epiphany
    seahorse
    simple-scan
    snapshot
    yelp
  ];

  # GNOME-specific settings.
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases =
  [
    {
      lockAll = true;
      settings =
      {
        # Turn on fractional scaling.
        "org/gnome/mutter" =
        {
          dynamic-workspaces = false;
          experimental-features =
          [
            "scale-monitor-framebuffer"
            "xwayland-native-scaling"
          ];
        };

        # Keyboard.
        "org/gnome/desktop/input-sources" =
        {
          sources =
          [
            (lib.gvariant.mkTuple [ "xkb" "pl" ])
            (lib.gvariant.mkTuple [ "xkb" "us+altgr-intl" ])
          ];
        };

        # Disable the touchpad.
        "org/gnome/desktop/peripherals/touchpad" =
        {
          send-events = "disabled";
        };

        # There should be only one workspace.
        "org/gnome/desktop/wm/preferences" =
        {
          num-workspaces = lib.gvariant.mkInt32 1;
        };

        # Turn on Night Light.
        "org/gnome/settings-daemon/plugins/color" =
        {
          night-light-enabled = true;
          night-light-schedule-automatic = false;
        };

        # Clock settings.
        "org/gnome/desktop/interface" =
        {
          clock-format = "24h";
          clock-show-date = false;
          clock-show-seconds = false;
          clock-show-weekday = true;
        };

        "org/gnome/shell" =
        {
          # Skip the tutorial.
          welcome-dialog-last-shown-version = "4294967295";

          # Pin apps to the bottom bar.
          favorite-apps =
          [
            "brave-browser.desktop"
            "org.kde.konsole.desktop"
            "org.gnome.gedit.desktop"
            "org.gnome.SystemMonitor.desktop"
            "org.gnome.baobab.desktop"
            "org.gnome.Nautilus.desktop"
            "org.gnome.Rhythmbox3.desktop"
          ];

          # Turn on the extensions.
          enabled-extensions =
          [
            pkgs.gnomeExtensions.power-off-options.extensionUuid
            pkgs.gnomeExtensions.just-perfection.extensionUuid
          ];
        };

        # Nautilus: use list view.
        "org/gnome/nautilus/preferences" =
        {
          default-folder-viewer = "list-view";
        };

        # Nautilus list view: name, size, date of last modification.
        "org/gnome/nautilus/list-view" =
        {
          default-visible-columns =
          [
            "name"
            "size"
            "date_modified"
          ];

          default-column-order =
          [
            "name"
            "size"
            "date_modified"
          ];
        };

        # Configure the top right corner menu.
        # There should be suspend-then-hibernate and hibernate,
        # but no suspend nor other clutter.
        "org/gnome/shell/extensions/power-off-options" =
        {
          show-hibernate = true;
          show-suspend-then-hibernate = true;

          show-hybrid-sleep = false;
          show-screenoff = false;
          show-soft-reboot = false;
          show-reboot-to-bios = false;
          show-settings = false;
        };

        # Declutter the calendar.
        "org/gnome/shell/extensions/just-perfection" =
        {
          events-button = false;
          weather = false;
          world-clock = false;

          # Turn off the pop-up that begs for donations.
          support-notifier-type = lib.gvariant.mkInt32 0;
        };

        # Turn off the pop-up that begs for donations.
        "org/gnome/settings-daemon/plugins/housekeeping" =
        {
          donation-reminder-enabled = false;
        };
      };
    }
  ];
}
