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
git clone https://github.com/CabraLoca69/dotfiles-hyprchy.git
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

## Cómo se arman los symlinks: `merged/`

`common/` + `hosts/<hostname>/` **no se symlinkean directo a `$HOME`**. Antes de eso,
`build-merged` los combina en una carpeta generada, `merged/` (gitignoreada, no vive en el
repo):

1. `rsync -a --delete common/ merged/` — espejo completo de lo compartido.
2. `rsync -a hosts/<hostname>/ merged/` **encima**, sin `--delete` — solo agrega/pisa lo puntual
   de esta máquina, nunca borra lo de `common/`.

Recién con `merged/` ya resuelto, `install-hyprchy` symlinkea hacia `$HOME`, **recursivo y
directorio por directorio**: si `~/.config/hypr` no existe todavía (o ya era un symlink nuestro
de antes), lo symlinkea entero de una — un solo link, `ls` limpio. Si en cambio ya hay contenido
real ahí (por ejemplo `~/.config` casi seguro tiene carpetas de otras apps que no son del repo),
baja un nivel más y repite el chequeo adentro. Resultado: todo lo que no tiene mezcla con cosas
ajenas al repo queda como un solo symlink de carpeta; solo se "abre" recursivamente donde hace
falta.

Tres cosas puntuales, además, necesitan un symlink extra propio porque el programa que los
consume busca en un lugar fijo del sistema, no dentro del árbol de `merged/`:

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
subcomando (`elephant service enable`) que genera y habilita su unidad.

### Editar la config después de instalado

Como lo que queda symlinkeado en `$HOME` apunta a `merged/` (no al repo directo), los cambios que
hagas ahí **no se reflejan solos en git**. Flujo de edición:

```bash
# editás lo que necesites, directo en ~/.config/... (símlinks a merged/) o en merged/ mismo
./sync-to-repo
```

`sync-to-repo` recorre `merged/` y decide dónde va cada archivo:

- Si ya existía como override de este host → se actualiza en `hosts/<hostname>/`.
- Si ya existía como compartido → se actualiza en `common/`.
- Si es un archivo **nuevo** (no existía en ninguno de los dos) → **te pregunta** si va a
  `common/` (compartido con todas las máquinas) o a `hosts/<hostname>/` (solo esta), sin asumir
  default.

Al final, reporta como **huérfanos** los archivos que están en el repo pero ya no en `merged/`
(los borraste) — nunca los borra solo del repo, es un aviso para que decidas vos si el borrado
fue intencional y quieras `git rm` a mano.

Corré `git status` después de `sync-to-repo` como de costumbre, antes de comitear.

## Temas: `current/theme` no vive en git

`~/.config/omarchy/current/theme/` (y de ahí, `mako.ini`, los paths de `waybar/themes/`,
`walker/themes/`, etc.) es **estado runtime derivado**, no un dotfile — lo genera el theme
switcher (`theme-manager set <tema> ...`) a partir de los temas base reales. Intentar versionarlo
en git como symlink terminaba rompiéndose (git no trackea bien un `git add` que atraviesa un
symlink intermedio), así que directamente **no se versiona**:

- El symlink fijo `~/.config/mako/config → ~/.config/omarchy/current/theme/mako.ini` lo recrea
  siempre `repair_internal_symlinks()` en cada corrida de `install-hyprchy` — no depende de git
  para nada, es una relación fija sin importar qué tema esté activo.
- El *contenido* de `current/theme/` (y de rebote ese `mako.ini`) lo genera
  `set_default_theme()`, que corre `theme-manager set "$DEFAULT_THEME" -w -k --hyprlock -q` una
  vez al final de la instalación. `DEFAULT_THEME` está en `install-hyprchy` como variable a
  definir — ⚠️ **si queda vacía, el instalador avisa y salteá este paso**, dejando el symlink de
  mako roto hasta que corras el `set` a mano.
- Los **temas base reales** (los `.toml`/carpetas que sí se editan a mano y sí van al repo) viven
  en `common/.local/share/omarchy/themes/<nombre>/` como siempre.

`verify_theme_symlinks()` corre al final del instalador y avisa si `~/.config/mako/config` quedó
roto, para no descubrirlo recién cuando falla una notificación.


## Terminal default para `xdg-terminal-exec`

Varios binds/scripts (incluido `omarchy-launch-floating-terminal`) usan `xdg-terminal-exec` para
abrir "el terminal default del usuario" sin hardcodear cuál es. Necesita
`~/.config/xdg-terminals.list`, un archivo de texto plano con un `.desktop` por línea, en orden de
preferencia — usa el primero que encuentre instalado:

```
Alacritty.desktop
kitty.desktop
```

`install-hyprchy` lo crea solo (`setup_xdg_terminal()`) si no existe todavía — no lo pisa si ya lo
tenías configurado a mano. Si usás otro terminal, editá `~/.config/xdg-terminals.list` directo.

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

## Múltiples máquinas: `common/` + `hosts/<hostname>/`

Este repo se usa en más de una máquina (PC de escritorio, notebook), cada una con su propia
config de monitores, y un par de scripts que leen paths de hardware hardcodeados
(`waybar-cpu-watts`, `waybar-gpu` — hwmon es distinto por equipo). En vez de ramas de git
separadas por máquina, la config vive en una sola rama, separada en dos árboles:
common/                    # compartido entre TODAS las máquinas
├── .config/hypr/hyprland.lua, helpers.lua, bindings.lua, ...
└── .local/bin/, .local/share/omarchy/, ...
hosts/
├── not-cloca/              # overrides SOLO para esta máquina (notebook)
│   └── .config/hypr/monitors.lua
└── pc-cloca/                # overrides SOLO para esta máquina (PC)
├── .config/hypr/monitors.lua
├── .local/bin/waybar-cpu-watts
└── .local/bin/waybar-gpu

`install-hyprchy` corre `build-merged` primero (detecta el hostname con `hostnamectl --static`,
combina `common/` + `hosts/<hostname>/` en `merged/`), y symlinkea desde ahí — ver la sección
anterior para el detalle de cómo se decide directorio-entero-symlinkeado vs. bajar un nivel.

Si una máquina nueva no tiene carpeta en `hosts/`, el instalador avisa pero no falla — usa
`common/` solo. Para agregar overrides de una máquina nueva, lo más simple es editar directo
sobre `~/.config/...` (que apunta a `merged/`) y correr `./sync-to-repo` — te va a preguntar
dónde va cada archivo nuevo.

⚠️ Este esquema permite *agregar/reemplazar* archivos por host, pero no *excluir* uno que exista
en `common/` (no hay forma de decir "en esta máquina, este archivo de común no va"). Si hace
falta eso, hay que agregarle al script una lista de exclusión — no implementado todavía.

## Estructura del repo

```
install-all                 # orquesta los 3 pasos de instalación
install-hyprchy               # paru, deps, PATH, build-merged + symlinks, systemd units, walker/elephant, tema default
install-drivers                # CPU/GPU (microcode, mesa/vulkan/nvidia, bootloader)
bootstrap-system                 # multilib, servicios, grupos, keyring, display manager
build-merged                    # combina common/ + hosts/<hostname>/ -> merged/ (gitignoreado)
sync-to-repo                     # baja cambios editados en merged/ de vuelta al repo (common/ o hosts/)
dependencies                           # PACMAN_DEPS / AUR_DEPS / CACHYOS_DEPS
common/                                  # dotfiles compartidos
hosts/<hostname>/                          # overrides puntuales por máquina
merged/                                      # GENERADO, gitignoreado — no editar el repo acá directo pensando que persiste solo con git
`````


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

**`impala`/NetworkManager conectan la wifi pero nunca hay IP (`ip addr` solo muestra `link/ether`,
sin `inet`)** — chequeá si NetworkManager tiene la interfaz como `unmanaged`:
```bash
nmcli device show wlan0 | grep -i managed
```
Si sale `unmanaged`, NetworkManager nunca va a pedir IP por DHCP para esa interfaz, aunque `iwd`
ya la haya asociado a la red (por eso `iwctl station wlan0 show` dice "conectado" pero no hay
DHCP configurado). Fix:
```bash
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/wifi-managed.conf << 'EOF'
[device]
wifi.backend=iwd
managed=true
EOF
sudo systemctl restart NetworkManager
```
Reconectá después con `impala` o `nmcli device wifi connect "TU_RED"` y confirmá con
`ip addr show wlan0` que ahora aparece una línea `inet 192.168.x.x/...`.

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

**Cambié algo en `~/.config/...` y no aparece en `git status`** — estás editando `merged/` (o un
symlink que apunta ahí), que está gitignoreado a propósito. Corré `./sync-to-repo` para bajar
el cambio a `common/` o `hosts/<hostname>/` según corresponda.

**mako no arranca / `Unable to parse configuration file`** — `~/.config/mako/config` quedó
apuntando a un `current/theme/mako.ini` que no existe. Definí `DEFAULT_THEME` en
`install-hyprchy` y corré `theme-manager set "$DEFAULT_THEME" -w -k --hyprlock` a mano, o
volvé a correr `./install-hyprchy` si ya lo definiste.


**activar/desactivar autologin**

Para activar autologin (se hace automatico en system-bootstrap): 

```bash
sudo mkdir -p /etc/sddm.conf.d && sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null <<EOF
[Autologin]
User=$USER
Session=hyprland-uwsm.desktop
EOF
```

Posteriormente se puede configurar el hyprlock para que bloquee la pantalla, ambos tienen temas 
asi que es cuestion de elegir nomas.

Para desactivarlo se puede eliminar el archivo o borrar su contenido, cada vez que enciendas vas 
a ver el login de tu display manager