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
- 3-heart health with knockback, invulnerability frames and fall-respawn at the stage start — plus a live hearts/cash/stage HUD built on `ValueNotifier`s
- Game-feel movement kit: momentum, run, **dash** (K/Ctrl), **coyote time**, **jump buffering** and **variable jump height**
- Vinyl boomerang with cooldown that damages grunts *and both bosses*
- Real boss battles: Foreman pace/charge/wall-crash/dizzy cycle with three phases; Data-Broker hover corridors, aimed bolt volleys, control inversion, proxy fake-out and death dialogues
- Stomp combos, patrol-bounded enemies (nobody walks off the stage forever anymore)
- Slow debuffs wired live (Hater Cloud aura, Auditor audit), control-hack inversion, mystery-block power-ups with the Volt sheet swap
- Cash collectibles feeding one shared wallet used by the Black Market shop
- Stage select, pause menu, settings, game-over, level-complete stats and victory flows
- Wired audio: synthesized SFX (jump/dash/hit/pickup/power-up/stomp/boss/stage-complete/UI) plus the looping neon chiptune `neon_loop.wav`
- Splash-screen news ticker, lore terminals, boss banter and the "DELETED" game-over stamp
- AI sprite sheets (4-frame normal + Volt run cycles, transparent bosses/grunts) with a procedural pixel-painter fallback per component, so missing art never breaks a build

## Controls

| Action | Keyboard | Touch |
| --- | --- | --- |
| Move | A/D or arrow keys | Left/right buttons |
| Jump (variable height) | Space, W or up arrow | A button |
| Run | Shift | — |
| Dash | K or Ctrl | — |
| Vinyl Boomerang | J or F | B button |
| Pause | HUD pause button | HUD pause button |

The Android build is locked to landscape.

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

## Release signing

Release builds are never signed with Flutter's debug key. Create a private upload keystore outside Git, then create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:\\absolute\\path\\to\\upload-keystore.jks
```

Never commit the keystore or `key.properties`; both are ignored. See `build_broskie.ps1` for the guarded bundle/APK pipeline.

## Architecture

```text
GameWidget overlays (main.dart)
├── HUD (hearts / stage / cash via ValueListenableBuilder) / touch controls / news ticker
├── Stage select / settings / pause / shop
├── Level complete / game over / victory / dialogue
└── BroskieGame (FlameGame)
    ├── Sky parallax (asset) or procedural skyline fallback
    ├── StageBackdrop (tiled AI art) per stage
    ├── Floor / InteractableBlock / MovingPlatform / CrumblingPlatform
    ├── DataBitCoin / PropagandaSign / InteractableLore / LevelExit
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
