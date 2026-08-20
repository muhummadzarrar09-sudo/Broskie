# Broskie

A neon-soaked anti-corporate 2D platformer built with **Flutter + Flame + AI-generated pixel art**. No game-maker software — every system is Dart code, every visual is a generated PNG wired in through Flame's sprite pipeline.

Broskie breaks out of Monopoly Corp's orientation, crosses the Grey Zone, the Neon Slums and the Stock Exchange, then storms the Executive Arena for the double boss fight against **The Foreman** and the **Data-Broker**.

## Campaign

1. **The Grey Zone** — movement onboarding: run, jump, dash, mystery blocks, patrolling corporate cubes and the first propaganda hijack.
2. **Neon Slums** — a data-spike crossing on a moving ferry platform, pulsing lasers and the Hater Cloud's slow-aura.
3. **Stock Exchange** — Wall Street bulls that charge themselves dizzy against the floor bounds, a vertical lift and the Auditor's Frozen Assets debuff.
4. **Executive Arena** — the dual boss fight. Bait the Foreman's charge into the arena walls and stomp him while he is dazed; burn down the Data-Broker's proxy and final form with vinyl boomerangs while dodging data-bolt volleys and control hacks.

## Features (what is actually in the build)

- Four side-scrolling stages with AI-generated tiled backdrops per stage
- **Branded splash screen** (AI key art with Ken Burns zoom, glowing/floating title, REAL asset-preload progress bar, fade into the menu) and a **living main menu** — swaying/breathing rooftop key art, procedural code-rain, staggered button entrances, floating title
- 3-heart health with knockback, invulnerability frames and **checkpoint flags** — falls respawn at the last flag, not the stage start — plus a live hearts/cash/stage HUD built on `ValueNotifier`s
- **Boss-gated exit**: the Stage 4 portal stays LOCKED until both executives are down
- **Progression that sticks**: cleared stages unlock the next one, saved on-device with your settings (SharedPreferences — no accounts, no servers, crew build)
- **Stage ranks (C/B/A/S)**: graded on hearts kept and clear time vs par, best rank per stage saved and flexed on the level-complete screen AND the stage-select tiles
- Game-feel movement kit: momentum, run, **dash** (K/Ctrl), **coyote time**, **jump buffering** and **variable jump height**
- Vinyl boomerang with cooldown that damages grunts *and both bosses*
- Real boss battles: Foreman pace/charge/wall-crash/dizzy cycle with three phases; Data-Broker hover corridors, aimed bolt volleys, control inversion, proxy fake-out and death dialogues
- Stomp combos, patrol-bounded enemies (nobody walks off the stage forever anymore)
- Slow debuffs wired live (Hater Cloud aura, Auditor audit), control-hack inversion, mystery-block power-ups with the Volt sheet swap
- Cash collectibles feeding one shared wallet used by the Black Market shop
- Stage select gated by real unlocks, pause menu, **settings that actually work** (SFX, music, touch controls, screen-shake strength), game-over, level-complete stats and victory flows
- Wired audio: synthesized SFX (jump/dash/hit/pickup/power-up/stomp/boss/stage-complete/UI), the menu chiptune `neon_loop.wav`, plus **one synthesized stage theme per stage** (pure-code chiptunes — `tools/make_chiptunes.py` writes the WAVs), with working mute switches
- Splash-screen news ticker, lore terminals, boss banter and the "DELETED" game-over stamp
- AI sprite sheets (4-frame normal + Volt run cycles, transparent bosses/grunts) with a procedural pixel-painter fallback per component, so missing art never breaks a build

## Controls

| Action | Touch (the real game) | Keyboard (debug) |
| --- | --- | --- |
| Move | Hold left / right | A/D or arrows |
| Jump (hold to float) | Hold **A** | Space / W / up |
| Dash | **DASH** | K or Left Ctrl |
| Vinyl | **B** | J or F |
| Pause | HUD pause / Android Back | HUD pause |

Difficulty is chosen on the title screen: **Easy (5 hearts) / Normal (3) / Hard (1)**.

The Android build is locked to landscape. Touch is first-class.

## Art pipeline (code + AI images only)

- `assets/images/runtime/` — production art that ships in the bundle: 4 stage backdrops (1376×768, tiled), transparent sprite sheets (4×258×256 frames) and transparent character/boss PNGs.
- The root of `assets/images/` keeps the original concept boards **out of the bundle** — only the skyline parallax layers ship.
- When generating new sheets: flat even background (alpha preferred), 4+ frames in one horizontal strip, consistent palette and canvas size per frame. Components try the art first and fall back to the procedural painter, so regenerating art is always safe.

## Requirements

- Flutter **3.41.0 or newer** (Dart **3.11 or newer**)
- Android SDK 36 for Android builds, JDK 17

## Run and test

```bash
flutter pub get
# Commit the generated pubspec.lock for reproducible application builds.
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

## Crew build (sideloaded — no Play Store)

Broskie ships as an APK handed straight to the crew. No store signing, no keystores needed: the guarded script builds a debug-signed APK that installs on any Android phone:

```powershell
./build_broskie.ps1 -Target apk
```

This writes `build/app/outputs/flutter-apk/BROSKIE.apk` — send it to the group chat, tap, install ("allow unknown apps" once), done. The script still refuses to package until format, analysis and tests pass. If a signed release is ever wanted later, the `android/key.properties` flow stays documented in git history.

## Architecture

```text
GameWidget overlays (main.dart)
├── Main menu / HUD (hearts·stage·cash listenables) / touch controls / news ticker
├── Stage select (unlock-gated) / settings / pause / shop
├── Level complete / game over / victory / dialogue
└── BroskieGame (FlameGame) + SharedPreferences save
    ├── Sky parallax (asset) or procedural skyline fallback
    ├── StageBackdrop (tiled AI art) per stage
    ├── Floor / InteractableBlock / MovingPlatform / CrumblingPlatform
    ├── CheckpointFlag / DataBitCoin / PropagandaSign / InteractableLore / LevelExit (lockable)
    ├── DataSpike / LaserHazard
    ├── GrumpyBrick / WallStreetBull / HaterCloud / AuditorEnemy
    ├── TheForeman / DataBrokerBoss (+ DataBolt)
    ├── VinylBoomerang
    └── Player (sprite sheets + procedural fallback)
```

One game, one architecture: code that is not wired into `main.dart` does not stay in the repo.

## Quality gates

`flutter analyze` and `flutter test` (Flame boot/restart/fall/advance smoke tests) must pass before packaging; `build_broskie.ps1` enforces the gates. Commit `pubspec.lock` after the first Flutter-enabled `pub get`. Hosted CI is still pending (GitHub App workflow permission).

See [roadmap.md](roadmap.md) for remaining production work.
