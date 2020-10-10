# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let unstableTarball =
  fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  nixpkgs.config =
  {
    packageOverrides = pkgs:
    {
      unstable = import unstableTarball
      {
        config = config.nixpkgs.config;
      };
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices =
  {
    root =
    {
      device = "/dev/sda3";
      preLVM = true;
    };
  };

  # This is required for my network card to work properly.
  # TODO: change when kernel 5.8 is available out of the box.
  boot.kernelPackages = pkgs.unstable.linuxPackages_5_8;

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
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Beware! Never install virtualbox using environment.systemPackages.virtualbox.
  # It doesn't work and results in the error "Kernel driver not accessible".
  # Note that the extension pack makes virtualbox recompile from source which takes long.
  # TODO: virtualbox doesn't work with kernel 5.8 because of compilation error, so it's off.
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
  [
    pass gnupg pinentry-curses deja-dup bleachbit
    konsole wget file gnumake lshw gparted
    brave openvpn youtube-dl
    gitAndTools.gitFull
    vscode
    texlive.combined.scheme-medium
    pygmentex graphviz
    unstable.coq_8_12
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
  services.xserver.xkbOptions = "eurosign:e";

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
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  users.extraGroups.vboxusers.members = [ "wk" ]; # Required for virtualbox to work.

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

  # Custom stuff here.
  nixpkgs.config.allowUnfree = true;
}
