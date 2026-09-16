# Handoff — 2026-09-16

Public reusable NixOS modules. Consumers pin this flake; they do not vendor copies.

**Owner:** Tyler Moody (`tmoody`). Emails: `tyler@moody.london`, `enquiries@moody.london`.

**Repo:** https://github.com/MoodyLondon/nixos-modules
**Default branch:** `main`
**Consumer (private):** https://github.com/MoodyLondon/nixos-config

---

## Done

- Flake exports **only** `nixosModules.aic8800d80` (`./modules/aic8800d80`)
- No `nixpkgs` input. Hosts pass their own `pkgs`
- No catch-all `nixosModules.default`
- AIC8800D80 / UGREEN USB WiFi 6: out-of-tree driver, unfree firmware, SCSI eject of MSC `a69c:5724`, USB `power/control=on` for `a69c:5724`, `a69c:8d80`, `368b:8d88`
- `allowUnfreePredicate` matches the prefix `aic8800d80` (NixOS wraps as `aic8800d80-unstable` / zstd)

---

## Decisions (do not silently revert)

- Public reusable modules live here. Host-only config stays in `nixos-config`
- Do not add a `nixpkgs` input or a default module
- Do not disable `usbcore.autosuspend` globally; keep the per-ID udev rules
- New modules only when Tyler asks, or when a real second consumer needs the same behaviour

---

## Next

- Add modules only with a real use. Do not invent hardware
- After this repo changes, in `nixos-config` run `nix flake update nixos-modules` and rebuild
- Do not activate machines from this repo
