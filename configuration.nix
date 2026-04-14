# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  # NixOS unstable channel.
  unstableTarball =
    fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;

  # Visual Studio Code extensions.
  # Protip: to get sha256 of some extensions, download it from VSCode Marketplace
  # and then run shasum -a 256 on the .vsix file, i.e.
  # shasum -a 256 meraymond.idris-vscode-0.0.11.vsix

  # Axi syntax highlighting.
  axi-syntax-highlighting = (pkgs.callPackage /home/wk/Code/Pevnik-Labs/Axi/default.nix {}).vscode-extension;

  vscode-with-extensions = pkgs.vscode-with-extensions.override
  {
    vscodeExtensions =
      (with pkgs.vscode-extensions;
      [
        # Nix support.
        bbenoist.nix

        # Latex support.
        james-yu.latex-workshop

        # Coq support.
        #rocq-prover.vsrocq
        #maximedenes.vscoq

        # Haskell support.
        justusadam.language-haskell
        haskell.haskell

        # Axi support.
        axi-syntax-highlighting
      ])
      ++
      pkgs.vscode-utils.extensionsFromVscodeMarketplace
      [
        {
          name = "vsrocq";
          publisher = "rocq-prover";
          version = "2.3.4";
          sha256 = "1h3y9549jfbmd6lhkncmhfnd7yisjr4j855gnw8bm1bj9c4jhdnv";
        }
        {
          name = "wasm-wasi-core";
          publisher = "ms-vscode";
          version = "1.0.2";
          sha256 = "1j6gjflxhy04jy2jrl2h3l8xzj2bivnd5gws636v7w46yqsczg46";
        }
        {
          name = "coq-lsp";
          publisher = "ejgallego";
          version = "0.2.4";
          sha256 = "0ak9sqbhyrrsz1r0d20mjzdyjw49ry1r3q3h10fp2rqdgf5zcrxk";
        }
        {
          name = "coqpilot";
          publisher = "JetBrains-Research";
          version = "2.4.3";
          sha256 = "16615f3zaa3dhprsw6a845xc3cgfff9l2sd4kaq4fpa8nhic754m";
        }
        {
          # Preview of .dot Graphviz diagrams.
          name = "graphviz-preview";
          publisher = "efanzh";
          version = "1.4.0";
          sha256 = "1n5dbkhz2c1kc5qqykhq3vaa7d1xxf9mqiy8ipr69pxjvkrcg3qz";
        }
        {
          # Idris2 support.
          name = "idris-vscode";
          publisher = "meraymond";
          version = "0.0.11";
          sha256 = "185cf9880cda675aa7a07c73c65a2d9c3026f02c79b183187764f4eb36cedb35";
        }
        #{
        #  # Idris2 support.
        #  name = "idris2-lsp";
        #  publisher = "bamboo";
        #  version = "0.7.0";
        #  sha256 = "f1e2ef1ca50f06881ee74c3339fa7968afd75491255732ad8a5f188fe3f03545";
        #}
        {
          # Lean 4 support.
          name = "lean4";
          publisher = "leanprover";
          version = "0.0.70";
          sha256 = "32de1da75197b5011d7ae9ac8d382c4ad2078817b5b9d294ea021925502f2fae";
        }
        {
          # Unison support. Installation of Unison itself: https://github.com/ceedubs/unison-nix/
          name = "unison";
          publisher = "unison-lang";
          version = "0.0.8";
          sha256 = "b66ab579f00fdd98e9f3206e29a7edd2368c4efbdb7511b3ac991d9eec807880";
        }
        {
          # Twelf support.
          name = "twelf-extension-pack";
          publisher = "ivan-m";
          version = "1.0.1";
          sha256 = "e90d4d6f1ad5c439af8c91bd80d8f227cf4debf6c85b82a2349302837b8d999a";
        }
        {
          # Athena support. Installation of Athena from source: https://github.com/AthenaFoundation/athena/wiki/Building-Athena
          name = "athena-language";
          publisher = "athenafoundation";
          version = "0.0.1";
          sha256 = "b6ebbc82b1ac4ab4adcf71b885b74568d3e33dc917ae238cc7597eb1768719be";
        }
      ];
  };
in
{
  nixpkgs.config =
  {
    # Make the unstable channel available.
    packageOverrides = pkgs:
    {
      unstable = import unstableTarball
      {
        config = config.nixpkgs.config;
      };
    };

    # Allow proprietary and broken packages, like VSCode and... well, I don't remember what's broken.
    allowUnfree = true;
    allowBroken = true;
  };

  imports =
  [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use latest stable kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Ethernet driver.
  boot.extraModulePackages =
  [
    config.boot.kernelPackages.yt6801
  ];

  boot.kernelModules = [ "yt6801" ];

  # Hibernate to encrypted swap file.
  powerManagement.enable = true;

  swapDevices =
  [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024; # 64 GB, same as RAM size
    }
  ];

  boot.resumeDevice = "/dev/mapper/nvme0n1p2_crypt";
  boot.kernelParams = [ "resume_offset=54726656" ];

  systemd.sleep.extraConfig =
  ''
    HibernateDelaySec=5min
  '';

  # Doesn't work...
  services.logind.settings.Login =
  {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandlePowerKey = "suspend-then-hibernate";
  };

  boot.loader =
  {
    # Use the systemd-boot bootloader.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };

  # Turn on zram swap.
  zramSwap =
  {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  
  networking.hostName = "nixos";           # Define your hostname.

  networking.networkmanager =
  {
    enable = true;
    wifi.powersave = false;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = false;
  #networking.interfaces.enp2s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n =
  {
    defaultLocale = "en_GB.UTF-8";
    extraLocales = [ "en_GB.UTF-8/UTF-8" ];
  };

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

  # Beware: in case of problems with Polish keyboard layout (with the letter ę) try these:
  # nix-shell -p gnome3.dconf --run "dconf read /org/gnome/desktop/input-sources/xkb-options"
  # nix-shell -p gnome3.dconf --run "dconf reset /org/gnome/desktop/input-sources/xkb-options"

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Beware! Never install virtualbox using environment.systemPackages.virtualbox.
  # It doesn't work and results in the error "Kernel driver not accessible".
  # Note that the extension pack makes virtualbox recompile from source which takes a very long time.
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
  [
    kdePackages.konsole gnumake lshw usbutils pciutils shellcheck
    gedit
    pass wl-clipboard # without wl-clipboard, pass -c doesn't work
    bleachbit # ntfsprogs
    restic
    brave #firefox unstable.yt-dlp
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
    vscode-with-extensions
    unstable.code-cursor
    unstable.claude-code
    unstable.codex

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
    ghc haskellPackages.haskell-language-server #haskellPackages.alex haskellPackages.happy

    coq_8_20 coqPackages_8_20.coqide coqPackages_8_20.coq-lsp rocqPackages.vsrocq-language-server coqPackages_8_20.vscoq-language-server (lib.getBin coqPackages_8_20.vscoq-language-server)
    #(coq_9_1.override { buildIde = true; })

    #agda
    #fstar
    #idris2
    #z3 stack # Needed to install the Granule language.
    #twelf
    #smlnj mlton rlwrap # Needed to build Athena from source.
  ];

  # `sudo` password is cached for 15 minutes.
  security.sudo.extraConfig =
  ''
    Defaults timestamp_timeout=15
  '';

  programs.gnupg.agent =
  {
    # Without this, `pass` fails to ask for the gpg password and is thus unusable.
    enable = true;

    # Password is cached for 15 minutes.
    settings =
    {
      default-cache-ttl = 900;
    };
  };

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

        "org/gnome/desktop/wm/preferences" =
        {
          num-workspaces = lib.gvariant.mkInt32 1;
        };

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
      };
    }
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable bluetooth.
  hardware.bluetooth.enable = true;

  # Enable sound. Use PulseAudio, disable PipeWire.
  services =
  {
    # Turn on support for some YubiKey features.
    pcscd.enable = true;

    # Daemon for updating firmware.
    fwupd.enable = true;

    # Sound.
    pipewire =
    {
      enable = true;
      pulse.enable = true;
    };

    pulseaudio.enable = false;

    # Enable the X11 windowing system.
    xserver.windowManager.i3.enable = true;
    xserver.enable = true;
    xserver.xkb.layout = "us";

    # GNOME desktop.
    displayManager.gdm.enable       = true;
    desktopManager.gnome.enable     = true;
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

      # Provide user with sudo and virtualbox access.
      extraGroups = [ "wheel" "vboxusers" ];
    };
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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.11"; # Did you read the comment?

  nix =
  {
    settings =
    {
      # Turn on flakes and nix-command.
      experimental-features = [ "nix-command" "flakes" ];

      # 0 means "use all available cores"
      cores = 0;
      max-jobs = "auto";
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
}
