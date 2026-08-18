# Broskie Project Roadmap

This roadmap reports only integrated code as complete. Runtime certification on a Flutter-enabled machine remains required before release.

## Compact Campaign

- [x] Main menu, continue/new run and stage select
- [x] Four distinct campaign stages with unique geometry and palettes
- [x] Stage briefings, reactive broadcasts and a complete ending
- [x] SharedPreferences progression, settings and best-rank persistence
- [x] C/B/A/S stage result system
- [x] Correct Flame `World`, smooth follow target and wide-screen responsive camera
- [x] AI-assisted stage backgrounds and transparent player/enemy/boss sprites
- [x] Animated rain, sparks, ambient particles and distant traffic
- [x] Branded native/Flutter loading presentation
- [x] Code-driven platforms, collectibles, hazards and reliable hitboxes
- [x] Momentum movement, acceleration, friction, running and directional dash
- [x] Stable axis-separated platform collisions with movement substeps
- [x] Coyote time and jump buffering
- [x] Keyboard and multi-touch controls
- [x] Health, damage, knockback, fall respawn and checkpoints
- [x] Cash collectibles, propaganda terminals and functional Volt-Cola
- [x] Flow meter with four gameplay states and speed scaling
- [x] Corporate-cube patrol and stomp behavior
- [x] Data spikes, control-hack zones and projectile attacks
- [x] The Foreman boss with three speed phases and a real death path
- [x] Data Broker final boss with escalating attacks and control inversion
- [x] Locked exits, stage completion, pause, restart and game-over flows
- [x] Responsive and accessible HUD overlays
- [x] Haptics, touch-control and reduced-effects settings
- [x] Input, persistence and Flame game tests
- [ ] Run `flutter analyze` and `flutter test` on Flutter 3.41+
- [ ] Hosted CI workflow (blocked by current GitHub App workflow permission)
- [ ] Commit the generated `pubspec.lock`

## Production Art and Audio

- [ ] Establish one canonical Broskie model and palette
- [ ] Create transparent, lossless idle/run/jump/hurt sprite sheets
- [ ] Slice a consistent 32-pixel environment tileset
- [ ] Create production sprites and effects for cubes, Volt-Cola and both bosses
- [ ] Compose and license music/SFX
- [ ] Add volume settings, subtitles and reduced-motion tuning

## Campaign Polish

- [ ] Physical-device playtesting and movement tuning
- [ ] Add contextual tutorial prompts to Stage 1
- [ ] Balance stage target times and boss damage windows
- [ ] Add controller input and remapping
- [ ] Add golden tests for major overlays
- [ ] Add save migration/versioning before changing the progression schema

## Future Expansion

- [ ] Wall Street Bull bonus encounter
- [ ] Frozen Assets / Auditor expansion
- [ ] Deep Web challenge stage
- [ ] Lord Static post-game boss
- [ ] Ghost runs and daily policy modifiers

Future content is not considered started merely because a class name or concept image exists.

## Release

- [x] Unique Android application ID
- [x] Android API 36 target
- [x] Release configuration does not use debug signing
- [x] Guarded App Bundle build script
- [ ] Create and securely back up the upload keystore
- [ ] Physical-device matrix testing
- [ ] Internal Play track and closed testing
- [ ] Store listing, privacy declarations and final accessibility review
