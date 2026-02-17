# DWM -> Omarchy Hyprland Config Pack

This folder ports your custom `dwm` workflow from `config.h` into Hyprland config fragments.

## Easiest + Most Valuable From Your DWM Config

1. `SUPER + h/j/k/l` directional focus  
   This is the fastest habit to keep and maps cleanly to Hyprland (`movefocus`).
2. `SUPER + [1..9]` workspace model  
   Your tag-based mental model transfers directly to Hyprland workspaces.
3. App-to-workspace rules (Slack on 8, Discord on 9, qutebrowser on 3, rider on 2)  
   This gives immediate organization without extra complexity.
4. Gaps, borders, and selected-border color  
   These are simple to set and preserve your existing visual feel.
5. Existing script-driven automation (`goToProgram.sh`, volume/brightness, VPN, screenshots)  
   Highest productivity win because your scripts already encode your workflow.

## Files

- `omarchy-hyprland-config/01-look-and-layout.conf`
- `omarchy-hyprland-config/02-window-rules.conf`
- `omarchy-hyprland-config/03-keybinds.conf`
- `omarchy-hyprland-config/scripts/goToProgram.sh` (Hyprland + X11 fallback)
- `omarchy-hyprland-config/scripts/goToZoom.sh` (Hyprland + X11 fallback)

## Use In Omarchy

Add these `source` lines to your active Hyprland config:

```conf
source = /home/sudqi/old/home/sudqi/Downloads/dwm-6.5/omarchy-hyprland-config/01-look-and-layout.conf
source = /home/sudqi/old/home/sudqi/Downloads/dwm-6.5/omarchy-hyprland-config/02-window-rules.conf
source = /home/sudqi/old/home/sudqi/Downloads/dwm-6.5/omarchy-hyprland-config/03-keybinds.conf
```

If Omarchy stores config elsewhere, copy this directory into that config path and update the `source` paths.

## Notes

- Multi-step `dwm` keychords were converted to direct Hyprland combos where needed.
- `dwm` "view all tags" (`SUPER+0`) has no direct equivalent, so `0` is mapped to a scratch workspace.
- `st` is kept as terminal to stay close to your `dwm` setup. Change `$terminal` in `01-look-and-layout.conf` if you want `kitty`, `foot`, or another Wayland-native terminal.
- `03-keybinds.conf` defines `$wmScripts` and routes `SUPER+Q/D/R/Z` through the new compositor-aware scripts.
