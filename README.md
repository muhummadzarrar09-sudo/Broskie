# Broskie

A landscape **Android** platformer built with Flutter + Flame. Broskie is a kid with a vinyl. Monopoly Corp is the grey. Touch is the real input.

## Campaign

1. **The Grey Zone** — movement onboarding: run, jump, dash, mystery blocks, patrolling corporate cubes and the first propaganda hijack.
2. **Neon Slums** — a data-spike crossing on a moving ferry platform, pulsing lasers and the Hater Cloud's slow-aura.
3. **Stock Exchange** — Wall Street bulls that charge themselves dizzy against the floor bounds, a vertical lift and the Auditor's Frozen Assets debuff.
4. **Executive Arena** — Foreman first (bait his charge into the walls, stomp the daze). The Data-Broker clocks in after he falls.

## Features (what is actually in the build)

- Four stages, Mario-shaped camera (street in the lower third), WORLD 1-N load cards
- Easy (5 hearts) / Normal (3) / Hard (1)
- Checkpoints, one-heart pit tax, platforms that carry you
- Sequenced stage-4 bosses; exit locked until both are down
- Ranks C/B/A/S, unlocks, vinyl wallet, settings — all on-device
- Touch-first: hold A to float, DASH, B vinyl; invert hits thumbs
- Settings: FX/music volume, haptics, shake, touch toggle
- Synthesized SFX + one chiptune per stage (`tools/make_chiptunes.py`)

## Controls

| Action | Touch (the real game) | Keyboard (debug) |
| --- | --- | --- |
| Move | Hold left / right | A/D or arrows |
| Jump (hold to float) | Hold **A** | Space / W / up |
| Dash | **DASH** | K or Left Ctrl |
| Vinyl | **B** | J or F |
| Pause | HUD pause / Android Back | Esc or P |

Difficulty is chosen on the title screen: **Easy (5 hearts) / Normal (3) / Hard (1)**.

The Android build is locked to landscape. Touch is first-class.

## Art pipeline (code + AI images only)

- `assets/images/runtime/` — production art that ships in the bundle: 4 stage backdrops (1376×768, tiled), transparent sprite sheets (4×258×256 frames) and transparent character/boss PNGs.
- The root of `assets/images/` keeps the original concept boards **out of the bundle** — only the skyline parallax layers ship.
- When generating new sheets: flat even background (alpha preferred), 4+ frames in one horizontal strip, consistent palette and canvas size per frame. Components try the art first and fall back to the procedural painter, so regenerating art is always safe.

## Requirements

- Flutter **3.44+** (Dart **3.12+**). 3.47 / Dart 3.13 is fine.
- Android SDK 36, JDK 17. Phone, landscape. No iOS/web/desktop ship.

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
./build_broskie.ps1
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
    ├── Floor / InteractableBlock / MovingPlatform
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
