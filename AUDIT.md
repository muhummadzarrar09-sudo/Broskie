# BROSKIE — Domain Audit, Scores, and Sprint Plan

**Status:** audit only. **No game code was changed.**  
**Repo:** `muhummadzarrar09-sudo/Broskie` · branch `arena/01a01b09-broskie` @ `8c7dff9`  
**Date:** 2026-08-20  
**Method:** full `lib/` + Android host + assets + tests + docs read. Flutter SDK is **not** in this sandbox — `analyze` / `test` / device cert are not claimed.

---

## STEP 0 / 0.5 (carried)

| Item | Result |
| --- | --- |
| Detection | **A) EXISTING CODE** — 5,660 lines Dart, 4 playable-authored stages, Android host, 17 WAVs, runtime art, 11 Flame tests |
| Genre | **2D side-scrolling action platformer** (run / jump / dash / stomp / vinyl). `beatPulse` is cosmetic, not a rhythm game |
| Ship platform | **Android landscape only** (`com.zarrar.broskie`, crew sideload APK) |
| Incidental | Keyboard works under `flutter run` on desktop. No `ios/`, `web/`, `windows/`, `linux/`, `macos/` |
| Skipped on purpose | Voxel, open-world streaming, netcode, Play Billing, iOS review, Metal/DX backends |

**Tags:** `[AND]` Android · `[DEV]` desktop/dev keyboard · `[AGN]` engine/logic

**Severity:** Critical / High / Medium / Low

**Roadmap step IDs** (defined in the sprint section): `S1` playable phone campaign · `S2` honest combat + camera + meta · `S3` Android chrome + audio + economy · `S4` debt, CI, identity.

---

# DOMAIN 1 — Architecture & code structure

**Score: 5.0 / 10**

One real architecture (good). Two god objects, ceremonial Riverpod, no platform-abstraction layer, stages hardcoded into the sim class, lifecycle/ownership leaks, version pins that disagree. Fine for a slice; hostile to a fifth stage or a second OS.

### Findings

**1.1 · High · `[AGN]` · S4**  
`BroskieGame` (616 LOC) and `Player` (612 LOC) own construction, sim, save, camera, juice, input, art, and death.  
**Root cause:** vertical-slice velocity; no world / input / persist modules.  
**Fix:** extract `StageFactory`, `SaveService`, `InputMux`, keep FlameGame as a thin orchestrator.

**1.2 · High · `[AGN]` · S4**  
Stages are literal `Vector2(...)` lists inside `_buildStage1..4`. `assets/levels/` is an empty `.keep`.  
**Root cause:** no content format.  
**Fix:** even a Dart `StageSpec` list in its own file beats this. JSON later.

**1.3 · Medium · `[AGN]` · S4**  
`ProviderScope` + `ConsumerWidget` + `WidgetRef? ref` — **zero providers**. Riverpod is a costume.  
**Root cause:** leftover “use a state library” decision never wired.  
**Fix:** delete `flutter_riverpod` or actually inject audio/save/settings.

**1.4 · Medium · `[AGN]` · S1 / S4**  
No platform-abstraction layer. Touch writes `player.horizontalDirection` directly; keyboard goes through invert; haptics/prefs/orientation are raw plugins. Adding iOS or gamepad means hunting call sites.  
**Root cause:** Android-first, no `InputPort`.  
**Fix:** one mux (S1 for invert/jump; S4 for gamepad).

**1.5 · Medium · `[AGN]` · S4**  
Enemy types are not one hierarchy. Only `GrumpyBrick extends Enemy`. Vinyl special-cases `Enemy | TheForeman | DataBrokerBoss`. Bulls/auditor/cloud are invisible to the weapon.  
**Root cause:** types grown per-feature.  
**Fix:** `Stompable` / `VinylHittable` mixins.

**1.6 · Medium · `[AGN]` · S2**  
`BroskieGameScreen` never disposes the `FlameGame` or its 11 `ValueNotifier`s.  
**Root cause:** no widget teardown path (and no return-to-title).  
**Fix:** `dispose()` when a real menu loop exists.

**1.7 · Medium · `[AGN]` · S3**  
Error architecture is `catch (_) {}` on audio, prefs, art, haptics. Failures are silent.  
**Root cause:** “never crash a crew build.”  
**Fix:** keep fallbacks; log once; surface save failure.

**1.8 · Medium · `[AND]` · S4**  
Build host is one Android app, but AGP 9.1.0 + Gradle 9.3.1 + `android.newDsl=false` / `builtInKotlin=false` are temporary Flutter compatibility switches. Wrapper `gradlew` / jar are gitignored.  
**Root cause:** bleeding-edge Android Gradle on a Flutter game.  
**Fix:** pin AGP/Flutter together; commit or document Flutter-regenerated wrapper.

**1.9 · High · `[AGN]` · S4**  
Versioning disagrees: `pubspec.yaml` Dart `>=3.5` / Flutter `>=3.0`; lock `>=3.12` / `>=3.44`; README Flutter **3.41** / Dart **3.11**.  
**Root cause:** docs and lock drifted independently.  
**Fix:** one pin, three files.

**1.10 · Low · `[AND]` · S4**  
Leftover `com.example.broskie_game.MainActivity` beside `com.zarrar.broskie`.  
**Root cause:** package rename not cleaned.  
**Fix:** delete the example package.

**1.11 · Low · `[AGN]` · S4**  
Overlay names are magic strings (`'Shop'`, `'PauseMenu'`, …).  
**Root cause:** Flame overlay map is stringly.  
**Fix:** one `Overlays` class of consts.

**1.12 · Medium · `[AGN]` · S2**  
Save/load is methods on the game with string keys, not a service. Cash/HP/checkpoint/kills each have a different persistence story (see Domain 6 / 4).  
**Root cause:** prefs bolted on after HUD listenables.  
**Fix:** `SaveData` DTO + version field.

**1.13 · Low · `[AGN]` · S4**  
Folders `world2/`, `world4/`, `world5/` do not match stages 1–4.  
**Root cause:** leftover lore numbering.  
**Fix:** rename to `enemies/` or stage ids.

**1.14 · Low · `[AGN]` · S4**  
`add(ScreenHitbox())` — camera follows the player, so the viewport collider almost never hits. Extra pairs, no design.  
**Root cause:** Flame template leftover.  
**Fix:** remove unless you use screen-edge events.

**1.15 · Medium · `[AGN]` · S4**  
Concurrency model is “main isolate + fire-and-forget.” `InteractableBlock._bounceEffect` uses `Future.delayed` without cancellation. `savePrefs()` is unawaited (lint `unawaited_futures` is on). Haptics calls an async API and swallows only sync throws.  
**Root cause:** no job/scope.  
**Fix:** `unawaited` + mounted checks; drop delayed bounce for a timer on the component.

**1.16 · Low · `[AGN]` · S4**  
Logging = one `debugPrint` on audio init. No levels, no crash file.  
**Root cause:** crew toy.  
**Fix:** optional; not a ship gate.

**1.17 · Medium · `[AGN]` · S4**  
Asset pipeline is “drop PNGs in `runtime/`.” Concept boards are JPEG bytes named `.png` (same MD5 as sibling `.jpg`). No atlas, no import preset.  
**Root cause:** AI dump + copy.  
**Fix:** gitignore concept dupes; only `runtime/` is the pipeline.

**1.18 · Low · `[AGN]` · S4**  
Extensibility points: none. No plugin API needed; the missing one is **level data**, not mods.

### Domain 1 notes (what is good)
Single `FlameGame`, `overlaysMuted` test seam, audio/haptics façades, `ValueNotifier` HUD, `static_sweep.py` import/art checks. Shared:platform code ratio is ~95:5 — correct **until** a second OS appears.

---

# DOMAIN 2 — Core gameplay & world / content system

**Score: 4.0 / 10** · scoped to a **linear 2D platformer** (rooms = four hardcoded stages, not chunks/voxels).

The feel kit is real. The **world representation is not**: no level format, moving platforms do not carry the rider, pits double-tax HP, camera has no bounds, Stage 4 is an open dual-boss hallway. Stages 2 and 3 are not trustworthy content.

### Findings

**2.1 · Critical · `[AGN]` · S1**  
`MovingPlatform` updates its own `position`. The player is not parented and does not inherit `delta`.  
**Root cause:** collision snap is “stand on a static AABB,” then the box walks away.  
**Fix:** apply platform delta while grounded on that platform; jump inherits `vy`. **This is the campaign-completeness bug.**

**2.2 · Critical · `[AGN]` · S1**  
Stage 2 is a horizontal ferry over a 699 px spike bed. Stage 3 is a vertical lift over a 998 px spike bed. Because of 2.1, the middle of the compact campaign is structurally unsound.  
**Root cause:** content authored around a missing rider constraint.  
**Fix:** implement 2.1, **or** temporarily flatten those gaps (motive question).

**2.3 · Critical · `[AGN]` · S1**  
A fall into spikes calls `Player.hit()` and the body still drops to `y > 1400` → `onPlayerFell()` removes a **second** heart.  
**Root cause:** two independent death channels (contact + abyss) with no “already punished this fall” flag.  
**Fix:** pit = checkpoint respawn for 1 HP, **or** suppress abyss if a hit landed this airborne.

**2.4 · High · `[AGN]` · S1**  
No world X/Y clamps. Player can run off `x < -200` into empty parallax. Camera follows falls to `y=1400`.  
**Root cause:** `camera.follow(player)` with no `worldBounds`.  
**Fix:** clamp X to stage width; lock camera Y to the street until death.

**2.5 · High · `[AGN]` · S4**  
World is not data. Completing a fifth stage means editing `broskie_game.dart`. No serialization, no migration, no authoring tool.  
**Root cause:** 1.2.  
**Fix:** `StageSpec` first; Tiled later if you still want it.

**2.6 · High · `[AGN]` · S4**  
Backdrop registration ≠ collision. `StageBackdrop.groundBottom = 600`, floor `y = 480`. Code comments admit a gloom scrim to hide “fake platforms baked into the art.”  
**Root cause:** AI plates painted as levels; collision drawn as rectangles.  
**Fix:** slice a tileset to the floor line, or darken plates harder and stop painting walkable ledges.

**2.7 · High · `[AGN]` · S2**  
Stage 4 spawns **both** executives at `t=0` (`Foreman` at x=900, `Broker` at x=2600). Arenas are open. Player can pull both or skip Foreman.  
**Root cause:** “dual boss” implemented as two adds, not a sequence.  
**Fix:** spawn Broker on Foreman death, or door the arenas.

**2.8 · Medium · `[AGN]` · S4**  
Streaming/LOD/culling: N/A at this size, but splash **preloads every stage plate** (~2 MB file / ~4 MB decoded each). All four worlds stay resident.  
**Root cause:** “instant onLoad” over “mobile budget.”  
**Fix:** load current + next only (S4).

**2.9 · Medium · `[AGN]` · S2**  
Checkpoints move `playerSpawn` in RAM only. Process kill = stage start. Not documented.  
**Root cause:** flags were a feel patch, not a save feature.  
**Fix:** don’t persist mid-stage (OK) — say so. Persist cash/unlocks properly (2.11).

**2.10 · High · `[AGN]` · S2**  
`NEW RUN` is `startRun(1)`. Unlocks, ranks, cash stay.  
**Root cause:** button label written before semantics existed.  
**Fix:** new run = reset session wallet + start 1; keep unlocks unless “erase save.”

**2.11 · High · `[AGN]` · S3**  
`scoreCoins` is not in `SharedPreferences`. Wallet dies with the process **but** survives in-session death (`restart()` does not clear it).  
**Root cause:** HUD first, persist later; death-restart never given an economy policy.  
**Fix:** pick one policy (persist + reset on NEW RUN is the honest one).

**2.12 · Medium · `[AGN]` · S2**  
`stageTime` ticks during dialogue, banners, boss cards, and unpaused HUD overlays. Ranks are not a fair clock.  
**Root cause:** timer = `dt` accumulator on the unpaused engine.  
**Fix:** only tick when `runClock == true`.

**2.13 · Medium · `[AGN]` · S2**  
Par times `{35,50,55,110}` are literals with no playtest log. If 2.1 is broken, S-ranks on 2/3 are fiction.  
**Root cause:** numbers written to ship the rank UI.  
**Fix:** retune after platforms work.

**2.14 · Low · `[AGN]` · S4**  
Determinism: `Random()` constructed inside `update`/`render` (shake, dust, laser sparks). Unseeded. Replay/ghosts (roadmap) would be impossible.  
**Root cause:** juice first.  
**Fix:** one `Random` on the game if you ever want ghosts.

**2.15 · Medium · `[AGN]` · S2**  
Hidden cash exists in every stage (good) but there is no content versioning and no disk I/O beyond prefs. Mobile size: concept JPEGs are **not** in the APK (good) but **are** in git (~duplicate 1.5 MB).  
**Root cause:** 1.17.  
**Fix:** stop tracking concept dupes.

**2.16 · Medium · `[AND]` · S1**  
Stage 1 “content” is three lore terminals that teach **keyboard**. The ship target is touch.  
**Root cause:** desktop-authored onboarding.  
**Fix:** copy from the control scheme that is actually on (S1).

**2.17 · Low · `[AGN]` · S4**  
`CrumblingPlatform` and `triggerParkourVault` are world systems with **zero** placements. Content claims (README diagram) overstate the world.  
**Root cause:** systems written ahead of authoring.  
**Fix:** place or delete.

### Domain 2 notes (what is good)
Four distinct layouts, checkpoint API + test, boss-gated exit + test, rank math + tests, per-stage themes/BPM, hidden stashes, procedural art fallback so missing plates don’t crash a load.

---

# DOMAIN 3 — Rendering & performance

**Score: 4.5 / 10**

Flame hides GLES/Vulkan. There is no renderer abstraction to score, and none is needed. What exists is a **fill-rate and decode** problem on `minSdk 24`, plus a camera that eats its own shake, plus unclamped `dt` that is both a hitch and a physics bug.

### Findings

**3.1 · High · `[AGN]` · S1**  
No `dt` clamp, no terminal fall speed, no fixed step. A 200 ms hitch tunnels the 120 px floor.  
**Root cause:** default Flame `update(dt)`.  
**Fix:** `dt = min(dt, 1/20)`; cap `vy`.

**3.2 · High · `[AGN]` · S2**  
Screen shake writes `camera.viewfinder.position` then `super.update()` runs `camera.follow`, which overwrites it **the same frame**. Shake slider is a placebo.  
**Root cause:** fight between juice and follow camera.  
**Fix:** apply shake as a post-follow offset, or un-follow during shake.

**3.3 · High · `[AND]` · S4**  
Runtime plates are 1376×768 **RGB** (~2.0–2.3 MB files; ~4.2 MB decoded RGBA each). Splash loads all of them. Six key plates resident ≈ 25 MB texels before sheets. `minSdk 24` includes 2 GB phones.  
**Root cause:** AI export at near-720p, no budget.  
**Fix:** 1024-wide indexed/pngquant, or load current stage only.

**3.4 · Medium · `[AND]` · S3**  
`ui_touch_*.png` are ~380–400 px **RGB (no alpha)** drawn at 56–70 dp. Wasted memory + opaque corners on the control cluster.  
**Root cause:** graffiti sheet crop without alpha.  
**Fix:** recut RGBA at ~128 px.

**3.5 · Medium · `[AGN]` · S4**  
No frustum/occlusion culling, no sprite batching strategy, no atlas. Backdrop loop redraws every mirrored tile every frame including off-camera. Fine at N=4 tiles; sloppy.  
**Root cause:** painter-per-component.  
**Fix:** only required if a profiler says so after 3.3.

**3.6 · Medium · `[AGN]` · S4**  
`StageBackdrop` uses `FilterQuality.low`. DESIGN.md law is `none`. Player under-glow is `MaskFilter.blur(14)` on the hottest sprite.  
**Root cause:** “make him read on dark plates” vs pixel law.  
**Fix:** hard 1 px outline, no blur.

**3.7 · Medium · `[AGN]` · S4**  
Per-frame allocations: `Random()` in shake/dust/laser render; `TextPainter` in block/sign/exit/lore `render()`. Floor grid is tens of `drawLine`s on a 3000 px slab.  
**Root cause:** immediate-mode prototype render.  
**Fix:** cache painters; reuse one `Random`; bake floor to a pattern.

**3.8 · Medium · `[AND]` · S3**  
No thermal/quality scaler, no target FPS, no battery path. Scanlines + news ticker + menu rain run even when the sim is paused.  
**Root cause:** juice always on.  
**Fix:** pause overlay animations with the engine; skip scanlines on low-end later.

**3.9 · High · `[AND]` · S1**  
No `Wakelock` / `keepScreenOn`. No lifecycle stop. The phone can **sleep mid-dash** or **play BGM in a pocket**. Opposite bugs, same missing OS hook.  
**Root cause:** no `AppLifecycleListener`.  
**Fix:** S1 with pause-on-background.

**3.10 · Medium · `[AGN]` · S3**  
Audio is uncompressed PCM. Stage themes 1.2–1.8 MB; mixed **22050 Hz** (old SFX + neon loop) and **44100 Hz** (chiptunes + new stingers). Resample cost every theme swap.  
**Root cause:** two generators, two eras.  
**Fix:** one rate (48 kHz) + OGG.

**3.11 · Low · `[AND]` · S4**  
No mipmaps, no DPI virtual resolution. Ultrawide phones see more world; 4:3 tablets crop the 480-floor vs 600-backdrop.  
**Root cause:** raw pixel world.  
**Fix:** virtual 16:9 + letterbox (S4).

**3.12 · Low · `[AGN]` · S4**  
Lighting/shadows: N/A (flat 2D). Particles: unbounded list, short lifetime — OK. API split GLES/Vulkan/Metal: Flame/Impeller, not your code — **no finding**.

**3.13 · Medium · `[AND]` · S4**  
`broskie_app_icon.png` in `assets/images/` is 1024×1024 RGBA **893 KB** and is **not** in `pubspec` assets. Git-only waste. Adaptive icon already has a 432 px drawable.

### Domain 3 notes (what is good)
Splash really preloads (progress is not fake). Procedural fallbacks. Parallax try/catch. Background color matches night token. Impeller/Skia is the abstraction — do not write a rendering API layer.

---

# DOMAIN 4 — Game systems logic

**Score: 4.0 / 10**

Jump assist is the best system in the repo. Combat, input mux, pause, and lifecycle are the worst. On Android the flagship boss mechanic (invert) is a no-op.

### Findings

**4.1 · Critical · `[AND]` · S1**  
`DataBrokerBoss._controlHack` sets `player.controlsInverted`. Only `onKeyEvent` applies it. `TouchControlsOverlay` writes `horizontalDirection = ±1` raw.  
**Root cause:** two input paths, one of them forgot the mux.  
**Fix:** touch calls `setMove(dir)` that applies invert. **Ship-target P0.**

**4.2 · High · `[AND]` · S1**  
Touch jump/dash/vinyl are `onTap` (not down/up). No variable jump on phone. README table says dash is “—” on touch; a Spray button exists.  
**Root cause:** buttons wired as clicks, not holds.  
**Fix:** `onTapDown`/`Up`/`Cancel`; hold-to-float; fix the README.

**4.3 · High · `[AGN]` · S1**  
`onCollisionEnd` sets `isGrounded = false` if **any** floor/block/platform ends. Contact count is a boolean. Standing on floor + leaving a block = one-frame unground, coyote burn, extra gravity.  
**Root cause:** no contact set.  
**Fix:** `groundContacts` increment/decrement.

**4.4 · High · `[AGN]` · S2**  
Successful stomp does **not** grant player i-frames. Next collision frame against a still-overlapping boss is `hit()`. Bounce can turn a punish into revenge damage.  
**Root cause:** stomp and contact share one callback with no lockout.  
**Fix:** 0.2 s i-frames on stomp, or boss i-frames after taking a stomp.

**4.5 · High · `[AGN]` · S2**  
`TheForeman.hitByReflectedBrick()` (called by vinyl) works whenever he is **not** dizzy, and **returns** when he is. The readable rule (stomp the daze) is inverted for the weapon.  
**Root cause:** leftover “reflected brick” name/mechanic.  
**Fix:** vinyl only during dizzy, or a telegraphed weak point. Rename the method.

**4.6 · High · `[AGN]` · S2**  
Both bosses `showBossBar` in `onLoad`. Last writer wins. `updateBossBar` from either clobbers the other.  
**Root cause:** one global bar, two live bosses (2.7).  
**Fix:** sequence bosses, or a dual bar.

**4.7 · High · `[AGN]` · S2**  
`WallStreetBull` is not `Enemy` — vinyl ignores it. `AuditorEnemy` is an immortal damage box (any collision → `player.hit()`). `HaterCloud` has a hitbox and **no** `onCollision`. Slow auras have no radius paint. `DebuffType.lowJump/noDash/invertedControls` are unused; invert is a parallel bool.  
**Root cause:** 1.5 + systems sketched then half-wired.  
**Fix:** one combat interface; delete unused enum values or use them.

**4.8 · High · `[AGN]` · S3**  
`PowerUpType.classic/juggernaut/shockwave` all call the same `grow()`. Shockwave does not shockwave. Shop still deducts when `isBig` (early return).  
**Root cause:** DESIGN promised distinct Volt-Colas; implementation is a size flag + aura color.  
**Fix:** don’t charge on no-op; either unique rules or one item.

**4.9 · High · `[AGN]` · S2**  
`enemiesDefeated` increments on some stomps, not on vinyl cube kills, never resets on `restart()`, not saved. Level-complete “EXECUTIVES DOWN” is a lie.  
**Root cause:** counter bolted onto kill sites inconsistently.  
**Fix:** increment in one `onEnemyKilled()`; reset in `restart()`.

**4.10 · High · `[AGN]` · S1**  
Pause is incomplete. Settings / LevelSelect / Shop / Dialogue / BossCard do **not** pause the engine. Pause menu “BLACK MARKET” does `togglePause()` (resume) then adds Shop — purchases apply to a **live** player.  
**Root cause:** overlays treated as paint, not modes.  
**Fix:** modal stack: overlay on ⇒ `pauseEngine`.

**4.11 · Critical · `[AND]` · S1**  
No `AppLifecycleListener`. Background ≠ pause. Android Back is unhandled (`PopScope` missing) — can kill the Activity mid-run.  
**Root cause:** no OS game-loop policy.  
**Fix:** background → pause menu; Back → pause, not exit.

**4.12 · High · `[AGN]` · S1**  
Dash keeps `velocity.x` on side hits (`if (dashTimer <= 0) velocity.x = 0`). Dash drives through solids. No dash i-frames.  
**Root cause:** dash designed as a speed burst, not a move with collision policy.  
**Fix:** zero `vx` on wall even during dash (unless you explicitly want ghost-dash — then also skip hurtboxes).

**4.13 · Medium · `[DEV]` · S2**  
No keyboard pause (Esc/P). Dialogue says “TAP TO CONTINUE.” Desktop play is second-class.  
**Root cause:** HUD-only chrome.  
**Fix:** Esc = pause; Enter = dismiss dialogue.

**4.14 · Low · `[AGN]` · S4**  
No gamepad, no remapping. Roadmap item. Not a crew-APK blocker.  
**Fix:** S4 if motive says so.

**4.15 · Medium · `[AGN]` · S2**  
Dialogue / boss phase lines / intro card do not pause combat. Foreman can hit you during “AGGRESSIVE RESTRUCTURING.” Card is `IgnorePointer` cinema for 2.4 s.  
**Root cause:** “cinema, not a roadblock” comment — too literal.  
**Fix:** time-stop or i-frames during cards.

**4.16 · Medium · `[AND]` · S3**  
Only permission is `VIBRATE`. Correct. No storage/camera. `allowBackup` is a data issue (Domain 6), not a runtime permission.

**4.17 · Medium · `[AGN]` · S1**  
Laser hitbox stays in the broadphase while inactive. Spikes/lasers have no telegraph. Acceptable if readable; they are thin red rects on busy plates.

**4.18 · High · `[AGN]` · S2**  
`LevelExit.onCollision` can fire `triggerLevelComplete()` every overlap frame until `pauseEngine` sticks. Overlay add can stack.  
**Root cause:** no `consumed` flag.  
**Fix:** latch.

**4.19 · High · `[AGN]` · S2**  
No return-to-title. Victory “PLAY AGAIN” `restart()`s stage 4. Meta-loop soft-locks in the arena.  
**Root cause:** pause menu never grew a “title” action.  
**Fix:** `showMainMenu()` that `pauseEngine`s and rebuilds nothing.

### Domain 4 notes (what is good)
Coyote 100 ms, jump buffer 120 ms, accel/friction, dash + cooldown, 3 HP + 1.5 s i-frames + 3 s spawn grace, power-absorb, vinyl return, Foreman telegraph 0.45 s, Broker volley tell, proxy fake-out, settings actually mutate systems, unlock clamp 1..4 tested.

---

# DOMAIN 5 — UI / UX

**Score: 5.0 / 10**

Splash, living menu, ranks, and working settings are above-prototype. Safe area, orientation chrome, onboarding, design-law compliance, and meta-navigation are below. The visual language is specified in `DESIGN.md` and only partly obeyed.

### Findings

**5.1 · High · `[AND]` · S3**  
HUD is `Positioned(top: 20)` with **no** `SafeArea`. Cutouts clip hearts / pause.  
**Root cause:** desktop-sized overlay.  
**Fix:** `SafeArea` + padding.

**5.2 · High · `[AND]` · S3**  
Launch theme is fullscreen; Flutter does not set immersive sticky. Gesture nav bar covers A/B/Spray (`bottom: 30`). News ticker (`height: 30`, live `ListView`) occupies the same band and can steal hits.  
**Root cause:** ticker + touch both want the bottom edge.  
**Fix:** ticker `IgnorePointer`; raise controls; immersive sticky.

**5.3 · High · `[AND]` · S3**  
`sensorLandscape` is set on the Activity. No `SystemChrome.setPreferredOrientations`. No orientation fallback UI (N/A if lock holds).  
**Fix:** set orientations in Dart too so `[DEV]` matches.

**5.4 · High · `[AGN]` · S2**  
No Return to Title. Level-complete CTA still says “NEXT LEVEL” on stage 4. Victory restarts the arena.  
**Root cause:** 4.19.  
**Fix:** same.

**5.5 · High · `[AND]` · S1**  
Onboarding teaches A/D, Shift, K/Ctrl, J/F. Touch is left/right + Spray/B/A. First-run Android players are lied to.  
**Root cause:** 2.16.  
**Fix:** branch copy on `touchControlsEnabled`.

**5.6 · Medium · `[AGN]` · S4**  
DESIGN law broken in production UI: radius 16–20 (cap is 8); menu/splash **blur** shadows; Material icons on HUD/shop/victory; `Impact` on game-over; `ThemeData.dark()` leak into `SwitchListTile`.  
**Root cause:** kit exists (`broskie_style.dart`) but overlays were built before the kit.  
**Fix:** S4 identity pass — not a playability gate.

**5.7 · Medium · `[AGN]` · S3**  
Settings persist (good). No volume sliders (hardcoded 0.35 / 0.5–0.9). Shake slider exists but shake is invisible (3.2).  
**Root cause:** toggles shipped; mixer didn’t.  
**Fix:** sliders after audio routing is honest.

**5.8 · Medium · `[AGN]` · S3**  
No semantics/tooltips, no text-scale layout, no colorblind palette, no reduce-motion, kill-flash not optional, no remaps, no l10n. Touch targets themselves are ≥56 dp (good).  
**Root cause:** crew-internal audience assumed.  
**Fix:** flash toggle + text-scale clamp if anyone outside the crew plays.

**5.9 · Medium · `[AGN]` · S3**  
Game-over `Stack` is unsized with `Positioned(bottom: 100)` — short landscape can clip “REBOOT SYSTEM.” Dialogue box is a fixed 150 px; stage-4 lore will overflow. Boss bar sits on the HUD row (`Alignment(0,-0.88)`).  
**Root cause:** Center+Stack without constraints.  
**Fix:** full-screen scrim + column.

**5.10 · Low · `[AGN]` · S3**  
Loading: splash progress is real (good). `minDisplay` 2.4 s can feel fake after cache is warm. Acceptable.

**5.11 · Low · `[DEV]` · S2**  
Cursor vs touch: desktop has no visible focus ring; keyboard cannot drive menus.  
**Fix:** with 4.13.

**5.12 · Medium · `[AGN]` · S4**  
Visual language drifts: cyan/amber/magenta tokens exist but `Colors.amber`, `greenAccent`, `redAccent` are used for cash/kills. Vinyl is drawn; HUD still says `CASH: $`.  
**Root cause:** copy older than DESIGN.md.

### Domain 5 notes (what is good)
Branded splash + Ken Burns + true preload; menu sway/rain/stagger; pixel hearts + vinyl glyph; scanline wrap; settings that write systems; stage banners; boss intro card; S-rank gold record; unlock-gated select; pause/restart exist.

---

# DOMAIN 6 — Data protection

**Score: 6.5 / 10** · kept light: single-player, no network, no auth.

Appropriate for a crew sideload. Saves are plaintext prefs with no atomic write and no recovery. Encrypting ranks is not worth the code until you store anything more than bragging.

### Findings

**6.1 · Medium · `[AND]` · S3**  
`SharedPreferences` is a world-readable XML on many Android versions. Unlocks + ranks + settings sit there in the clear. Device lost = progress cloned, not an identity leak.  
**Root cause:** default plugin.  
**Fix:** optional light XOR/obfuscation **only if** you care about spoiling unlocks. Otherwise document it.

**6.2 · Medium · `[AND]` · S3**  
`allowBackup="true"` `fullBackupContent="true"` with **no** backup rules XML. `adb backup` / device transfer clones the save.  
**Root cause:** default manifest.  
**Fix:** `allowBackup=false` for a crew toy, or an `@xml` include list.

**6.3 · Medium · `[AGN]` · S3**  
`savePrefs` is sequential `setBool/setInt`. Process kill mid-write can tear (unlock written, rank not). No temp-file/rename, no backup slot, no checksum.  
**Root cause:** plugin API used as a database.  
**Fix:** one JSON blob + version + write-to-tmp-then-rename if you outgrow prefs. For four ints, accept the risk or write once via `setString('save', json)`.

**6.4 · Medium · `[AGN]` · S3**  
`catch (_) {}` on load/save. Corruption or disk-full = silent defaults / silent data loss. No recovery path.  
**Root cause:** 1.7.  
**Fix:** if parse fails, keep last good in memory and toast “SAVE FAILED.”

**6.5 · Medium · `[AGN]` · S3**  
No schema version. Renaming `unlocked_stage` will silently reset campaigns.  
**Root cause:** 1.12.  
**Fix:** `save_v = 1` now, while it is cheap.

**6.6 · Low · `[AND]` · S3**  
File permission scoping: app-private prefs. Correct. No external storage. No exported `FileProvider`.

**6.7 · Low · `[AGN]` · —**  
No network, no auth, no anti-cheat needed. Do not add any.

---

# DOMAIN 7 — Code quality & maintainability

**Score: 5.5 / 10**

Strict analyzer, lockfile present, a real (narrow) test suite, a no-SDK sweep script, and a gated PowerShell packer. Against that: dead systems, untested P0 physics, no hosted CI, doc/code lies, one-commit history, unused dependency.

### Findings

**7.1 · High · `[AGN]` · S1 / S4**  
Tests cover rank math, boot, restart, fall, advance, checkpoint, boss-gate, prefs clamp, hit-stop, boss bar. They do **not** cover moving platforms, invert, stomp-then-hit, shop debit, dt hitch, lifecycle. The broken systems are the untested ones.  
**Root cause:** tests follow the API that was easy to call headless.  
**Fix:** one test per P0 fix in the same sprint as the fix.

**7.2 · High · `[AGN]` · S4**  
Hosted CI is a paste-me file at `tools/ci_flutter.yml`. No `.github/workflows/`. Draft CI uses floating `stable` and no `--enforce-lockfile` (the packer does).  
**Root cause:** GitHub App cannot push workflows (comment in file).  
**Fix:** paste once; pin SDK.

**7.3 · Medium · `[AGN]` · S4**  
Dead code: `CrumblingPlatform` (unplaced), `triggerParkourVault`, unused `DebuffType`s, unused `broskie_player.png` (preloaded!), unused Riverpod, leftover example Activity.  
**Root cause:** “wired or deleted” rule not enforced.  
**Fix:** delete in S4 unless a motive says keep.

**7.4 · Medium · `[AGN]` · S3**  
`savePrefs()` unawaited at 8 sites; `unawaited_futures` is enabled. Haptics same pattern.  
**Root cause:** 1.15.  
**Fix:** `unawaited(savePrefs())`.

**7.5 · Low · `[AGN]` · S4**  
Import style mixed (`package:broskie_game/...` vs relative in `main.dart`). Naming: `DataBitCoin` is a vinyl; `GrumpyBrick` is a cube; `hitByReflectedBrick` is vinyl.  
**Root cause:** Mario-template ancestry.  
**Fix:** rename when you touch the file.

**7.6 · Medium · `[AGN]` · S4**  
Error handling is copy-paste empty catch. Duplication: stomp predicate copied 5 times with slop 14/16/20/24.  
**Root cause:** no shared combat helper.  
**Fix:** with 1.5.

**7.7 · High · `[AGN]` · S4**  
Flutter is not in this sandbox. Roadmap already lists analyze/test as open. **Do not treat this audit as certification.**  
**Fix:** run the three gates on the pinned SDK before any crew APK.

**7.8 · Low · `[AGN]` · S4**  
Commit hygiene: one squashed feature commit on `main`. Fine. `tools/SYNC_TO_ARENA.ps1` points at **wrong** branch `arena/01a01558-broskie`.  
**Fix:** delete or retarget the helper.

**7.9 · Medium · `[AGN]` · S4**  
Debt tracking is `roadmap.md`, which **contradicts itself** (settings “UI-only” vs “wired”; ranks done and not done; neon loop “serves all stages” vs per-stage themes).  
**Root cause:** checklist updated in two passes.  
**Fix:** Domain 8.

**7.10 · Low · `[AGN]` · —**  
`analysis_options.yaml` is actually strict (`strict-casts/inference/raw-types`, `always_declare_return_types`). `static_sweep.py` is clean as of this audit. Keep both.

**7.11 · Medium · `[AGN]` · S4**  
Reproducibility: lockfile committed (good). Wrapper scripts gitignored (bad for raw Gradle). PowerShell-only packer (bad on Linux CI unless you use the YAML). No flavors/build variants — good, don’t add any.

---

# DOMAIN 8 — Documentation

**Score: 4.5 / 10**

There *is* a README, DESIGN center, architecture tree, and roadmap — more than most slices. They **disagree with the code** on controls, settings, music, SDK, and several mechanics. DESIGN.md’s own law (“a centered design never lies”) is currently violated by the docs.

### Findings

**8.1 · High · `[AGN]` · S4**  
README requires Flutter **3.41 / Dart 3.11**. Lock requires **Flutter ≥3.44 / Dart ≥3.12**. `pubspec.yaml` allows **3.5 / 3.0**.  
**Root cause:** 1.9.  
**Fix:** one number.

**8.2 · High · `[AGN]` · S4**  
Roadmap lies: “toggles are UI-only today” (they are wired); “neon loop currently serves all stages” (`playStageTheme` exists); ranks listed done **and** undone; completed item still says fall-respawn “to stage start.”  
**Root cause:** 7.9.  
**Fix:** rewrite roadmap as Remaining / Done, no duplicates.

**8.3 · High · `[AND]` · S1**  
README control table: touch dash = “—”. Spray dashes. Stage-1 lore is keyboard-only.  
**Root cause:** table not updated when touch dash landed.  
**Fix:** with 4.2 / 5.5.

**8.4 · Medium · `[AGN]` · S4**  
DESIGN promises distinct Volt-Cola identities, `FilterQuality.none`, radius ≤8, no blur shadows, pixel glyphs not Material. Code breaks all of these.  
**Root cause:** design center written after/beside the UI, not enforced.  
**Fix:** either enforce (S4) or amend DESIGN so it describes the build.

**8.5 · Medium · `[AGN]` · S4**  
No LICENSE, no attribution for AI art / Flame / audioplayers, no CHANGELOG, no CONTRIBUTING, no known-issues list (this audit is the first).  
**Root cause:** solo crew project.  
**Fix:** MIT/proprietary one-liner + “AI-generated art, not for resale” if you share the APK wider.

**8.6 · Medium · `[AND]` · S4**  
Build instructions: PowerShell packer, Windows-shaped. No macOS/Linux commands beyond `flutter run`. Default script target is `bundle` (needs keystore) while README sells `apk`.  
**Root cause:** author environment ≠ crew narrative.  
**Fix:** default `-Target apk`; add a 4-line bash snippet.

**8.7 · Low · `[AGN]` · S4**  
Architecture diagram includes `CrumblingPlatform` (unplaced). In-code API docs are occasional good comments plus stale ones (`onPlayerFell` “stage start”; laser “every 2 seconds” vs 2-on/1-off).  
**Fix:** comment pass with the files you touch.

**8.8 · Medium · `[AGN]` · S2**  
Player-facing copy lies: “EXECUTIVES DOWN” counts cubes; Broker “clones” teleport; Auditor “ice spike” is an aura; NEW RUN isn’t.  
**Fix:** rename strings when the system is fixed.

**8.9 · Low · `[AGN]` · —**  
README run/test commands are correct **if** Flutter is installed. Honest about no Play Store. Honest about no accounts. Keep that tone.

---

# Scores

| Domain | /10 | Weight | Weighted |
| --- | ---: | ---: | ---: |
| 1 Architecture | 5.0 | 12 | 6.0 |
| 2 Gameplay / world | 4.0 | 20 | 8.0 |
| 3 Rendering / perf | 4.5 | 12 | 5.4 |
| 4 Game systems | 4.0 | 20 | 8.0 |
| 5 UI / UX | 5.0 | 12 | 6.0 |
| 6 Data protection | 6.5 | 4 | 2.6 |
| 7 Code quality | 5.5 | 12 | 6.6 |
| 8 Documentation | 4.5 | 8 | 3.6 |
| **Overall** | | **100** | **46.2 / 100** |

Domain 6 is weighted low on purpose (offline, no auth). The score is a **playable-on-phone** score, not a “does a prototype exist” score. Stage 1 + menus would score higher; the compact campaign as advertised would not.

---

# Top 10 priority fixes

Ranked by **severity × inverse effort** (biggest playability return first).

| # | Fix | Sev | Effort | Platform | Step |
| --- | --- | --- | --- | --- | --- |
| 1 | Moving platforms carry the rider + test | Critical | M | `[AGN]` | S1 |
| 2 | One fall = one heart (pit + abyss latch) | Critical | S | `[AGN]` | S1 |
| 3 | Touch uses the same input mux (invert + hold jump) | Critical | S | `[AND]` | S1 |
| 4 | Modal pause: Settings/Shop/Select/Dialogue + lifecycle + Back | Critical | M | `[AND]` | S1 |
| 5 | `dt` clamp + terminal `vy` | High | S | `[AGN]` | S1 |
| 6 | Stomp i-frames; vinyl only on dizzy Foreman | High | S | `[AGN]` | S2 |
| 7 | Sequence Stage 4 / dual bar; latch exit | High | M | `[AGN]` | S2 |
| 8 | Shake **after** follow; camera world bounds | High | S | `[AGN]` | S2 |
| 9 | Return to title + honest NEW RUN + reset kill counter | High | S | `[AGN]` | S2 |
| 10 | Persist cash (or stop surviving death); don’t charge failed shop buys | High | S | `[AGN]` | S3 |

Do **not** add stages, tilesets, Lord Static, Riverpod, or iOS until 1–5 are in.

---

# Sprint roadmap

Each sprint is one crew-APK-sized bite. **No code until Sprint 1 MCQs are answered.**

### Sprint 1 — “The ferry moves Broskie”

**Goal:** a phone player can finish stages 1–3 without fighting the engine.  
**Finds:** 2.1, 2.2, 2.3, 2.4, 2.16, 3.1, 3.9, 4.1, 4.2, 4.3, 4.10, 4.11, 4.12, 5.5, 8.3  
**Exit:** Flame tests for rider-carry, pit-single-tax, invert-on-touch (logic), dt clamp. Stage-1 lore matches touch. Backgrounding opens pause.  
**Out of scope:** new art, new stages, design-kit cosmetics.

### Sprint 2 — “Bosses tell the truth”

**Goal:** combat and camera match what the UI claims.  
**Finds:** 2.7, 2.10, 2.12, 3.2, 4.4, 4.5, 4.6, 4.9, 4.13, 4.15, 4.18, 4.19, 5.4, 8.8  
**Exit:** no stomp-revenge hit; Foreman vinyl policy is the readable one; one boss at a time or a dual bar; shake visible; title return; `stageTime` only while playing.

### Sprint 3 — “Crew APK chrome”

**Goal:** the thing you hand to the group chat behaves like a phone game.  
**Finds:** 3.4, 3.10, 4.8, 5.1, 5.2, 5.3, 5.7, 5.9, 6.2–6.5, 2.11  
**Exit:** SafeArea + immersive + ticker ignores pointers; cash policy implemented; shop doesn’t steal money; save has a version key; music-on resumes **stage** theme ( Dom 5 leftover / audio routing ).

### Sprint 4 — “Stop lying, then polish”

**Goal:** repo health + DESIGN identity.  
**Finds:** Domain 1 leftovers, 2.5–2.6, 3.3, 3.6, 5.6, 7.2–7.3, Domain 8  
**Exit:** one SDK pin; hosted or at least documented CI; dead code gone; README/roadmap/DESIGN agree; optional identity pass (radius/blur/icons).

---

# MCQ follow-ups (motives)

Answer these **before any code**. Sprint 1’s five are also in the Arena question widget. Later sprints reuse this list when we get there.

## Sprint 1 — why this game exists, and what “playable” means

**S1-Q1.** What is Broskie *for* right now?  
A. A crew toy — sideload APKs to friends, no store  
B. A portfolio vertical slice — it has to *look* finished on video  
C. A real release path (Play later)  
D. A learning project — process matters more than the APK  

**S1-Q2.** Stages 2–3 are built around moving platforms that do not carry the player. Prefer:  
A. Fix the rider physics even if it eats the sprint  
B. Flatten/simplify those gaps so the stages play without ferries  
C. Cut 2–3 from the campaign for now (1 + 4 boss rush)  
D. Keep the jank — only stop softlocks / crashes  

**S1-Q3.** Input philosophy for the shipped APK:  
A. Touch-first. Keyboard is debug only  
B. Touch and keyboard are both first-class  
C. Add gamepad in the near term too  
D. I mostly play on desktop; Android is secondary  

**S1-Q4.** When DESIGN/README and the build disagree:  
A. Change **code** to match DESIGN.md (strict)  
B. Change **docs** to match what’s fun in the build  
C. Ask me on each lie  
D. DESIGN is sacred — delete non-conforming features  

**S1-Q5.** Difficulty / honesty:  
A. Fair arcade — telegraphs, no double-hits, no silent cheese  
B. Street jank is the vibe — only fix unwinnable states  
C. Keep vinyl-Foreman cheese if we label it  
D. Make it easier so the crew *finishes* it  

## Sprint 2 — combat and the story the systems tell

**S2-Q1.** The Foreman fight should be:  
A. Wall-crash → stomp only (vinyl off except dizzy)  
B. Vinyl always works — it’s a shooter-platformer  
C. Vinyl works but at reduced damage  
D. I don’t care; pick the readable one  

**S2-Q2.** Stage 4 dual bosses:  
A. Sequence them (Foreman, then Broker)  
B. Keep both live; fix the HUD to a dual bar  
C. Separate arenas with a door  
D. Drop one boss; four stages is already long  

**S2-Q3.** NEW RUN should:  
A. Wipe session cash + start stage 1; keep unlocks  
B. Full erase (unlocks, ranks, cash)  
C. Just warp to stage 1 (current behavior), rename the button  
D. Ask “are you sure?” with both options  

**S2-Q4.** Rank timer should exclude:  
A. Dialogue, banners, and cards  
B. Everything except raw movement  
C. Don’t care about ranks; de-emphasize them  
D. Keep it raw `dt` — speedrunners pause-buffer anyway  

**S2-Q5.** Return-to-title is:  
A. Mandatory on pause + victory  
B. Pause only  
C. Don’t bother — they can force-close  
D. Victory goes to a credits/end card first  

## Sprint 3 — the APK in someone’s hand

**S3-Q1.** Cash / Black Market:  
A. Persist cash; shop is real progression  
B. Session-only cash; reset on death  
C. Cut the shop; mystery block is enough  
D. Expand the shop (more items) after it works  

**S3-Q2.** Audio investment:  
A. Fix routing (resume correct theme, precache, pause duck) and stop  
B. Also convert to OGG / one sample rate  
C. I want real composed music later; keep chiptunes as placeholders  
D. Mute-toggles are enough, don’t spend sprint time  

**S3-Q3.** Phone chrome (notch, nav bar, back, sleep):  
A. Must feel like a shipped Android game  
B. Good enough if it doesn’t eat the A button  
C. Crew knows the quirks  
D. I test on an emulator / desktop only  

**S3-Q4.** Save privacy for a crew build:  
A. `allowBackup=false`, move on  
B. Leave backup on, add a save version + crash-safe blob  
C. Light-obfuscate unlocks so friends can’t edit XML  
D. Don’t touch saves unless they’re corrupting  

**S3-Q5.** Who is the next APK for?  
A. The same group chat  
B. Strangers on the internet (itch / Drive link)  
C. A store listing later this year  
D. Just me  

## Sprint 4 — identity vs debt

**S4-Q1.** After the game is completable, spend the next week on:  
A. DESIGN.md enforcement (palette, radius, no blur, pixel glyphs)  
B. New content (tileset, hurt/jump frames, extra stage)  
C. Repo hygiene (CI, SDK pin, dead code, LICENSE)  
D. Split across A/B/C, you choose the order  

**S4-Q2.** AI art plates that don’t match collision:  
A. Darken/crop so nobody jumps at painted ledges  
B. Author a real tileset from the plates  
C. Live with it — gloom scrim is enough  
D. Regenerate plates to match the rectangles  

**S4-Q3.** Riverpod and other costumes:  
A. Delete unused deps without asking  
B. Ask before deleting anything  
C. Actually adopt Riverpod for settings/save  
D. I want a bigger rewrite (ECS / another engine) — talk to me first  

**S4-Q4.** Second platform:  
A. Android only, indefinitely  
B. Desktop window as a first-class play target  
C. iOS after Android feels good  
D. Web demo for sharing  

**S4-Q5.** Scope lock:  
A. Freeze features; only fix + polish the four stages  
B. One more thing after polish (bull arena / Lord Static / Deep Web)  
C. Keep the roadmap open; I’ll pick  
D. Shrink to a single-stage vertical slice and make *that* perfect  

---

## What I will not do until you answer Sprint 1

- Touch `lib/`, `android/`, tests, or assets  
- “Helpfully” flatten stages 2–3  
- Enforce DESIGN.md cosmetics before the ferry works  
- Add CI/iOS/Riverpod/content  

Next action after S1 answers: implement **only** Sprint 1, with a test per P0 fix.
