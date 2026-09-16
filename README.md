# nixos-modules

Reusable NixOS modules. This flake has **no `nixpkgs` input**; consumers use their own `pkgs`.

There is no catch-all default module. Import only the modules you need.

## `aic8800d80`

Out-of-tree driver and unfree firmware for the AICSemi AIC8800D80 USB WiFi 6 chipset, including UGREEN AX900 (`368b:8d88`).

The adapter cold-boots as USB mass storage (`a69c:5724`) and needs a SCSI eject to become WiFi (`a69c:8d80` / UGREEN `368b:8d88`). The module ships that udev rule and disables USB autosuspend for those device IDs so the radio does not drop.

NixOS wraps the package (`aic8800d80-unstable`, zstd). The module allows unfree names with the prefix `aic8800d80`. A bare pname allowlist is not enough.

### Use from another flake

```nix
{
  inputs.nixos-modules.url = "github:MoodyLondon/nixos-modules";

  outputs =
    { nixpkgs, nixos-modules, ... }:
    {
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit nixos-modules; };
        modules = [ ./configuration.nix ];
      };
    };
}
```

```nix
{ nixos-modules, ... }:
{
  imports = [ nixos-modules.nixosModules.aic8800d80 ];
}
```
