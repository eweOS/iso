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
  - `files/`: (Optional) files to be used in global `config.sh`, installed to `/.files/` before `config.sh`
  - `subprofiles/{subprofile}/`: (Optional) subprofile directory
    - `config.sh`: (Optional) config script in chroot
    - `files/`: (Optional) files to be used in subprofile level `config.sh`, installed to `/.files/` before `config.sh`
    - `title.txt`: (Optional) title to be used in limine menu, which defaults to be subprofile name
  - `default_subprofile.txt`: (Optional) default subprofile
- `config`:
  - `common`: common config script in chroot
    - `common/function_enable_service.sh`: functions to be used by config scripts
  - `{profile_set}`: config script in chroot for a specific group of profiles


## Requirement

- pacman + arch-install-scripts (pacstrap + arch-chroot) (chroot support is WIP)
- libisoburn (xorriso)
- wget
- squashfs-tools (mksquashfs)

## Workflow

- `utils/pacman-config.sh`: configures `pacman.conf`
- `utils/cleanup.sh`: executes pre-task cleanup
- `utils/install.sh`:
  - create and mount `base` layer: install base system
  - create and mount `base` + `packages` layers: install packages, install arch-specific packages (if any)
- `utils/hook.sh`: 
  - create and mount `base` + `packages` + `live` layers
  - mounts `boot` partition (if liveimage)
  - copy files to be used in global config hooks (if any)
  - executes global config hooks (in `config/`)
  - executes profile config hooks (in `profiles/{profile}/config.sh`)
  - clean used files by config hooks
- `utils/hooks-subprofiles.sh`: (if liveimage and any subprofile)
  - create and mount `base` + `packages` + `live` + `live-{subprofile}` layers
  - copy files to be used in subprofile config hooks (if any)
  - executes subprofile config hooks (in `profiles/{profile}/subprofiles/{subprofile}/config.sh`)
  - clean used files by config hooks
- `utils/limine_menu.sh`: (if liveimage and any subprofile)
  - generate and override limine config
- `utils/collect_tarball.sh`: compress tarball and make checksum (if tarball)
- `utils/collect_liveimage.sh`: (if liveimage)
  - make squashfs for each layer
  - make iso from isofs directory
  - chroot into `base` + `packages` layers to install BIOS bootloader (if x86)
  - make checksum
- `utils/cleanup.sh`: executes post-task cleanup

## Layered Squashfs

- base: base packages
- packages: profile packages
- live: profile live config
- live-{subprofile}: subprofile live config

## TODO

- create local repo in iso

