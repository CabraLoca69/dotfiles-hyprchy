# dotfiles
# ESTE REPOSITORIO ESTA EN DESARROLLO, NO RECOMIENDO HACER NADA DE LO QUE DICE ESTE README, ACTUAR BAJO DISCRECION



Setup personal de Hyprland sobre una base de [Omarchy](https://omarchy.org) desacoplada.
El entorno es un híbrido: Hyprland y Omarchy dependen uno del otro, pero Omarchy ya no gestiona sus propios archivos — todo vive en este repo.

## Estructura

```
dotfiles/
├── .config/
│   ├── hypr/          # Configuración de Hyprland
│   └── omarchy/       # Temas de Omarchy (modificados)
├── .local/
│   ├── bin/           # Scripts del sistema (waybar, wallpaper, etc.)
│   └── share/
│       └── omarchy/   # Instalación de Omarchy (tomada del installer original)
└── install.sh
```

## Instalación normal (máquina nueva)

> Esto asume que ya hiciste el [setup inicial](#setup-inicial-una-sola-vez) en algún momento.
> Si es la primera vez que levantás este entorno, leé esa sección primero.

```bash
git clone <url-del-repo> ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

El script:
1. Instala las dependencias AUR que falten (requiere `paru`)
2. Crea los symlinks en `~/.config`, `~/.local/share` y `~/.local/bin`

---

## Setup inicial (una sola vez)

Este proceso solo hay que hacerlo la primera vez, cuando se parte de cero.
Es manual porque tiene pasos con estado que no se pueden automatizar sin riesgo.

### 1. Instalar Omarchy normalmente

Seguir el installer oficial de Omarchy. Esto crea `~/.local/share/omarchy/` con toda su estructura.

### 2. Reinstalar los paquetes de Omarchy desde AUR/CachyOS

Omarchy instala paquetes desde su propio repositorio de pacman. Hay que migrarlos a sus equivalentes en AUR o CachyOS para poder desacoplar el repo.

Identificar qué paquetes vienen del repo de Omarchy:
```bash
pacman -Sl omarchy 2>/dev/null || grep -r "omarchy" /etc/pacman.conf /etc/pacman.d/
```

Para cada paquete, encontrar el equivalente en AUR e instalar con `paru`/ ´yay´:
```bash
paru -S <paquete-equivalente>
```

### 3. Desregistrar el repo de Omarchy

Una vez migrados todos los paquetes, sacar el repo de `/etc/pacman.conf`:
```ini
# Eliminar o comentar estas líneas:
[omarchy]
Server = ...
```

Luego sincronizar:
```bash
sudo pacman -Sy
```

### 3.5. Limpiar lo que haya dejado el installer de Omarchy

El installer oficial de Omarchy puede instalar paquetes extra que no forman parte de este setup.
Como la versión de este repo está **congelada**, esas deps no se van a usar nunca — pero van a quedar instaladas y potencialmente actualizarse solas.

Después de desregistrar el repo de Omarchy, revisar qué quedó huérfano:

```bash
# Paquetes que ya no tienen ningún dependiente
pacman -Qdt
```

Comparar contra la lista de deps conocidas de este repo (sección [Dependencias](#dependencias)) y desinstalar lo que no corresponda:

```bash
sudo pacman -Rns <paquete>
```

> Esto hay que hacerlo con criterio — `pacman -Qdt` puede listar cosas tuyas no relacionadas con Omarchy. No borrar a ciegas.

### 4. Reemplazar la carpeta de Omarchy con el repo

```bash
# Respaldar por si algo sale mal <- en esta parte seguro explota todo, se va a desconfigurar entero
mv ~/.local/share/omarchy ~/.local/share/omarchy.bak

# Clonar el repo
git clone <url-del-repo> ~/dotfiles

# Correr el installer (crea todos los symlinks)
cd ~/dotfiles
chmod +x install.sh
./install.sh

# Una vez verificado que todo funciona, borrar el backup
rm -rf ~/.local/share/omarchy.bak
```

---

## Dependencias

### AUR (instaladas automáticamente por `install.sh`)

| Paquete | Uso |
|---|---|
| `elephant` + módulos | Launcher / datasource (Omarchy) |
| `xdg-terminal-exec` | Terminal por defecto del entorno |
| `yaru-icon-theme` | Iconos (Omarchy) |
| `linux-wallpaperengine-git` | Wallpaper Engine en Linux |
| `sunwait` | Cálculo de amanecer/atardecer para `hyprsunset_daynight.sh` |
| `hyprland-preview-share-picker-git` | Preview al compartir pantalla en Hyprland |

### CachyOS (instaladas automáticamente si el repo está configurado)

| Paquete | Uso |
|---|---|
| `walker` | Launcher de aplicaciones |

> Si no usás CachyOS, `walker` también está disponible en AUR.

### Manuales / hardware-específico

- **ROCm** (`rocm-smi`) — para `waybar-gpu.sh`. Solo funciona con GPU AMD.
- **Wallpaper Engine** — requiere comprarlo e instalarlo en Steam.

---

## Notas de hardware

Los scripts de Waybar leen sensores del sistema por paths hardcodeados.
**En hardware distinto estos paths probablemente sean diferentes.**

`waybar-cpu-watts.sh`:
```
/sys/class/hwmon/hwmon3/energy9_input   → energía CPU
/sys/class/hwmon/hwmon4/temp1_input     → temperatura CPU
```

`waybar-gpu.sh`:
```
/sys/class/hwmon/hwmon2/power1_average  → consumo GPU
```

Para encontrar los paths correctos en tu máquina:
```bash
ls /sys/class/hwmon/
# Para cada hwmon:
cat /sys/class/hwmon/hwmon*/name
```