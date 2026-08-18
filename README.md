# Broskie

A compact neon-soaked 2D platformer campaign built with Flutter and Flame.

Broskie breaks out of corporate orientation, crosses the Factory and Neon Slums, defeats **The Foreman**, and attacks the **Data Broker** inside the Monopoly Core. The campaign has a beginning, progression, two boss encounters and a real ending—without pretending that dozens of placeholder levels are complete.

## Campaign

1. **The Grey Zone — Unauthorized Individuality**
   Movement onboarding, alternate platform lines, corporate cubes and the first propaganda hijack.
2. **The Factory — Management Is Watching**
   Industrial traversal, denser patrols and a three-speed Foreman boss fight.
3. **Neon Slums — Terms and Conditions Apply**
   Data spikes, control-hack zones, rebel terminals and a longer technical route.
4. **Monopoly Core — Going Live**
   Combined hazards and the ten-hit Data Broker fight with projectiles, control inversion and escalating speed.

## Features

- Main menu, continue/new run, stage select, settings, credits and ending
- Saved campaign unlocks, best ranks and accessibility preferences
- Four 3,000–4,600-pixel side-scrolling stages
- Responsive fixed-resolution camera using Flame's `World` correctly
- Momentum movement, running, directional dash, coyote time, jump buffering and movement substeps
- Keyboard and multi-touch controls
- Health, knockback, fall respawns, checkpoints and invulnerability frames
- Cash chips, hackable propaganda terminals and functional Volt-Cola power
- **Flow system** with CHILL, COOKING, LOCKED IN and UNGOVERNABLE states
- Patrolling corporate-cube enemies and stomp combos
- Foreman and Data Broker boss encounters
- Data spikes, hack zones and Data Broker pulse attacks
- Stage briefings, reactive broadcasts, pause/restart and game-over flows
- C/B/A/S stage ranks based on health, time and peak Flow
- Responsive HUD with semantic labels and optional touch controls
- Haptic and reduced-effects preferences
- AI-assisted production backgrounds and character sprites backed by reliable code collision geometry

## Controls

| Action | Keyboard | Touch |
| --- | --- | --- |
| Move | A/D or arrow keys | Left/right buttons |
| Jump | Space, W or up arrow | Jump button |
| Run | Shift | Volt-Cola and Flow increase movement speed |
| Dash | K or Ctrl | Yellow dash button |
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

For a directly installable, debug-signed QA artifact:

```powershell
./build_broskie.ps1 -Target apk
```

This writes `build/app/outputs/flutter-apk/BROSKIE.apk`. The APK target deliberately uses debug mode so it installs without a private release key; Play Store bundles still use guarded release signing.

## Architecture

```text
GameWidget overlays
├── Main menu / stage select
├── Stage briefing / HUD / touch controls
├── Settings / pause / game over / results
└── Ending / credits

BroskieGame
├── CampaignRepository → SharedPreferences
├── Stage catalog + campaign/rank state
└── Flame World (camera renders this tree)
    ├── Themed NeonCityBackdrop
    ├── SolidSurface / MysteryBlock / BossGate
    ├── CashChip / VoltCola / PropagandaTerminal / LevelExit
    ├── DataSpike / HackZone / DataPulse
    ├── GrumpyBrick enemies
    ├── TheForeman / DataBrokerBoss
    └── Player
```

Input is isolated in `InputController`; campaign and HUD state are exposed through typed `ValueNotifier`s; collision surfaces are tracked explicitly for stable axis-separated platform physics. `CampaignRepository` has both device-backed and in-memory implementations so persistence can be tested without plugins.

## Concept art

`assets/images/` contains the original 1408×768 JPEG concept boards, while `assets/images/runtime/` contains dedicated AI-assisted game backgrounds and transparent character sprites derived from that direction. Only the runtime directory is bundled. Physics and hitboxes remain code-driven so richer art cannot destabilize gameplay.

## Quality gates

The repository includes input, campaign-persistence and Flame game tests. The guarded PowerShell release script refuses to package the app until formatting, static analysis and all tests pass.

Hosted CI is still pending because the current GitHub App connection cannot add workflow files. The first Flutter-enabled checkout should commit the generated `pubspec.lock`.

See [roadmap.md](roadmap.md) for remaining production work.
