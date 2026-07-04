# DESIGN — Killer Klownz from Outer Space

> *"Cotton Candy Cosmos"*

Deep space everywhere — then the alien launcher drops in from another dimension, pastel pink and completely wrong. The volume slider glows like a spaceship instrument. Notifications are from a different planet (literally: cream white in a dark world). Something fun is about to murder you.

The design runs on three surface temperatures that never normalize against each other:

- **Cold/void** — space black (`#0b0a10`). Terminals, chat, the baseline. Where horror lives.
- **Alien/warm** — cotton candy pink (`#f5c2e7`) and cream (`#fffaf0`). Walker, Mako, Discord sidebar. Intrusions from elsewhere.
- **Slime/instrument** — dark alien green (`#001a0d`). SwayOSD, Discord server list. Not cold, not warm — wrong in a third way.

Active window borders don't pick a temperature — they cycle through all the accent colors simultaneously and spin.

---

## Palette

| Role | Hex | Used in |
|------|-----|---------|
| Space black | `#0b0a10` | Windows, terminal bg |
| Alien cyan | `#3cfaff` | Primary foreground |
| Electric cobalt | `#4b6cff` | Accent, selection |
| Hot pink | `#ff3c8e` | Errors, clown lipstick |
| Cosmic magenta | `#ff4fd8` | Active borders |
| Alien purple | `#b96bff` | Secondary accent, Walker highlights |
| Slime green | `#2dff6a` | SwayOSD fg |
| Spotlight yellow | `#ffe347` | Warnings, highlights |
| Cotton candy pink | `#f5c2e7` | Walker bg, Hyprlock idle ring, Discord sidebar |
| Void purple text | `#1a0020` | Walker text, Mako text, Discord sidebar text |
| Deep circus purple | `#6c1a8a` | Walker selected state |
| Alien green void | `#001a0d` | SwayOSD bg, Discord server list + user panel |
| Cream | `#fffaf0` | Mako bg, swaync notification bg |
| Near-white lavender | `#e6e3ff` | ANSI white (color7), terminal body text |
| Muted border | `#7a74a0` | Inactive channels, disabled text |

---

## Component Design

### Terminal / Windows
Standard dark. No warmth, no tint — pure cosmic void.
- bg: `#0b0a10`
- fg: `#3cfaff`
- This is the baseline everything else violates.

### Walker (app launcher)
**The centerpiece rule-break.** Light background in a dark theme. Looks like a portal opened.
- bg: `#f5c2e7` — cotton candy pink
- text: `#1a0020` — near-black purple (enough contrast, reads circus)
- selected/accent: `#6c1a8a` — deep purple
- border: `#b96bff` — alien glow
- The contrast ratio is fine. The wrongness is intentional.

### SwayOSD
Spaceship instrument panel. Not a popup — a readout.
- bg: `#001a0d` — very dark green, almost black
- fg/icon/progress: `#2dff6a` — slime green
- border: `#2dff6a` at low opacity
- Feels like a different device entirely from the pink launcher.

### Mako (notifications)
Inverted. A clown handing you a note written on cream paper.
- bg: `#fffaf0` — cream white
- text: `#1a0020` — dark purple
- app name / summary: `#ff3c8e` — hot pink
- border: `#ff4fd8` — cosmic magenta
- `top-center` anchor recommended — ringmaster announcement energy

### Hyprlock
The void, waiting.
- bg: `#0a0005` — deeper than space black, slight red-black
- password ring: `#f5c2e7` idle → `#ff4fd8` typing → `#2dff6a` success
- font color: `#3cfaff`
- placeholder: `#3cfaff` at 50% opacity

### Hyprland Decoration

**Concept:** Tiled windows are sharp-cornered and opaque — the void is total, not frosted. Floating windows get rounding and blur so they feel like objects dropped in from another dimension. The active window radiates a magenta shadow glow. Inactive windows dim slightly and sink into the dark with a barely-visible purple shadow. Walker gets no blur — the pink must be solid and shocking, not translucent.

#### Borders

Full circus stripe. Every accent color in the palette cycles around the frame — hot pink into magenta into alien purple into cobalt into slime green into spotlight yellow and back to pink. Thick enough that you can read every color. Inactive border is dead void so the active gradient hits like a freight train by contrast.

```ini
border_size = 6

col.active_border   = rgba(ff3c8eff) rgba(ff4fd8ff) rgba(b96bffff) rgba(4b6cffff) rgba(2dff6aff) rgba(ffe347ff) rgba(ff3c8eff) 45deg
col.inactive_border = rgba(1a002066)   # void purple, barely there
```

#### Rounding

Tiled windows: zero. Sharp corners, no apology. Floating windows get rounding so they visually lift off the desktop — they're objects from somewhere else.

```ini
rounding = 0   # global default — tiled windows are sharp

# windowrule overrides for floats:
# windowrulev2 = rounding 14, floating:1
```

#### Shadows

The active window glows. It doesn't just sit there — it pulses magenta into the dark. Inactive windows cast a void-purple shadow that barely registers, like something half-seen in a dark tent.

```ini
drop_shadow         = true
shadow_range        = 45
shadow_render_power = 3          # soft falloff
shadow_offset       = 0 5        # slight downward — weight, not float

col.shadow          = rgba(ff4fd8bb)   # active: cosmic magenta glow, ~73% opacity
col.shadow_inactive = rgba(1a002055)   # inactive: void purple, barely there
```

#### Blur

Blur is on for floating surfaces only — the tiled void doesn't need it. The vibrancy setting pulls ambient color into blurred surfaces, so floats pick up a faint purple-black tint from the dark desktop. Film noise adds texture — the cosmos isn't clean.

```ini
enabled      = true
size         = 8
passes       = 3
new_optimizations = true

noise      = 0.03    # subtle grain — the cosmos has texture
contrast   = 0.90    # slight darkening through the blur
brightness = 0.85    # keeps blurred surfaces from blowing out
vibrancy   = 0.15    # pulls ambient void-purple into blurred surfaces
vibrancy_darkness = 0.5   # affects the dark areas more than bright
xray       = false
```

#### Animations

The `borderangle` animation with `loop` makes the gradient **spin continuously** around every active window. This is the single most clown thing in the entire theme — a rainbow pinwheel around every focused window. Keep the rotation speed moderate so the colors are readable, not strobing.

Windows arrive fast with a slight pop — no gentle eases, no slow fades. Everything is sudden.

```ini
animation = windows,     1, 4, default, slide
animation = windowsOut,  1, 3, default, popin 80%
animation = border,      1, 6, default
animation = borderangle, 1, 80, default, loop   # spinning gradient — the clown pinwheel
animation = fade,        1, 3, default
animation = workspaces,  1, 4, default, slide
```

The `80` on borderangle is one full rotation every 8 seconds — visible but not nauseating. Lower = faster spin.

#### Per-surface rules

| Surface | Rule | Why |
|---------|------|-----|
| Walker | `noblur` + `opacity 1.0` | Pink must be fully opaque — blur would dilute the rule-break |
| SwayOSD | `noblur` + `opacity 1.0` | Slime green instrument panel needs to be solid |
| Mako | `noblur` | Cream paper doesn't get frosted |
| Floating windows | `rounding 14` + blur on | Objects from another dimension |
| Terminals (tiled) | `inactive_opacity 0.93` | Slight dim when not focused — the void recedes |
| Fullscreen | `opacity 1.0` | No transparency, you're inside the tent |

```ini
# layerrules (layers, not windows)
layerrule = noblur, walker
layerrule = noblur, notifications   # mako handles its own
layerrule = noblur, swayosd

# windowrules
windowrulev2 = rounding 14, floating:1
windowrulev2 = opacity 0.93 0.93, class:(foot|kitty|alacritty|ghostty)
```

### Vencord (Discord)
**"Cotton Candy Portal"** — the channel sidebar is pink. Same rule-break as the Walker: you navigate Discord through a cotton candy world, then drop into the void to read messages. The server list is alien slime. The main chat stays space black. Three different surface temperatures in one app.

#### Surface map

| Discord surface | Bg color | Fg color | Vibe |
|----------------|----------|----------|------|
| Server list (far left) | `#001a0d` dark green | icons as-is | slime green alien world — the exterior |
| Channel sidebar | `#f5c2e7` cotton candy pink | `#1a0020` void purple | the portal — same as Walker |
| Selected channel highlight | `#ff4fd8` magenta | `#fffaf0` cream | you are here |
| Main chat area | `#0b0a10` space black | `#e6e3ff` near-white | the void where messages live |
| Member list | `#0d0b14` near-black, slightly lighter | `#3cfaff` cyan | spacecraft passenger list |
| Header bar | `#0b0a10` space black | `#3cfaff` cyan | |
| Message input | `#0b0a10` with `#ff4fd8` border | `#e6e3ff` | the mouth of the portal |
| User panel (bottom left) | `#001a0d` dark green | `#2dff6a` slime | you are the alien |

#### Accent / semantic colors

| Role | Color | Why |
|------|-------|-----|
| Unread ping badge | `#ff3c8e` hot pink | clown lipstick, unavoidable |
| Mention highlight | `rgba(255,60,142,0.18)` | pink blush in the void |
| Link color | `#4b6cff` cobalt | electric, not warm |
| Reaction selected | `#ff4fd8` magenta bg | |
| Online status dot | `#2dff6a` slime green | alive (for now) |
| Idle status dot | `#ffe347` yellow | wandered off |
| DND status dot | `#ff3c8e` hot pink | do not approach the clown |
| Offline | `#7a74a0` muted grey | gone into the void |
| Boost / premium accent | `#b96bff` alien purple | |

#### Key CSS variables to override
```
--background-secondary (channel sidebar):   #f5c2e7
--background-secondary-alt (server list):   #001a0d
--background-primary (chat + member list):  #0b0a10
--background-tertiary (header + user area): #0b0a10
--channeltextarea-background:               #0b0a10
--interactive-active (selected channel):    #1a0020
--header-primary:                           #3cfaff
--text-normal:                              #e6e3ff
--text-muted:                               #7a74a0
--brand-experiment (Discord accent):        #4b6cff
```

The channel sidebar category headers need explicit dark text (`#1a0020`) so they don't disappear into the pink. Channel names in the sidebar should be `#7a74a0` when unread-inactive and `#1a0020` when active — same void purple used in Walker.

---

## Rules This Deliberately Breaks

1. Launcher bg is **light** when everything else is dark
2. SwayOSD bg is **dark green** — a third temperature, neither cold void nor warm pink
3. Notifications are **white** — fully inverted, not a dark-theme notification at all
4. Borders are **thick** (6px) and **spin** — a rainbow pinwheel around every focused window
5. Discord has **three different surface temperatures** in one app — green server list, pink sidebar, black chat
6. There is no single "accent color" — the theme uses all six simultaneously and refuses to pick one

---

## What to implement

All done: `walker.css`, `swayosd.css`, `mako.ini`, `hyprlock.conf`, `hyprland.conf`, `swaync.style.css`, `vencord.theme.css`

1. ✅ `hyprland.conf` — gradient circus-stripe border, borderangle loop animation, magenta shadow glow, blur settings, windowrules (floating rounding 14, terminal opacity 0.93, noblur layerrules)
2. ✅ `vencord.theme.css` — Cotton Candy Portal: pink sidebar, green server list, black chat, all semantic status/mention/badge colors
3. ✅ `hyprlock.conf` — verified: idle cotton candy (`$outer_color`) → success slime (`$check_color`) correct; standard omarchy template uses 6 variables, no separate typing-state hook
