# BROSKIE — Design Center (v2)

The v1 “neon OS / barcode CRT” brief produced a game that looked like a prompt
and played like a prototype. This document replaces it.

Broskie is a **phone platformer** about one kid who will not be standardized.
If a decision does not make Broskie — the character — more readable on a
landscape Android screen, it does not ship.

## Who this is for

- **Platform:** Android landscape. Touch is the real input. Keyboard is a
  debug stick, not a second product.
- **Why it exists:** learn 2D game feel and ship an APK. Not a store page.
- **Difficulty:** Mario-shaped. Easy / Normal / Hard, chosen on the title
  screen, saved on-device.

## The character is the fingerprint

Broskie is a backwards-cap street kid with a vinyl in his hand.

- He is **warm**: bone, brick-red cap, denim, volt-amber when he acts.
- The corp is **cold grey plastic**, not generic cyan-magenta soup.
- Graffiti is something Broskie **does**, not a filter we overlay on every
  menu. One sticker on a concrete panel beats a full-screen neon plate.

Painted AI backdrops are atmosphere **behind** the street. They must never
pretend to be floors. The walkable world is geometry you can read at a
glance: dark concrete, a 4 px bone lip, no fake ledges.

## Palette (tight)

| Role | Hex | Use |
| --- | --- | --- |
| Night concrete | `#12100C` | Screens, street, menus |
| Bone | `#F2E6D4` | Text, floor lip, outlines |
| Cap red | `#E52521` | Broskie, danger, game-over |
| Denim | `#1F4287` | Panels, secondary |
| Volt | `#FFB800` | Jumps, cash, “do this” |
| GO | `#3DDC84` | Exits, checkpoints (Android green on purpose) |

Cyan and magenta are **not** brand colors anymore. If they appear, they are
enemy tech, and they should feel hostile.

## UI law (phone)

- Touch targets ≥ 56 dp. Bottom cluster sits **above** the nav bar.
- `SafeArea` on the HUD. Notch never eats hearts or pause.
- Buttons are chunky rectangles, radius **4**. No blur glow, no Material
  hamburger soup, no 16–20 px squircles.
- Type: monospace, ALL-CAPS headlines, **hard 2 px offset shadow**.
- Every menu is Broskie talking, not “BROSKIE OS.” Pause is PAUSED, not
  SYSTEM OVERRIDE.

## Camera (Mario-shaped)

The lens is a **640×360** window on the street, not “center on Broskie.”

- Ground lives in the **lower third**. Broskie stands in the **lower-middle**.
- Follow X with look-ahead (you see more of where he is running).
- Y is locked to the street unless he climbs (stage 3 tower).
- You should never see a huge empty pit under the floor. That was the old
  `camera.follow(player)` bug — it put his head in the dead center.

## Feel law (Mario-shaped)

- Coyote time, jump buffer, variable jump (hold A). Same on touch and keys.
- One mistake, one heart. A spike pit must not also charge a fall-death.
- Moving platforms carry you. If they do not, they are not platforms.
- Easy: 5 hearts, slower enemies, generous assist.
- Normal: 3 hearts — the game we balance for.
- Hard: 1 heart, faster enemies, tight assist. Checkpoints stay (this is not
  kaizo unless we say so later).

## Forbidden

- Blur shadows, CRT scanlines on the HUD, fake “OS” copy, keyboard tutorials
  on a phone build, menus that do not pause the world, painted floors that
  are not colliders, features the UI names but the code does not do.
