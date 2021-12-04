# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Visual Studio Code extensions.
  # Protip: to get sha256 of some extensions, download it from VSCode Marketplace
  # and then run shasum -a 256 on the .vsix file, i.e.
  # shasum -a 256 meraymond.idris-vscode-0.0.11.vsix

  vscode-with-extensions = pkgs.vscode-with-extensions.override
  {
    vscodeExtensions =
      (with pkgs.vscode-extensions;
      [
        bbenoist.nix              # Nix support.
        james-yu.latex-workshop   # Latex support.
      ])
      ++
      pkgs.vscode-utils.extensionsFromVscodeMarketplace
      [
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
      ];
  };
in
{
  imports =
  [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = if builtins.pathExists /sys/firmware/efi/efivars
  then
  {
    # Use the systemd-boot bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.luks.devices.root =
    {
      device = "/dev/sda3";
      preLVM = true;
    };
  }
  else
  {
    loader.grub =
    {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };

    initrd.luks.devices.root =
    {
      device = "/dev/sda2";
      preLVM = true;
    };
  };
  
  networking.hostName = "nixos";           # Define your hostname.
  networking.networkmanager.enable = true; # networking.wireless doesn't work for me.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = false;
  #networking.interfaces.enp2s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  #i18n =
  #{
  #  consoleFont = "Lat2-Terminus16";
  #  consoleKeyMap = "pl";
  #  defaultLocale = "pl_PL.UTF-8";
  #};

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

  # Allow VSCode.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
  [
    konsole cht-sh gnumake lshw usbutils
    pass wl-clipboard # without wl-clipboard, pass -c doesn't work
    gparted ntfsprogs bleachbit
    deja-dup duplicity
    brave youtube-dl
    rhythmbox
    anki
    libreoffice xournal gimp
    slack # tdesktop discord

    nodePackages.node2nix # Useful when working with jsCoq.
    gitAndTools.gitFull
    vscode-with-extensions
    texlive.combined.scheme-full python39Packages.pygments graphviz
    ghc
    coq coqPackages.equations coqPackages.stdpp
    agda
    fstar
    idris2
    z3 stack # Needed to install the Granule language.
  ];

  # Without this, `pass` fails to ask for the gpg password and is thus unusable.
  programs.gnupg.agent.enable = true;

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

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # GNOME desktop.
  services.xserver =
  {
    displayManager.gdm.enable    = true;
    windowManager.i3.enable      = true;
    desktopManager.gnome.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wk =
  {
    isNormalUser = true;
    extraGroups = [ "wheel" "vboxusers" ]; # Provide user with sudo and virtualbox access.
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?
}
