# dotfiles-hyprchy

Personal Hyprland setup built on top of a decoupled [Omarchy](https://omarchy.org) base.
Omarchy's structure is included directly in this repo — no need to install it separately.

> **Work in progress.** Tested on CachyOS. Should work on any Arch-based distro with Hyprland.

---

## What's included

- Hyprland config with keybinds, window rules, and animations
- Waybar with custom scripts (CPU watts, GPU usage, wallpaper picker)
- Omarchy's bin, themes, and default apps — modified and self-contained
- Scripts for floating terminals, wallpaper management, and more

---

## Dependencies

### Base (pacman)
Hyprland, Waybar, Alacritty, Nautilus, fonts, and other core packages.
The installer handles these automatically.

### AUR (requires [paru](https://github.com/Morganamilo/paru))
- `elephant` + modules — app launcher data sources
- `xdg-terminal-exec` — default terminal handler
- `yaru-icon-theme` — icon theme
- `linux-wallpaperengine-git` — Wallpaper Engine on Linux
- `sunwait` — sunrise/sunset for `hyprsunset_daynight.sh`
- `hyprland-preview-share-picker-git` — screen share preview

### CachyOS repo (optional but recommended)
- `walker` — application launcher (menus, app switcher)

Without walker the launcher won't work. You can either:
- Add the CachyOS repo: [wiki.cachyos.net/installation/repos](https://wiki.cachyos.net/installation/repos/)
- Or install from AUR: `paru -S walker-bin`

### Manual / hardware-specific
- **ROCm** (`rocm-smi`) — for `waybar-gpu.sh`, AMD GPU only
- **Wallpaper Engine** — must be purchased and installed via Steam

---

## Installation

<details>
<summary>Starting from a fresh CachyOS install (no DE)?</summary>

Make sure you have the basics before running the installer:

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
cd ~
```

</details>

1. Clone and run the installer:
```bash
git clone https://github.com/CabraLoca69/dotfiles-hyprchy.git
cd dotfiles-hyprchy
chmod +x install.sh
./install.sh
```

2. Reboot or log out and back in to start Hyprland.

---

## Hardware notes

Some Waybar scripts read sensor paths that vary by hardware.
At the moment the only waybar modified like this is in the theme sakura-mochi, you can change the active modules if you want, custom/gpu and custom/cpu-watts are the ones that uses this scripts

`waybar-cpu-watts`:
/sys/class/hwmon/hwmon3/energy9_input   → CPU energy

/sys/class/hwmon/hwmon4/temp1_input     → CPU temperature

`waybar-gpu`:
/sys/class/hwmon/hwmon2/power1_average  → GPU power draw

To find the correct paths on your machine:
```bash
ls /sys/class/hwmon/
cat /sys/class/hwmon/hwmon*/name
```

---

## Credits

- [Omarchy](https://github.com/basecamp/omarchy) by Basecamp/DHH — the base this is built on
- [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) by Almamu
- Themes and Waybar configs by [HANCORE-linux](https://github.com/HANCORE-linux) and [OldJobobo](https://github.com/OldJobobo)


---

## License

MIT