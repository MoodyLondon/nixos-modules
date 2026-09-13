{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation {
  pname = "aic8800d80";
  version = "unstable-2026-06-04";

  src = fetchFromGitHub {
    owner = "kilam994";
    repo = "aic8800d80-linux-driver";
    rev = "65f74ccbe982d9242afd1b3126a28fc3a77abb4f";
    sha256 = "0zfn0a5zvwf6qm3qlpgzakppz76j4jj9jmpmyn09kcl9hrxhz0zw";
  };

  # Upstream aic_load_fw never registered 368b:8d88 (UGREEN). Without it
  # the loader never binds and the radio never gets firmware.
  patches = [ ./8d88.patch ];

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [
    "pic"
    "format"
  ];

  makeFlags = [
    "-C"
    "drivers/aic8800"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KVER=${kernel.modDirVersion}"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildFlags = [ "modules" ];

  installPhase = ''
    runHook preInstall

    moddir=$out/lib/modules/${kernel.modDirVersion}/extra/aic8800
    mkdir -p $moddir
    install -m 644 drivers/aic8800/aic_load_fw/aic_load_fw.ko $moddir/
    install -m 644 drivers/aic8800/aic8800_fdrv/aic8800_fdrv.ko $moddir/

    fwdir=$out/lib/firmware
    mkdir -p $fwdir
    cp -r fw/aic8800* $fwdir/

    runHook postInstall
  '';

  meta = {
    description = "Out-of-tree driver for the AICSemi AIC8800D80 USB WiFi 6 chipset (incl. UGREEN AX900, 368b:8d88)";
    homepage = "https://github.com/kilam994/aic8800d80-linux-driver";
    license = lib.licenses.unfree; # vendor blob firmware bundled alongside GPL-ish driver source
    platforms = [ "x86_64-linux" ];
  };
}
