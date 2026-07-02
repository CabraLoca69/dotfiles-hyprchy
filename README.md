# dotfiles-hyprchy

Dotfiles personales de Hyprland, basadas en [Omarchy](https://github.com/basecamp/omarchy) pero
desacopladas de su instalador — la idea es no traer el paquete completo de Omarchy (temas, apps,
config que no vas a usar), sino instalar Hyprland + UWSM limpio desde la distro, y encima de eso
aplicar solo lo visual/config de este repo.

> Este repo está en desarrollo activo. Cosas van a romperse. Actuar bajo discreción.

## Filosofía / orden de instalación

**No instales estas dotfiles antes de tener Hyprland instalado por el gestor de paquetes de tu
distro.** Se probó al revés (dotfiles primero, Hyprland después) y deja el sistema en un estado
inconsistente — la entrada `hyprland-uwsm.desktop` en SDDM la genera el paquete de Hyprland/UWSM,
no este repo, y varios paths asumen que ya existen cuando se instalan.

Orden correcto:

1. **Sistema base instalado**, estás en una TTY.
2. **Instalar Hyprland + UWSM + SDDM desde la distro**, mínimo, sin metapaquetes tipo
   `cachyos-hyprland-settings` (traen su propio waybar/tema/wallpapers, que no queremos):
   ```bash
   sudo pacman -S --needed hyprland uwsm xdg-desktop-portal-hyprland \
     qt5-wayland qt6-wayland polkit-gnome sddm kitty
   sudo systemctl enable sddm NetworkManager
   sudo reboot
   ```
3. En SDDM, elegir la sesión **"Hyprland (uwsm-managed)"** (no "Hyprland" a secas).
4. Confirmar que UWSM sincroniza bien el entorno de por sí, antes de tocar nada:
   ```bash
   systemctl --user show-environment | grep -E "WAYLAND_DISPLAY|DBUS_SESSION"
   uwsm-app -- kitty   # debería abrir una ventana nueva sin exportar nada a mano
   ```
5. Recién ahí, clonar este repo y correr `./install-all`.

## Instalación

```bash
git clone <este-repo> ~/dotfiles-hyprchy
cd ~/dotfiles-hyprchy
./install-all
```

Corre, en orden:

1. **`install-hyprchy`** — paru, dependencias (pacman/AUR/CachyOS), `PATH`, symlinks de configs,
   unidades de systemd, autostart de walker, elephant.
2. **`install-drivers`** — detecta CPU/GPU, instala microcode y drivers gráficos correspondientes.
3. **`bootstrap-system`** — multilib, servicios, grupos, keyring, display manager.

Todos los pasos son **idempotentes** — correr `./install-all` de nuevo no rompe nada, cada script
chequea antes de tocar algo.

### Flags útiles

```bash
./install-all --atomic-bin       # ver sección "Red de seguridad de PATH" más abajo
./install-hyprchy --atomic-bin   # lo mismo, corriendo solo ese paso
```

⚠️ Se bajan bastantes paquetes del AUR (repositorio de la comunidad, no oficial de Arch) durante
`install-hyprchy`. Si te importa revisar cada uno antes de instalarlo, sacá `--skipreview` del
`paru -S` en el script y hacelo a mano la primera vez.

## Por qué tantas cosas necesitan un fix manual — UWSM y el entorno de la sesión

Buena parte de los problemas que este repo resuelve vienen de una fuente común: **UWSM lanza
aplicaciones como unidades de `systemd --user`, no como hijos directos de tu shell**. Eso significa
que heredan el entorno que `systemd --user`/D-Bus tengan sincronizado en ese momento — no el de tu
`.bashrc`, no el de la terminal que tengas abierta.

Esto rompe cosas de formas no obvias:

- **`PATH` custom no llega a `uwsm-app`.** `~/.config/environment.d/*.conf` es el mecanismo
  "oficial" de systemd para esto, pero tiene un bug/limitación conocida
  ([systemd/systemd#12259](https://github.com/systemd/systemd/issues/12259)): **`PATH`
  específicamente se ignora ahí**, aunque cualquier otra variable funcione bien. La solución real
  es `~/.config/uwsm/env` (que UWSM lee con su propio mecanismo, no el generador de systemd) — es
  lo que hace `setup_uwsm_env()` en `install-hyprchy`.
- **`~/.config/systemd/user.conf.d/` tampoco sirve** para esto — ni siquiera se lee (confirmado
  en el mailing list de systemd-devel, es una limitación documentada, no un bug tuyo).
- **`o.launch_on_start(...)` / `hl.on("hyprland.start", ...)` en `hyprland.lua`** no son la causa
  de estos problemas — son solo wrappers de Lua que arman un string y llaman a `hl.exec_cmd(...)`,
  cero interacción con systemd/D-Bus por sí mismos. Si algo lanzado desde ahí falla, el problema
  está en el entorno que ve `uwsm-app` en ese momento, no en el wrapper.

### Red de seguridad de PATH: `--atomic-bin`

Si después de configurar `~/.config/uwsm/env` seguís teniendo `command not found` para binarios
propios lanzados por `uwsm-app`, `/usr/local/bin` **siempre** está en el `PATH` — no depende de
ningún mecanismo de sincronización, systemd lo trae por default para cualquier proceso, sea como
sea que se haya lanzado. `--atomic-bin` symlinkea `~/.local/bin/*` y
`~/.local/share/omarchy/bin/*` ahí:

```bash
./install-hyprchy --atomic-bin
```

Es una foto fija — si agregás un script nuevo después, hay que volver a correrlo (o symlinkealo
a mano). No reemplaza a `~/.config/uwsm/env`, es el parche de "necesito que ande ya".

## Symlinks: qué se symlinkea y por qué algunos necesitan un paso extra

`create_symlinks()` en `install-hyprchy` symlinkea en bloque todo `.config/*/`, `.local/share/*/`
y `.local/bin/*` del repo hacia `$HOME`. Eso cubre la gran mayoría, pero **tres cosas viven dentro
de esos árboles y necesitan un symlink adicional propio**, porque el programa que los consume
busca en un lugar fijo del sistema, no dentro de tu `$HOME/.local/share/omarchy/`:

| Qué | Vive en (repo) | Necesita estar en | Función que lo hace |
|---|---|---|---|
| Unidades systemd (`swayosd-server.service`, etc.) | `.local/share/omarchy/config/systemd/user/` | `~/.config/systemd/user/` | `symlink_systemd_units()` |
| `walker.desktop` | `.local/share/omarchy/default/walker/` | `~/.config/autostart/` | `symlink_autostart_entries()` |
| elephant (backend de walker) | — (no es un archivo) | habilitado vía `elephant service enable` | `enable_elephant()` |

`walker.desktop` en `~/.config/autostart/` es necesario porque el generador de systemd
`xdg-desktop-autostart-generator` arma la unidad transitoria `app-walker@autostart.service` a
partir de ahí — sin el `.desktop` en ese path exacto, la unidad nunca existe y
`omarchy-restart-walker` falla con *"Unable to restart Walker -- RESTART MANUALLY"*.

`elephant` no se symlinkea porque no viene con un `.service` fijo en el repo — trae su propio
subcomando (`elephant service enable`) que genera y habilita su unidad. Es el único caso de los
tres que es un comando, no un symlink.

## Temas y git

Omarchy aplica temas creando `~/.config/omarchy/current/theme` como **symlink** apuntando al tema
activo (`~/.config/omarchy/themes/<nombre>/`). Un repo de git que solo trae la estructura de
selector de temas pero **ningún tema real adentro** deja ese symlink apuntando a nada en una
instalación limpia — hasta que alguien elige un tema activamente, cosas que dependen de
`current/theme` (walker, entre otras) quedan rotas o transparentes.

**Este repo incluye al menos un tema completo** para evitar ese estado roto en el primer arranque.
Si agregás temas nuevos, asegurate de que el que quede como default en `current/theme` sea uno
real, versionado en el repo — no solo el symlink apuntando a un directorio vacío.

## Drivers de GPU: conflicto con `[cachyos]`

Si tenés el repo `[cachyos]` habilitado en `pacman.conf`, trae `mesa-git` (y variantes `-git` de
`vulkan-*`), que **conflictúa** con los paquetes `mesa`/`vulkan-*` estándar que `install-drivers`
instala según la GPU detectada — pacman aborta con conflicto.

`install-drivers` ya maneja esto solo: si detecta `[cachyos]` habilitado y vas a instalar drivers
de GPU, te pregunta si querés deshabilitarlo temporalmente (con backup de `pacman.conf`) durante
esa instalación puntual, y lo restaura automáticamente al terminar — pase lo que pase, incluso si
el script falla a mitad de camino (usa un `trap` sobre `EXIT`). No hace falta comentarlo a mano
vos mismo.

## paru: fuente, no `-bin`

`install-hyprchy` instala `paru` así:

- Si `[cachyos]` está habilitado → `paru` como paquete normal de ese repo (ya viene sano).
- Si no → se compila **`paru` (fuente)**, nunca `paru-bin` (precompilado).

`paru-bin` viene linkeado contra el `libalpm.so.<N>` que tenía el sistema del mantenedor en el
momento de compilarlo. En distros con `pacman` de build git/dev (como CachyOS,
`7.1.0.r9.g54d9411-4` estilo) el soname de `libalpm` cambia seguido, y `paru-bin` termina roto con
`error while loading shared libraries: libalpm.so.N: cannot open shared object file` — sin arreglo
posible salvo esperar una build nueva en el AUR. `paru` fuente compila contra el `libalpm` real del
sistema en el momento de instalarlo, así que no tiene ese problema.

## Estructura del repo

```
install-all              # orquesta los 3 pasos de instalación
install-hyprchy           # paru, deps, PATH, symlinks, systemd units, walker/elephant
install-drivers           # CPU/GPU (microcode, mesa/vulkan/nvidia, bootloader)
bootstrap-system           # multilib, servicios, grupos, keyring, display manager
dependencies                # PACMAN_DEPS / AUR_DEPS / CACHYOS_DEPS
.config/                     # symlinkeado en bloque a ~/.config/
.local/bin/                   # symlinkeado en bloque a ~/.local/bin/
.local/share/omarchy/           # symlinkeado en bloque a ~/.local/share/omarchy/
```

## Troubleshooting rápido

**`uwsm-app -- algo` tira "command not found"** — `~/.config/uwsm/env` no está seteado o no
hiciste logout/login completo después de tocarlo. Mientras tanto: `./install-hyprchy --atomic-bin`.

**Walker no aplica tema / queda transparente** — revisá que `~/.config/omarchy/current/theme`
resuelva a un tema real (`readlink -f ~/.config/omarchy/current/theme`), no a un symlink roto.

**`omarchy-restart-walker` falla con "Unable to restart Walker"** — falta
`~/.config/autostart/walker.desktop`. Correr `./install-hyprchy` de nuevo (es idempotente, lo
symlinkea si el repo lo tiene).

**pacman tira conflicto con `mesa-git` al instalar drivers** — `[cachyos]` habilitado.
`install-drivers` te lo va a preguntar solo; si preferís hacerlo a mano, comentá el bloque
`[cachyos]` en `/etc/pacman.conf`, corré `install-drivers`, y descomentalo después.

**`paru: error while loading shared libraries: libalpm.so.N`** — te quedó un `paru-bin` viejo de
antes de este fix. `sudo pacman -R paru-bin` y volvé a correr `install-hyprchy` (instala `paru`
fuente).

**`impala` no muestra tu wifi como "conocida" / `Operation failed` al conectar, aunque estés
conectado** — pasa cuando la conexión inicial se hizo con `iwctl` directo desde la TTY del
instalador de Arch (flujo típico, antes de que exista tu usuario/sesión), y `iwd` se quedó con
el perfil sin que NetworkManager lo termine de adoptar bien. `impala` habla con NetworkManager,
no con iwd — por eso no lo ve como conocida aunque el link físico esté activo. Fix:
```bash
nmcli connection delete "NOMBRE_DE_TU_RED"
nmcli device wifi connect "NOMBRE_DE_TU_RED"
```
No se automatizó en el instalador a propósito — borrar conexiones de NetworkManager a ciegas
podría romper perfiles wifi que ya andaban bien en una instalación existente. Con Ethernet no
debería pasar, no hay handshake de iwd/NetworkManager de por medio.