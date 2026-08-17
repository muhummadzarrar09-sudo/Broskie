# Broskie Project Roadmap

This roadmap reports only integrated, playable work as complete.

## Vertical Slice — The Grey Zone

- [x] Correct Flame `World` and fixed-resolution camera architecture
- [x] Programmatic player, city, platform, collectible and enemy visuals
- [x] Momentum movement, acceleration, friction and running
- [x] Stable axis-separated platform collisions with movement substeps
- [x] Coyote time and jump buffering
- [x] Keyboard and multi-touch controls
- [x] Health, damage, knockback, fall respawn and checkpoints
- [x] Cash collectibles and functional Volt-Cola power-up
- [x] Corporate-cube patrol and stomp behavior
- [x] The Foreman boss with three speed phases and a real death path
- [x] Locked exit, level completion, pause, restart and game-over flows
- [x] Responsive and accessible HUD overlays
- [x] Unit/game tests and CI quality gates

## Production Art and Audio

- [ ] Establish one canonical Broskie model and palette
- [ ] Create transparent, lossless idle/run/jump/hurt sprite sheets
- [ ] Slice a consistent 32-pixel environment tileset
- [ ] Create production sprites and effects for cubes, Volt-Cola and Foreman
- [ ] Compose and license music/SFX
- [ ] Add audio settings, subtitles and reduced-motion options

## Content Pipeline

- [ ] Define a versioned level schema with validation and useful errors
- [ ] Build a level authoring/export tool
- [ ] Add eight polished Grey Zone levels
- [ ] Add narrative dialogue after the overlay is connected and tested
- [ ] Add save/progression only after progression design is stable

## Future Worlds

- [ ] World 2: Neon Slums / Data Broker
- [ ] World 3: Stock Exchange / Wall Street Bull
- [ ] World 4: Cloud Server / Hater Cloud
- [ ] World 5: Frozen Assets / Auditor
- [ ] World 6: Deep Web
- [ ] World 7: Penthouse / Lord Static

No future world is considered started merely because a class name or concept image exists.

## Release

- [x] Unique Android application ID
- [x] Android API 36 target
- [x] Release configuration does not use debug signing
- [x] Guarded App Bundle build script
- [ ] Create and securely back up the upload keystore
- [ ] Physical-device matrix testing
- [ ] Internal Play track and closed testing
- [ ] Store listing, privacy declarations and final accessibility review
