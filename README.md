# dotfiles-hyprchy
> ⚠️ **Solo Arch Linux y derivados** (probado en CachyOS y Arch). 
> Los instaladores usan `pacman`/`paru`/AUR directamente — no van a andar en Ubuntu, Fedora, 
> Debian, etc. sin reescribir la capa de instalación de paquetes. Hyprland en sí no es exclusivo 
> de Arch, pero este repo específicamente asume ese ecosistema.

Dotfiles personales de Hyprland, basadas en [Omarchy](https://github.com/basecamp/omarchy) pero
desacopladas de su instalador — la idea es no traer el paquete completo de Omarchy (temas, apps,
config que no vas a usar), sino instalar Hyprland + UWSM limpio desde la distro, y encima de eso
aplicar solo lo visual/config de este repo.

> Este repo está en desarrollo activo. Cosas van a romperse. Actuar bajo discreción.

## Filosofía / orden de instalación

**No instales estas dotfiles antes de tener Hyprland instalado por el gestor de paquetes de tu
distro, y andá con cuidado si ya tenés otro shell/config armado encima de Hyprland (probado sobre
[Caelestia Shell](https://github.com/caelestia-dots/caelestia): rompe cosas).** Las combinaciones
probadas y que andan bien son: TTY limpia, TTY limpia + Hyprland pelado desde la distro, o Hyprland 
con pocas configs propias ya encima. Cuanto más armado esté el sistema con configs de otro shell/dotfiles
antes de instalar este repo, más probable que haya conflictos — si tenés algo así, lo más simple
es reinstalar Hyprland limpio antes de seguir.

Probado en dos máquinas distintas, funciona en ambas: notebook (Intel i5-8350U, gráfica integrada
Intel) y PC de escritorio (Ryzen 7 5700X + RX 9070 XT).

Orden correcto:

1. **Sistema base instalado**, estás en una TTY. (Paso 2 y 3 opcionales para asegurar o si no
   estás acostumbrado a la terminal, se puede saltar al 4 desde TTY.)

2. **Instalar Hyprland + UWSM + SDDM desde la distro**, mínimo, sin metapaquetes tipo
   `cachyos-hyprland-settings` (traen su propio waybar/tema/wallpapers, que no queremos):

```bash
   sudo pacman -S --needed hyprland uwsm xdg-desktop-portal-hyprland \
     qt5-wayland qt6-wayland polkit-gnome sddm kitty
   sudo systemctl enable sddm NetworkManager
   sudo reboot
```

   Con ese reboot alcanza — no hace falta loguear y verificar nada a mano antes de seguir, es
   directo al paso 3.

3. En SDDM, elegir la sesión **"Hyprland (uwsm-managed)"** (no "Hyprland" a secas). Esto sigue
   aplicando siempre que no hayas configurado autologin — si lo hiciste (`bootstrap-system` te lo
   pregunta), SDDM ya arranca directo con esa sesión sin pedirte elegir, así que el punto queda
   resuelto solo. Si elegís "Hyprland" a secas en algún momento (sin UWSM), cosas se rompen.

4. Recién ahí, clonar este repo y correr `./install-all`.

## Instalación

```bash
git clone https://github.com/CabraLoca69/dotfiles-hyprchy.git
cd ~/dotfiles-hyprchy
./install-all
```

`install-all` pregunta **una sola vez, al principio**, confirmación para arrancar, y ahí pide
la contraseña de `sudo` — la mantiene viva en background durante toda la instalación, así que no
te la vuelve a pedir a mitad de camino (ni aunque AUR tarde compilando más de los 15 min de
timeout default de sudo). De ahí en más corre todo de punta a punta sin preguntar nada más,
**salvo** en `bootstrap-system`, donde sí hay un par de confirmaciones puntuales por tratarse de
decisiones de seguridad (autologin de SDDM, habilitar `[multilib]`, integración de PAM con
gnome-keyring).

Podes leer la lista completa de dependecias y comentar (#) lo que consideres antes de instalar: [Deps](https://github.com/CabraLoca69/dotfiles-hyprchy/blob/main/dependencies)

Corre, en orden:

1. **`install-hyprchy`** — paru, dependencias (pacman/AUR/CachyOS), `PATH`, symlinks de configs,
   unidades de systemd, autostart de walker, elephant, tema default.
2. **`install-drivers`** — detecta CPU/GPU, instala microcode y drivers gráficos correspondientes
   (incluyendo detección automática de variante NVIDIA `-open-dkms` vs `-dkms` según el modelo).
3. **`bootstrap-system`** — multilib, servicios, grupos, keyring, display manager. Acá sí hay
   prompts, por diseño.

Todos los pasos son **idempotentes** — correr `./install-all` de nuevo no rompe nada, cada script
chequea antes de tocar algo.

### Flags útiles

```bash
./install-all --atomic-bin           # ver sección [Red de seguridad de PATH] mas abajo
./install-hyprchy --atomic-bin       # lo mismo, corriendo solo ese paso

./install-all nombredir              # usa dotfiles-hyprchy/nombredir en vez de merged/
./install-hyprchy nombredir          # idem, corriendo solo ese paso
```

Por default, `build-merged` arma el árbol combinado (`common/` + `hosts/<hostname>/`) en
`merged/`. Si le pasás un nombre como primer argumento posicional (a `install-all` o
`install-hyprchy` directo, `--atomic-bin` no cuenta como nombre), usa esa carpeta en cambio —
pensado para tener más de un árbol armado en paralelo sin pisarse (por ejemplo probar una config
nueva sin tocar la que ya anda). Si no pasás nada, sigue siendo `merged/` como siempre.

⚠️ Se bajan bastantes paquetes del AUR (repositorio de la comunidad, no oficial de Arch) durante
`install-hyprchy`, con `--noconfirm --skipreview` (no pide confirmación por paquete ni pausa a
revisar el `PKGBUILD`). Si te importa revisar cada uno antes de instalarlo, sacá esos flags del
`paru -S` en el script y hacelo a mano la primera vez, tambien podes revisar la lista de dependencias
aca : [Deps](https://github.com/CabraLoca69/dotfiles-hyprchy/blob/main/dependencies)

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

Es una medida puntual y extrema para cuando `uwsm-app` se pone testarudo y no toma
`~/.config/uwsm/env` de ninguna manera — no corre en el flujo normal de instalación (`main()` no
la llama salvo que pases la flag explícitamente), no es algo que uses día a día.

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

### Contenedores compartidos: por qué `.config`, `.local`, `.local/share` y `.cache` nunca se symlinkean enteros

La regla de arriba ("si no existe todavía en `$HOME`, symlinkealo entero") es peligrosa aplicada
sin criterio a un puñado de directorios muy particulares: `.config`, `.local`, `.local/share` y
`.cache` no son carpetas de una sola app — son **contenedores genéricos** que usan decenas de
programas ajenos al repo (fuentes, íconos, thumbnails, flatpak, mime, estado de otras apps, etc.).

Si alguno de ellos **todavía no existe** en `$HOME` al momento de instalar (instalación en una
cuenta nueva, o porque en algún momento lo borraste a mano mientras debugueabas algo), la regla
genérica no tiene forma de distinguir "esto es mío" de "esto lo comparto con todo el sistema" —
symlinkearía, por ejemplo, `~/.local/share` **entero** a `merged/.local/share` (que en el repo
solo trae `omarchy/`). A partir de ahí, cualquier app que después escriba en
`~/.local/share/lo-que-sea` termina escribiendo físicamente dentro de `merged/`, ensuciándolo con
archivos que no son dotfiles.

Por eso `install-hyprchy` trata estos cuatro paths como caso especial: **nunca** los symlinkea
enteros, pase lo que pase — siempre fuerza que existan como directorio real en `$HOME` y baja un
nivel más adentro, así solo terminan symlinkeadas las subcarpetas puntuales que sí son del repo
(`.local/share/omarchy`, por ejemplo), nunca el contenedor completo. Si en algún momento alguno de
estos cuatro paths quedó mal symlinkeado (de una corrida vieja, antes de este fix), `install-hyprchy`
lo detecta y se autorepara solo la próxima vez que corra — deshace el symlink de golpe y reconstruye
bien desde ahí.

`.local/bin` queda **afuera** de esta lista a propósito: a diferencia de `.local/share`, esa
carpeta es enteramente del repo (tus scripts propios, nada de apps de terceros escribiendo ahí),
así que sí tiene sentido que se symlinkee entera como una sola unidad — es justamente lo que
aprovecha `--atomic-bin` más arriba.

⚠️ Si `~/.local/share` (u otro de estos contenedores) quedó mal symlinkeado por una corrida vieja
y alguna app llegó a escribir cosas dentro de `merged/.local/share/` mientras tanto, `install-hyprchy`
**no mueve solo** ese contenido de vuelta a su lugar — solo deshace el symlink y crea el directorio
real vacío al lado. Revisá `merged/.local/share/` antes de reinstalar (o corré `./sync-to-repo` en
dry-run, te lo va a listar como "no reconocido") y movés a mano lo que corresponda.

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

### Unidades systemd `--user`: se habilitan solas si tienen `[Install]`

`symlink_systemd_units()` no solo symlinkea todo lo que haya en
`common/.local/share/omarchy/config/systemd/user/` — también recorre esos `.service`/`.timer` y
corre `systemctl --user enable` sobre cada uno. No hace falta tocar código para que una unidad
nueva arranque sola: alcanza con que el archivo tenga una sección `[Install]` (típicamente
`WantedBy=graphical-session.target` o similar).

Comportamiento según el caso:

- **Tiene `[Install]`** → se habilita automáticamente (`swayosd-server.service`,
  `omarchy-recover-internal-monitor.service`, el `.timer` de `omarchy-battery-monitor`, etc.).
- **No tiene `[Install]`** → `enable` tira *"has no installation config"* y el script lo loguea
  como informativo, no como error. Es el caso normal de un `.service` que dispara *otra* unidad
  (por ejemplo `omarchy-battery-monitor.service`, que lo activa su propio `.timer`, no
  `systemctl enable` directo) — no hace falta habilitarlo aparte.
- **Dropins (`app-walker@autostart.service.d/*.conf`)** — se symlinkean igual que cualquier otro
  archivo del directorio, pero no entran en el loop de habilitación (no son unidades en sí).

En la práctica: para agregar un daemon nuevo que arranque solo con la sesión, solo hace falta
poner el `.service` (con `[Install]`) en `common/.local/share/omarchy/config/systemd/user/` y
correr `./install-hyprchy` — se symlinkea y se habilita sin tocar el instalador.

### Editar la config después de instalado

Como lo que queda symlinkeado en `$HOME` apunta a `merged/` (no al repo directo), los cambios que
hagas ahí **no se reflejan solos en git**. Flujo de edición:

```bash
# editás lo que necesites, directo en ~/.config/... (símlinks a merged/) o en merged/ mismo
./sync-to-repo             # dry-run: te dice qué haría, no toca nada
./sync-to-repo --apply     # aplica los cambios detectados al repo
```

`sync-to-repo` no usa ningún archivo de estado/manifest — en cada corrida recalcula de nuevo, para
cada archivo de `merged/`, a qué le corresponde bajar con la misma regla que usa `build-merged`
para armar `merged/` (existe en `hosts/<hostname>/`? → ahí. si no, existe en `common/`? → ahí. si
no existe en ninguno de los dos → archivo nuevo). Por diseño corre en dos etapas: **reporte
primero, aplicación solo si pedís `--apply` explícitamente** — nunca escribe nada en la primera
pasada.

Lo que revisa en cada corrida:

- **Archivos editados** — contenido de `merged/` distinto al del repo → se listan (y con
  `--apply`, se copian) al destino que les corresponda (`common/` o `hosts/<hostname>/`).
- **Archivos borrados** — existen en el repo pero ya no en `merged/` (los borraste desde `$HOME`)
  → se listan, y con `--apply` se borran del repo (podando directorios que queden vacíos). Sin
  `--apply` no se toca nada, es solo aviso.
- **Archivos nuevos** — están en `merged/` pero no existen ni en `common/` ni en
  `hosts/<hostname>/` → se listan aparte, **nunca se copian solos a ningún lado** (ni con
  `--apply`). Hay que decidir a mano si van a `common/` (todas las máquinas) o a
  `hosts/<hostname>/` (solo esta), copiarlos ahí, y volver a correr.
- **Symlinks rotos en `$HOME`** — recorre `merged/` replicando la misma lógica de
  directorio-entero-vs-bajar-un-nivel que usa `install-hyprchy` (ver sección anterior), y avisa si
  algo dejó de ser symlink, falta directamente, o apunta a otro lado. Nunca repara nada solo —
  hay que correr `./install-hyprchy` de nuevo después de resolver a mano cuál versión vale.

Cada corrida queda guardada en `.sync-logs/` (gitignoreado, agregalo si no lo está), con nombre
`sync-to-repo_<fecha>_<hora>_<dry-run|apply>.log` — útil para revisar después qué hizo una corrida
con `--apply`, sobre todo si borró algo.

**Paths que `sync-to-repo` ignora por completo** (ni se comparan, ni se reportan como nuevos, ni
se chequean symlinks ahí): estado en runtime que ya está gitignoreado aparte, como
`.config/omarchy/current/` (ver sección de [temas](#temas-currenttheme-no-vive-en-git) más abajo). 
Están listados en el array `IGNORE_PATHS` al principio del script — para agregar uno nuevo, sumá la 
ruta relativa (a `merged/`) ahí, matchea la ruta exacta y todo lo que cuelgue debajo.

Corré `git status` después de `sync-to-repo --apply` como de costumbre, antes de comitear.

## Temas: `current/theme` no vive en git

`~/.config/omarchy/current/theme/` (y de ahí, `mako.ini`, los paths de `waybar/themes/`,
`walker/themes/`, etc.) es **estado runtime derivado**, no un dotfile — lo genera el theme
switcher (`theme-manager set <tema> ...`) a partir de los temas base reales. Intentar versionarlo
en git como symlink terminaba rompiéndose (git no trackea bien un `git add` que atraviesa un
symlink intermedio), así que directamente **no se versiona**, y por el mismo motivo
`sync-to-repo` lo tiene en su lista de paths ignorados (`IGNORE_PATHS`) — ni lo compara, ni lo
reporta como archivo nuevo, ni se mete a chequear symlinks ahí:

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

Si tenés el repo `[cachyos-v3]` habilitado en `pacman.conf`, trae `mesa-git` (y variantes `-git` de
`vulkan-*`), que **conflictúa** con los paquetes `mesa`/`vulkan-*` estándar que `install-drivers`
instala según la GPU detectada — pacman aborta con conflicto.

`install-drivers` ya maneja esto solo, sin preguntar: si detecta `[cachyos-v3]` habilitado y vas a
instalar drivers de GPU, lo deshabilita temporalmente (con backup de `pacman.conf`) durante esa
instalación puntual, y lo restaura automáticamente al terminar — pase lo que pase, incluso si el
script falla a mitad de camino (usa un `trap` sobre `EXIT`). No hace falta tocar nada a mano.

## Drivers NVIDIA: variante open/dkms automática

`install-drivers` ya no pregunta si tu GPU es Turing (RTX 20xx) o más nueva — lo detecta solo vía
`lspci` (busca `RTX`, `Quadro RTX/Txxxx`, `Tesla T4`, `Axxx0`, etc. en el nombre del dispositivo)
y elige `nvidia-open-dkms` o `nvidia-dkms` en consecuencia. Si el modelo no matchea ninguno de esos
patrones (GPU muy nueva que no está en la lista, o nombre no estándar), cae a `nvidia-dkms` por
default y te lo deja anotado en las notas post-instalación — si el driver `-open` te interesa igual,
reinstalá a mano: `sudo pacman -S nvidia-open-dkms`.

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

`paru` fuente compila contra el `libalpm` real del sistema en el momento de instalarlo, así que no
tiene ese problema.

Se compila con `makepkg -si --noconfirm` — no debería pedir input, salvo que algún `install()`
script del PKGBUILD pida confirmación propia (caso borde raro). Si un paquete AUR puntual cuelga
la instalación desatendida por esto, comentalo en `dependencies` y instalalo después a mano.

## Múltiples máquinas: `common/` + `hosts/<hostname>/`

Este repo se usa en más de una máquina (PC de escritorio, notebook), cada una con su propia
config de monitores, y un par de scripts que leen paths de hardware hardcodeados
(`waybar-cpu-watts`, `waybar-gpu` — hwmon es distinto por equipo). En vez de ramas de git
separadas por máquina, la config vive en una sola rama, separada en dos árboles:

```text
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
```

`install-hyprchy` corre `build-merged` primero (detecta el hostname con `hostnamectl --static`,
combina `common/` + `hosts/<hostname>/` en `merged/`), y symlinkea desde ahí — ver la sección
anterior para el detalle de cómo se decide directorio-entero-symlinkeado vs. bajar un nivel.

Si una máquina nueva no tiene carpeta en `hosts/`, el instalador avisa pero no falla — usa
`common/` solo. Para agregar overrides de una máquina nueva, lo más simple es editar directo
sobre `~/.config/...` (que apunta a `merged/`) y correr `./sync-to-repo` — te va a listar el
archivo como nuevo para que decidas dónde va.

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
merged(o nombredir)/                         # GENERADO, puede estar gitignoreado — 
                                             # no editar el repo acá directo pensando que persiste solo con git
`````

## Dual-boot con ESP compartida (Limine)

No hay instalador para esto — es 100% manual, y solo aplica si instalaste Arch junto a otra
distro que también usa Limine, compartiendo la misma partición EFI (ESP). Pasos generales:

1. **No crear una segunda ESP.** Un solo `/boot` (la partición `vfat`/FAT32 existente) montado
   para ambos sistemas — Limine necesita una sola ESP para listar todas las entradas.
2. **Instalar el kernel y el paquete `limine` de Arch normalmente** (`pacstrap` con `linux`,
   `linux-firmware`; `pacman -S limine` dentro del chroot). No hace falta reinstalar el binario
   EFI de Limine si la otra distro ya lo tiene — es el mismo bootloader, solo hay que agregarle
   una entrada de arranque nueva a su configuración existente.
3. **Ubicar el `limine.conf` real** (`find /boot -iname "limine.conf" -o -iname "limine.cfg"`).
   Si la otra distro usa `limine-entry-tool`/`limine-snapper-sync` (típico en CachyOS), vas a ver
   bloques autogenerados con `comment: kernel-id=...` y snapshots — **no tocar nada de eso**.
4. **Agregar un bloque manual para Arch**, antes de la sección `/+Other systems and bootloaders`
   (o donde prefieras, el orden solo afecta el menú): 

```bash
/+Arch Linux
//Arch Linux
protocol: linux
path: boot():/vmlinuz-linux
module_path: boot():/initramfs-linux.img
cmdline: root=UUID=TU-UUID-AQUI rw
``` 

   El UUID es el de la partición **root de Arch**, no la ESP: `blkid -s UUID -o value /dev/tu_particion_root`.

   ⚠️ **Revisá el bloque con `grep -A5 "Arch Linux" /boot/limine.conf` después de editar.**
   Un typo acá (UUID sin el prefijo `UUID=`, o cualquier letra de más/de menos) manda directo a
   `emergency mode` en el próximo boot (`Failed to mount /sysroot`). Si eso pasa: bootear a la
   otra distro, entrar por SSH o TTY, y comparar `blkid` contra lo que quedó en `limine.conf`
   caracter por caracter.

**`pacman` tira "error: no se pudo realizar la operación (archivos en conflicto)" al instalar
`intel-ucode`/`amd-ucode`** (o potencialmente otro paquete que deje archivos sueltos en la ESP)
— pasa porque la ESP es compartida y la otra distro ya tiene ese archivo instalado desde su
propia base de datos de pacman; la tuya no lo sabe. Es seguro pisarlo, es el mismo binario
upstream:

```bash
sudo pacman -S intel-ucode --overwrite '/boot/intel-ucode.img'
```

(cambiá el nombre del archivo según cuál sea el conflicto puntual)

## Plymouth (splash de arranque/apagado)

No viene instalado ni activado por defecto en una instalación base de Arch. Pasos:

1. **Instalar y elegir tema:**
```bash
   sudo pacman -S plymouth                  # install-hyprchy deberia instalarlo por defecto 
   plymouth-set-default-theme --list        # ver temas disponibles
   sudo plymouth-set-default-theme -R bgrt  # -R regenera el initramfs al final
```

2. **Agregar el hook `plymouth` a `/etc/mkinitcpio.conf`.** El nombre es **`plymouth`
   siempre**, tanto en HOOKS estilo `udev` como estilo `systemd` — `sd-plymouth` no existe como
   paquete/hook en Arch, si lo ves mencionado en algún lado es de otra distro. Lo único que
   cambia entre familias es la posición:
   - Estilo `udev`: después de `base udev`, antes de `autodetect`.
   - Estilo `systemd` (`HOOKS=(base systemd ...)`, común en CachyOS/derivados): después de
     `sd-vconsole`.

```bash
   sudo mkinitcpio -P
```

3. **Agregar `quiet splash` al `cmdline`** de tu entrada en `limine.conf` (o el bootloader que
   uses) — sin esto, el kernel sigue mostrando el log de texto normal aunque Plymouth esté bien
   instalado.

**`mkinitcpio -P` tira "ERROR: Hook 'plymouth' cannot be found" (o `sd-plymouth`)** — o falta
el paquete `plymouth`, o está mal escrito el nombre del hook, o está en la posición equivocada
según la familia de HOOKS (ver punto 2 arriba). Confirmá con `pacman -Ql plymouth | grep hook`
qué nombre de hook provee realmente el paquete instalado.

**No aparece el splash aunque no haya errores en `mkinitcpio -P`** — chequeá en este orden:
1. `grep -A5 "Arch Linux" /boot/limine.conf` — ¿tiene `quiet splash` bien escrito (sin typos
   tipo `slpash`)?
2. `plymouth-set-default-theme` (sin argumentos) — ¿devuelve un tema, o vacío/error?
3. `lsinitcpio /boot/initramfs-linux.img | grep plymouth` — ¿aparece contenido, o nada?

### Previsualizar temas de Plymouth sin reiniciar

Si bajaste temas de terceros (AUR o manuales en `/usr/share/plymouth/themes/`) y no tenés forma
de ver cómo quedan antes de aplicarlos: **no se puede previsualizar corriendo Wayland/X11
encima** (Plymouth necesita el framebuffer/DRM libre). Cambiar a una TTY sin compositor gráfico
corriendo (`Ctrl+Alt+F3`, por ejemplo), loguearse ahí, y correr el tema en modo debug — volver
con `Ctrl+Alt+F1`/`F2` al terminar. Script de ejemplo: [pegar acá tu `plymouth-picker.sh`].

## Troubleshooting rápido

**`uwsm-app -- algo` tira "command not found"** — `~/.config/uwsm/env` no está seteado o no
hiciste logout/login completo después de tocarlo.  Leer:
[Red de seguridad de PATH](#red-de-seguridad-de-path---atomic-bin). Mientras tanto:
`./install-hyprchy --atomic-bin`.

**pacman tira conflicto con `mesa-git` al instalar drivers** — `[cachyos]` habilitado.
`install-drivers` te lo va a preguntar solo; si preferís hacerlo a mano, comentá el bloque
`[cachyos]` en `/etc/pacman.conf`, corré `install-drivers`, y descomentalo después.

**`paru: error while loading shared libraries: libalpm.so.N`** — te quedó un `paru-bin` viejo de
antes de este fix. `sudo pacman -R paru-bin` y volvé a correr `install-hyprchy` (instala `paru`
fuente).

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
symlink que apunta ahí), que está gitignoreado a propósito. Corré `./sync-to-repo` (dry-run) para
ver qué detecta, y `./sync-to-repo --apply` para bajarlo a `common/` o `hosts/<hostname>/` según
corresponda.

**Vengo de Caelestia Shell (u otro shell/dotfiles ya armado sobre Hyprland) y algo no anda** —
no está soportado instalar este repo encima de otro shell/config ya armado; en la práctica rompe
cosas (probado con Caelestia Shell puntualmente). Lo más simple es reinstalar Hyprland limpio
desde la distro (ver "Filosofía / orden de instalación" arriba) y recién ahí correr
`./install-all`.

**`~/.local/share` (u otro contenedor: `.config`, `.local`, `.cache`) aparece symlinkeado entero
en vez de solo mis subcarpetas** — corriste una versión vieja de `install-hyprchy` de antes del
fix de contenedores compartidos (ver sección [Cómo se arman los symlinks](#cómo-se-arman-los-symlinks-merged) 
más arriba). Actualizá el script y volvé a correr `./install-hyprchy`: se detecta y se autorepara solo. 
Si mientras tanto alguna app escribió cosas ahí adentro, van a quedar sueltas en `merged/.local/share/` 
(o el contenedor que corresponda) — revisalo con `./sync-to-repo` (dry-run, te lo va a listar como "no
reconocido") y movelo a mano de vuelta a su lugar antes de reinstalar.

**activar/desactivar autologin** - System-bootstrap te pregunta si queres activar el autologin
durante la instalacion, si pusiste que no y queres activarlo: 

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

**mako no arranca / `Unable to parse configuration file`** — `~/.config/mako/config` quedó
apuntando a un `current/theme/mako.ini` que no existe. Definí `DEFAULT_THEME` en
`install-hyprchy` y corré `theme-manager set <nombre tema> -w -k --hyprlock` a mano, o
volvé a correr `./install-hyprchy` si ya lo definiste.

**Walker no aplica tema / queda transparente** — revisá que `~/.config/omarchy/current/theme`
resuelva a un tema real (`readlink -f ~/.config/omarchy/current/theme`), no a un symlink roto.
Ademas config.toml debe existir, o al menos estar symlinkeado en el directorio .config/walker,
aunque el instalador deberia cubrir ese caso especifico.

**`omarchy-restart-walker` falla con "Unable to restart Walker"** — falta
`~/.config/autostart/walker.desktop`. Correr `./install-hyprchy` de nuevo (es idempotente, lo
symlinkea si el repo lo tiene).


## Créditos

Este repo no parte de cero — toma prestado y adapta trabajo de varios proyectos de la comunidad:

- **[Omarchy](https://github.com/basecamp/omarchy)** (Basecamp/DHH) — base conceptual y buena
  parte de la estructura de config de Hyprland/waybar/walker/temas de la que parte este repo,
  aunque desacoplada de su instalador (ver introducción arriba).

- **[linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine)** (Almamu) — usado
  opcionalmente para correr wallpapers de Wallpaper Engine (Steam) en Linux.
  No se distribuye en este repo; se instala como dependencia AUR

- **Theme-manager-plus** - [OldJobobo](https://github.com/OldJobobo/theme-manager-plus) - viene 
instalado por practicidad, ya esta integrado a los menus y keybinds (leer su documentacion).

- **Waybars y temas** — [OldJobobo](https://github.com/OldJobobo) y
  [HANCORE](https://github.com/HANCORE-linux) 
  
- **Temas de walker** - [rahulkumarparida](https://github.com/rahulkumarparida/Walker-themes)

- **Wallpaper-picker** - [yo mismo](https://github.com/CabraLoca69/Linux-WE-SimpleUi)