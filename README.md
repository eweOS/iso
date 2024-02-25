# eweOS ISO Image Maker

## Usage

```
./gen.sh [profile] [target_arch]
```

## Config

- `profiles/{profile}`: 
  - `config.sh`: (Optional) config script in chroot
  - `packages.txt`: packages to be installed
  - `packages.{target_arch}.txt`: (Optional) packages to be installed for a specific arch
- `config`:
  - `common`: common config script in chroot
    - `common/function_enable_service.sh`: functions to be used by config scripts
  - `{profile_set}`: config script in chroot for a specific group of profiles



## Requirement

- pacman + arch-install-scripts (pacstrap + arch-chroot) (chroot support is WIP)
- libisoburn (xorriso)
- wget
- squashfs-tools (mksquashfs)
