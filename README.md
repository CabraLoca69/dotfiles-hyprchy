## Hardware compatibility

Tested on AMD CPU + AMD GPU (ROCm). Other hardware configurations are not guaranteed to work out of the box:

- **Nvidia** — Hyprland has known issues with Nvidia. You may need additional configuration. See [Hyprland wiki - Nvidia](https://wiki.hyprland.org/Nvidia/).
- **Intel GPU** — should work but is untested.
- **Laptops** — brightness, touchpad, and power profile scripts may need adjustment.

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
- Helper scripts for GPU/CPU drivers and system bootstrap (multilib, services, display manager)

---

## Dependencies

Package lists live in [`dependencies`](./dependencies), separate from the installer
logic in `install-all`. If a specific package hangs the install (bad mirror, AUR package
that won't compile, flaky connection, etc), open `dependencies`, comment out that one
line with `#`, and re-run `./install-all` — everything else installs normally. Once you've
sorted out whatever was blocking it, install that package by hand
(`sudo pacman -S <pkg>` or `paru -S <pkg>`) and uncomment the line for next time.

### Base (pacman)

Hyprland, Waybar, Alacritty, Nautilus, fonts, and other core packages.
The installer handles these automatically.

### AUR (requires [paru](https://github.com/Morganamilo/paru))

- `elephant` + modules — app launcher data sources
- `xdg-terminal-exec` — default terminal handler
- `yaru-icon-theme` — icon theme
- `linux-wallpaperengine-git` — Wallpaper Engine on Linux
- `sunwait` — sunrise/sunset for `hyprsunset_daynight`
- `hyprland-preview-share-picker-git` — screen share preview

### CachyOS repo (optional but recommended)

- `walker` — application launcher (menus, app switcher)

Without walker the launcher won't work. You can either:
- Add the CachyOS repo: [wiki.cachyos.net/installation/repos](https://wiki.cachyos.net/installation/repos/)
- Or install from AUR: `paru -S walker-bin`

### Manual / hardware-specific

- **ROCm** (`rocm-smi`) — for `waybar-gpu`, AMD GPU only
- **Wallpaper Engine** — must be purchased and installed via Steam

---

## Installation

### Option A — one-shot (recommended for a fresh install)

`install-all` chains everything below (paru → dotfiles → drivers → system
bootstrap) in the right order, and is safe to re-run if something fails partway
through — every step checks what's already done before touching anything.

```bash
git clone https://github.com/CabraLoca69/dotfiles-hyprchy.git
cd dotfiles-hyprchy
chmod +x install-all
./install-all
```

Do **not** run it with `sudo` — it asks for your password internally where needed.
Compiling `paru` requires a regular user, not root.

At the end it'll suggest a reboot. Do it, or log out and back in, to land on Hyprland
via the display manager it set up.

### Option B — step by step

<details>
<summary>Starting from a fresh CachyOS install (no DE)?</summary>

Make sure you have `paru` before running the installer:

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
chmod +x install-hyprchy
./install-hyprchy
```

2. (Optional but recommended) Install CPU/GPU drivers:

```bash
chmod +x install-drivers
./install-drivers
```

3. (Optional but recommended) Run the system bootstrap — enables `[multilib]`,
   `NetworkManager`, `bluetooth`, fixes `gnome-keyring` + PAM integration, and
   installs/enables a display manager (`sddm`) if none is present:

```bash
chmod +x bootstrap-system
./bootstrap-system
```

4. Reboot or log out and back in to start Hyprland.

---

## Hardware notes

You may reconfigure hyprland for your monitors, go to `.config/hypr/monitors.lua` and change that.

Some Waybar scripts read sensor paths that vary by hardware.
At the moment the only waybar theme modified like this is `event-horizon`. You can change
the active modules if you want — `custom/gpu` and `custom/cpu-watts` are the ones that use
these scripts.

The waybar themes path is `.config/waybar/themes`.

These two are ones that reads paths hardcoded go and modify it or change the waybar theme:

`.local/bin/waybar-cpu-watts`:
```
/sys/class/hwmon/hwmon3/energy9_input   → CPU energy
/sys/class/hwmon/hwmon4/temp1_input     → CPU temperature
```

`.local/bin/waybar-gpu`:
```
/sys/class/hwmon/hwmon2/power1_average  → GPU power draw
```

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