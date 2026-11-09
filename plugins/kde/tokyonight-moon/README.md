# Tokyo Night Moon color scheme for Plasma

Color scheme for Plasma 6 based on the **Tokyo Night Moon** palette from
[folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim) (`lua/tokyonight/colors/moon.lua`),
with the file structure borrowed from [nonetrix/tokyonight-kde](https://github.com/nonetrix/tokyonight-kde)'s
`TokyoNight.colors`.

## Palette mapping

| Moon token | Hex | Used as |
|---|---|---|
| `bg` | `#222436` | Window/View/Tooltip `BackgroundNormal` |
| `bg_dark` | `#1e2030` | Alternates (row stripes), Header background |
| `bg_dark1` | `#191b29` | Complementary/alternate deep background |
| `bg_highlight` | `#2f334d` | Button background |
| `fg` | `#c8d3f5` | `ForegroundNormal`, WM active foreground |
| `dark5` | `#737aa2` | `ForegroundInactive`, WM inactive foreground |
| `blue` | `#82aaff` | Focus/Hover decoration, selection background, links |
| `red` | `#ff757f` | Negative states |
| `orange` | `#ff966c` | Neutral states |
| `green` | `#c3e88d` | Positive states |
| `magenta` | `#c099ff` | Visited links |
| `teal` | `#4fd6be` | `BackgroundAlternate` for Button/Selection |

## Install

Choose **Tokyo Night Moon (color scheme)** in the Plugins menu, or run manually:

```bash
plugins/kde/tokyonight-moon/install.sh
```

Files land in `~/.local/share/color-schemes/TokyoNightMoon.colors`; apply via
System Settings → Colors.

## Notes

- This only covers Plasma's color roles (widgets, selection, window
  decorations' text/button colors). Window decoration themes (Aurorae/Klassy)
  and Konsole profiles are separate — Konsole already ships a moon colorscheme
  in tokyonight.nvim's `extras/konsole/tokyonight_moon.colorscheme`.
- Selection foregrounds use `bg` over `blue` for legibility, matching the dark-on-selection
  pattern of the original `TokyoNight.colors`.
