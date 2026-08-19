# BROSKIE — Design Center

> **A neon-noir rhythm rebellion. Sound is the weapon against standardization.**
> Every art, UI, FX, enemy and collectible decision must pass one test:
> *"Does this serve the war between Beat and Barcode?"*

## The fingerprint: BARCODE vs GRAFFITI

- Everything corporate is stamped with a **barcode** (cubes, propaganda, bosses, locked exit).
- Everything Broskie touches gets **painted/remixed** (hijacked signs, smashed blocks, liberated exits).
- Standardization vs self-expression. This is the one-glance identity.

## Locked palette (5 colors + 1 semantic exception)

| Role | Color | Usage |
| --- | --- | --- |
| Night | `#0F0C20` | World base, overlay backgrounds |
| Signal Cyan | `#22E6FF` (approx `#00E5FF`) | System, HUD, Broskie-affiliated neon |
| Glitch Magenta | `#FF3FA4` (approx) | Danger, hacks, market, boss accents |
| Volt Amber | `#FFB800` (approx) | Action, player agency, ranks, cash |
| Bone | `#F2F2F2` | Text on dark, highlights |
| GO Green | `#00FF66` | Semantic only: exits, heals, success |

No off-palette colors in new work. Blur is the enemy: pixel art is `FilterQuality.none`.

## Typography law

- Monospace everywhere; ALL-CAPS headlines; letter-spacing discipline (2–10px by size rank).
- In-world and overlay text gets a **2px hard black offset shadow — never a blur shadow**.

## "BROSKIE OS" UI kit (rules, widgets to follow)

- 3px chunky pixel borders; border radius never above 8px; scanline painter on every overlay (CRT signature texture).
- Amber = do it. Cyan = system/info. Magenta = danger/black market.
- Pixel-drawn glyphs over Material icons wherever the icon is diegetic (hearts, cash, dash, rank).
- Every button plays `ui_click.wav`.

## World & character language

- Permanent night rain. Neon signage flickers on the stage theme's BPM (the world dances to its own chiptune).
- AI pixel art is canonical for ALL characters/enemies; procedural canvas rendering only as invisible fallback.
- Enemies read as one coherent **Monopoly Corp product line** (boxy grey plastic, red barcode eye); rebel elements are warm/vinyl black.
- Vinyl is the collectible currency (DATA VINYLS), the projectile, and the loading spinner. Headphone/vinyl pixel hearts on the HUD.
- Bosses: barcode-stamped management hardware. Health bars read "SIGNAL INTEGRITY".

## Game-feel law

- 60–90ms hit-stop on stomps and boss hits; white kill-flash.
- Boss telegraphs are always visible (Foreman eye-flash + breath before charge; Broker glitch-flicker before volley).
- Screen shake reserved for big events (respect the shake slider).
- The power-up system has ONE identity: Volt-Cola = Bass Boost. No option exists that doesn't feel and read different.

## Forbidden in the design center

- Colors outside the palette, blurred pixel art, Material-default widget looks, rounded blobs > 8px radius,
  features/UI text that promise behavior that does not exist. A centered design never lies to the player.
