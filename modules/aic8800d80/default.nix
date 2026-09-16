{
  config,
  lib,
  pkgs,
  ...
}:

# Out-of-tree AIC8800D80 / UGREEN USB WiFi. Import from any host that has
# the adapter. This flake has no nixpkgs input; consumers use their own
# pkgs. The bundled firmware is unfree.
let
  aic8800d80 = config.boot.kernelPackages.callPackage ./package.nix { };
in
{
  # NixOS wraps the package (aic8800d80-unstable, *-zstd), so match prefix.
  nixpkgs.config.allowUnfreePredicate = lib.mkDefault (
    pkg: lib.hasPrefix "aic8800d80" (lib.getName pkg)
  );

  boot.extraModulePackages = [ aic8800d80 ];
  boot.kernelModules = [
    "aic_load_fw"
    "aic8800_fdrv"
  ];
  hardware.firmware = [ aic8800d80 ];

  # The driver's firmware loader (aic_load_fw) opens firmware files with a raw
  # filp_open() rather than the kernel's request_firmware() API, so it can't
  # see through NixOS's zstd-compressed /run/current-system/firmware. Point it
  # straight at this package's own uncompressed copy instead.
  boot.extraModprobeConfig = ''
    options aic_load_fw aic_fw_path=${aic8800d80}/lib/firmware/aic8800D80
  '';

  # This adapter cold-boots into "Aic MSC" mass-storage mode (a69c:5724) and
  # needs a real SCSI eject to switch into its WiFi identity (a69c:8d80 /
  # UGREEN 368b:8d88) — upstream's own udev rule for this exact device does
  # the same thing.
  #
  # USB autosuspend also drops this chipset. Keep the dongle powered in every
  # known identity; do not disable autosuspend globally.
  services.udev.extraRules = ''
    KERNEL=="sd*", ATTRS{idVendor}=="a69c", ATTRS{idProduct}=="5724", RUN+="${pkgs.util-linux}/bin/eject /dev/%k"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="a69c", ATTR{idProduct}=="5724", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="a69c", ATTR{idProduct}=="8d80", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="368b", ATTR{idProduct}=="8d88", TEST=="power/control", ATTR{power/control}="on"
  '';
}
