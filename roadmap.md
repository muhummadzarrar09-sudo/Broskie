# Broskie Project Roadmap

This roadmap reports only integrated, running code as complete. Runtime certification on a Flutter-enabled machine remains required before release.

## Compact Campaign

- [x] In-game stage select, pause, restart, level-complete and game-over flows
- [x] Four distinct campaign stages with unique geometry, hazards and AI-art backdrops
- [x] Reactive boss broadcasts (dialogue) and a victory ending
- [x] Tiled `StageBackdrop` renderer wired to the generated stage backgrounds
- [x] 4-frame normal + Volt run sheets and transparent cube/boss sprites, procedural fallback kept
- [x] 3-heart health, damage, knockback, invulnerability frames and fall-respawn to stage start
- [x] Live hearts/cash/stage HUD via `ValueNotifier`s
- [x] Momentum movement, acceleration, friction and running
- [x] Directional dash (K/Ctrl) with cooldown and afterimage trail
- [x] Coyote time, jump buffering and variable jump height
- [x] Keyboard and multi-touch controls routed through one jump-buffer API
- [x] Cash collectibles with one shared wallet across HUD and Black Market shop
- [x] Mystery-block power-ups (classic/juggernaut/shockwave) with power absorb on hit
- [x] Vinyl boomerang that damages grunts, the Foreman and the Data-Broker
- [x] Patrol-bounded corporate cubes and stomp combos
- [x] Wall-crash bull charges, dizzy stun windows and stomp punish
- [x] Real Foreman fight: pace/charge cycle, arena-edge crashes, dizzy stomps, three phases
- [x] Real Data-Broker fight: aimed bolt volleys, control hacks, proxy fake-out, hover drift
- [x] Data spikes, pulsing lasers, moving platforms, control-hack inversion
- [x] Live slow debuffs (Hater Cloud aura, Auditor Frozen Assets)
- [x] Wired SFX for the real files on disk + looping `neon_loop.wav` chiptune; audio init in `main()`
- [x] Correct Flame camera follow and stage-edge mortality (`onPlayerFell`)
- [x] Main menu (NEW RUN / CONTINUE / STAGE SELECT / SETTINGS) over a paused world
- [x] Checkpoint flags: falls respawn at the last flag inside the stage
- [x] Boss-gated Stage 4 exit (locked until both executives are defeated)
- [x] Working settings (SFX / music / touch controls / shake strength) wired live
- [x] On-device persistence of settings + stage unlocks (crew build, no accounts)
- [x] Unlock-gated stage select
- [x] Flame smoke tests against the live API (boot / restart / fall / advance / checkpoint / boss-gate / unlock)
- [x] Dead-code purge: ~2,800 lines of an unwired second architecture removed
- [ ] Run `flutter analyze` and `flutter test` on Flutter 3.41+ (this sandbox has no Flutter SDK)
- [ ] Commit the generated `pubspec.lock`
- [ ] Hosted CI workflow (blocked by current GitHub App workflow permission)

## Production Art and Audio

- [ ] One canonical Broskie model sheet (idle/jump/hurt frames beyond the run cycle)
- [ ] Consistent 32px environment tileset sliced from the generated backdrops
- [ ] Additional AI boss animation frames (Foreman charge anticipation, Broker glitch frames)
- [ ] Optional composed music per stage (the neon loop currently serves all stages)
- [ ] Volume sliders and a real settings implementation (toggles are UI-only today)

## Campaign Polish

- [ ] Physical-device playtesting and movement tuning (crew APK feedback round)
- [ ] Contextual tutorial prompts in Stage 1
- [ ] Balance stage target times, boss health and damage windows
- [ ] Stage ranks (C/B/A/S) shown on level-complete, persisted per stage
- [ ] Controller input and remapping
- [ ] Golden tests for major overlays

## Future Expansion

- [ ] Wall Street Bull bonus arena
- [ ] Frozen Assets / Auditor expansion
- [ ] Deep Web challenge stage
- [ ] Lord Static post-game boss
- [ ] Ghost runs and daily policy modifiers

Future content is not considered started merely because a class name or concept image exists — and classes that exist are now required to be wired in.

## Crew Distribution (no Play Store)

Broskie is a crew build: sideloaded APK, no store, no signing ceremony.

- [x] Unique Android application ID
- [x] Android API 36 target
- [x] Guarded APK build script (format + analyze + test gates before packaging)
- [ ] Physical-device matrix testing on crew phones
- [ ] Ship `BROSKIE.apk` to the group chat
- [ ] (Optional, later) Signed release keystore if a store build ever returns
