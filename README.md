# Broskie

A neon-soaked 2D platformer vertical slice built with Flutter and Flame.

Broskie runs through Neo-City, stomps corporate cubes, drinks Volt-Cola, and fights **The Foreman** to unlock the exit. The current repository intentionally focuses on one complete, testable level instead of pretending that seven unfinished worlds are done.

## What is playable

- One 3,660-pixel side-scrolling level with gaps, platforms and checkpoints
- Responsive fixed-resolution camera using Flame's `World` correctly
- Momentum movement, running, coyote time and jump buffering
- Keyboard and multi-touch controls
- Three health points, damage knockback, fall respawns and invulnerability frames
- Cash-chip collectibles
- A mystery block that releases a functional Volt-Cola speed/power state
- Three patrolling corporate-cube enemies with stomp behavior
- A three-speed, six-hit Foreman boss fight
- Locked exit, boss reward, game-over, pause, restart and completion flows
- Responsive HUD with semantic labels
- Programmatic pixel rendering, so the game has no missing runtime art dependency

## Controls

| Action | Keyboard | Touch |
| --- | --- | --- |
| Move | A/D or arrow keys | Left/right buttons |
| Jump | Space, W or up arrow | Jump button |
| Run | Shift | Volt-Cola increases touch movement speed |
| Pause | HUD pause button | HUD pause button |

The Android build is locked to landscape and uses an immersive fullscreen presentation.

## Requirements

- Flutter **3.41.0 or newer**
- Dart **3.11.0 or newer**
- Android SDK 36 for Android builds
- JDK 17

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

Never commit the keystore or `key.properties`; both are ignored.

On Windows, the guarded release pipeline runs dependency, formatting, analysis and test checks before producing an Android App Bundle:

```powershell
./build_broskie.ps1 -Target bundle
```

For a directly installable QA artifact:

```powershell
./build_broskie.ps1 -Target apk
```

The bundle path is `build/app/outputs/bundle/release/app-release.aab`.

## Architecture

```text
GameWidget overlays
├── HUD + multi-touch controls
├── Pause
├── Game over
└── Level complete

BroskieGame
└── Flame World (camera renders this tree)
    ├── NeonCityBackdrop
    ├── SolidSurface / MysteryBlock / BossGate
    ├── CashChip / VoltCola / LevelExit
    ├── GrumpyBrick enemies
    ├── TheForeman
    └── Player
```

Gameplay is deterministic and asset-independent. Input state is isolated in `InputController`; HUD state is published through a typed `ValueNotifier`; collision surfaces are tracked explicitly for stable axis-separated platform physics.

## Concept art

`assets/images/` contains 1408×768 JPEG concept boards. They are deliberately **not bundled into the app** and are references, not production sprite sheets. Runtime visuals are currently rendered in code until consistent transparent sprites are created.

## Quality gates

GitHub Actions checks formatting, static analysis and tests on every branch push and pull request. Application dependencies are pinned by `pubspec.lock` once resolved.

See [roadmap.md](roadmap.md) for the honest next steps.
