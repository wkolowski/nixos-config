{ config, ... }:

{
  networking.hostName = "xmg";

  swapDevices =
  [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024; # 64 GB, same as RAM size
    }
  ];

  boot =
  {
    # Ethernet driver.
    kernelModules = [ "yt6801" ];
    extraModulePackages = [ config.boot.kernelPackages.yt6801 ];

    # Hibernate to encrypted swap file.
    resumeDevice = "/dev/mapper/nvme0n1p2_crypt";
    kernelParams = [ "resume_offset=54726656" ];
  };

  # Without this, pressing Power during suspend-then-hibernate hangs the system.
  systemd.sleep.settings.Sleep.HibernateMode = "shutdown";
}
