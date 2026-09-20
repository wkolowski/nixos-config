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
  };

  environment.systemPackages = with pkgs;
  [
    kdePackages.konsole gnumake lshw usbutils pciutils shellcheck
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

  xdg.mime.defaultApplications =
  {
    # Set Brave as the default browser.
    "text/html" = "brave-browser.desktop";
    "application/xhtml+xml" = "brave-browser.desktop";
    "x-scheme-handler/http" = "brave-browser.desktop";
    "x-scheme-handler/https" = "brave-browser.desktop";
    "x-scheme-handler/about" = "brave-browser.desktop";
    "x-scheme-handler/unknown" = "brave-browser.desktop";

    # Open .csv files using gedit.
    "text/csv" = "org.gnome.gedit.desktop";
    "text/comma-separated-values" = "org.gnome.gedit.desktop";
    "text/x-csv" = "org.gnome.gedit.desktop";
    "text/x-comma-separated-values" = "org.gnome.gedit.desktop";
    "application/csv" = "org.gnome.gedit.desktop";

    # Open .xml files using gedit.
    "text/xml" = "org.gnome.gedit.desktop";
    "application/xml" = "org.gnome.gedit.desktop";
  };

  programs.gnupg.agent =
  {
    # Without this, `pass` fails to ask for the gpg password and is thus unusable.
    enable = true;

    # Turn on SSH.
    enableSSHSupport = true;

    # Password is cached for 15 minutes.
    settings.default-cache-ttl = 900;
  };

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
