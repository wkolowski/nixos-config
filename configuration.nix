# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # NixOS unstable channel.
  unstableTarball =
    fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;

  # Visual Studio Code extensions.
  vscode-with-extensions = pkgs.vscode-with-extensions.override
  {
    vscodeExtensions =
      (with pkgs.vscode-extensions;
      [
        bbenoist.Nix              # Nix support.
        james-yu.latex-workshop   # Latex support.
      ])
      ++
      pkgs.vscode-utils.extensionsFromVscodeMarketplace
      [
        { # Preview of .dot Graphviz diagrams.
          name = "graphviz-preview";
          publisher = "efanzh";
          version = "1.4.0";
          sha256 = "1n5dbkhz2c1kc5qqykhq3vaa7d1xxf9mqiy8ipr69pxjvkrcg3qz";
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

    # Allow VSCode.
    allowUnfree = true;
  };

  imports =
  [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot =
  {
    # Use the systemd-boot bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.luks.devices.root =
    {
      device = "/dev/sda3";
      preLVM = true;
    };

    # This is required for my network card to work properly.
    # TODO: change when kernel 5.8 is available out of the box.
    kernelPackages = pkgs.unstable.linuxPackages_5_8;
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
  # Note that the extension pack makes virtualbox recompile from source which takes long.
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
  [
    konsole wget file gnumake lshw usbutils
    gparted
    pass
    deja-dup
    brave openvpn youtube-dl
    gitAndTools.gitFull
    vscode-with-extensions
    texlive.combined.scheme-full python38Packages.pygments graphviz
    unstable.coq_8_12 unstable.coqPackages.equations
    unstable.ghc
    anki
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
    desktopManager.gnome3.enable = true;
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
  system.stateVersion = "20.09"; # Did you read the comment?
}
