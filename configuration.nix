{ pkgs, lib, unstablePkgs, ... }:

{
  # Turn on zram swap.
  zramSwap =
  {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.loader =
  {
    # Use the systemd-boot bootloader.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };

  systemd.sleep.settings.Sleep =
  {
    # suspend is not allowed.
    AllowSuspend = false;

    # suspend-then-hibernate will hibernate after 10 minutes.
    AllowSuspendThenHibernate = true;
    HibernateDelaySec = "10min";
  };

  # Lid should do nothing.
  services.logind.settings.Login =
  {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  hardware.bluetooth.enable = true;

  networking.networkmanager =
  {
    enable = true;
    wifi.powersave = false;
  };

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_GB.UTF-8";

  fonts =
  {
    enableDefaultPackages = true;
    packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
 };

  # Block logging in as root, i.e. using `su`, to reduce attack surface
  # and so that I don't need to remember an additional password.
  system.activationScripts.lockRoot =
  {
    deps = [ "users" ];
    text =
    ''
      ${pkgs.shadow}/bin/passwd -l root > /dev/null 2>&1 || true
    '';
  };

  users =
  {
    # User management is imperative, because we don't want to
    # store password hashes in the config.
    mutableUsers = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.wk =
    {
      isNormalUser = true;

      # Provide user with sudo.
      extraGroups = [ "wheel" ];
    };
  };

  # `sudo` password is cached for 15 minutes.
  security.sudo.extraConfig =
  ''
    Defaults timestamp_timeout=15
  '';

  services =
  {
    # Turn on support for some YubiKey features.
    pcscd.enable = true;

    # Daemon for updating firmware.
    fwupd.enable = true;

    # Use PipeWire, disable PulseAudio.
    pipewire =
    {
      enable = true;
      pulse.enable = true;
    };

    pulseaudio.enable = false;

    # X11 support, including i3.
    xserver =
    {
      enable = true;
      windowManager.i3.enable = true;
      xkb.layout = "us";
    };

    # GNOME desktop.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs;
  [
    kdePackages.konsole gnumake lshw usbutils pciutils shellcheck
    gnomeExtensions.power-off-options
    gedit
    pass wl-clipboard # without wl-clipboard, pass -c doesn't work
    bleachbit # ntfsprogs
    restic
    unstablePkgs.brave #firefox unstablePkgs.yt-dlp
    # calibre # For converting between ebook formats. Tip: better use `nix-shell -p calibre`
    rhythmbox
    anki
    libreoffice gimp

    # Tools for YubiKey.
    yubikey-manager
    yubioath-flutter
    pcsclite

    #nodePackages.node2nix # Useful when working with jsCoq.
    gitFull
    #unstablePkgs.code-cursor
    #unstablePkgs.claude-code
    unstablePkgs.codex

    (texlive.combine
      {
        inherit (texlive)
        scheme-basic
        latexmk
        beamer
        minted
        ;
      })
    python3Packages.pygments graphviz
    ghc haskellPackages.haskell-language-server

    coq_8_20 coqPackages_8_20.coqide coqPackages_8_20.coq-lsp rocqPackages.vsrocq-language-server coqPackages_8_20.vscoq-language-server (lib.getBin coqPackages_8_20.vscoq-language-server)

    #agda
    #fstar
    #idris2
    #z3 stack # Needed to install the Granule language.
    #twelf
    #smlnj mlton rlwrap # Needed to build Athena from source.
  ];

  programs.gnupg.agent =
  {
    # Without this, `pass` fails to ask for the gpg password and is thus unusable.
    enable = true;

    # Password is cached for 15 minutes.
    settings.default-cache-ttl = 900;
  };

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

        # There should be only one workspace.
        "org/gnome/desktop/wm/preferences" =
        {
          num-workspaces = lib.gvariant.mkInt32 1;
        };

        # Pin apps to the app bar.
        "org/gnome/shell" =
        {
          favorite-apps =
          [
            "brave-browser.desktop"
            "org.kde.konsole.desktop"
            "org.gnome.SystemMonitor.desktop"
            "org.gnome.baobab.desktop"
            "org.gnome.Nautilus.desktop"
            "org.gnome.Rhythmbox3.desktop"
            "anki.desktop"
            "code.desktop"
            "coqide.desktop"
            "org.gnome.gedit.desktop"
          ];
        };

        # Configure top right corner menu. There should be suspend-then-hibernate
        # and hibernate, but no suspend nor other clutter.
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
      };
    }
  ];

  nix =
  {
    settings =
    {
      # 0 means "use all available cores".
      cores = 0;
      max-jobs = "auto";

      # Turn on flakes and nix-command.
      experimental-features =
      [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
    };

    gc =
    {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 365d";
    };

    optimise =
    {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.11"; # Did you read the comment?
}
