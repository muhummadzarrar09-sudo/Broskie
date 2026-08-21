# Changelog

## Unreleased

- Boot flow redesign: splash keyart IS the loader (push-in settle, chromatic
  glitch frames, groove bar), title is the rooftop keyart with a slow drift
  and a kit control deck, load card rides the stage accent with pixel-heart
  lives and the Foreman bleeding through on the arena card
- Test rig green: audio never pokes the platform channel before init
  (async MissingPluginException escaped every try/catch), and the stage-4
  lock test now pumps Flame's queued add lifecycle + the exit's 0.2s poll

## 0.4.0 — crew APK

- Android-only, touch-first, Mario-shaped camera (street in the lower third)
- Easy / Normal / Hard
- Moving platforms carry the rider; one fall = one heart
- WORLD 1-N load cards and BROSKIE × N death wipe
- Sequenced stage-4 bosses
- NEW RUN wipes vinyls; wallet persists
- Immersive landscape, volume sliders, attract-mode title
- Dead Riverpod / vault / crumbling platform removed

## 0.3.0

Prototype vertical slice (Flutter + Flame) before the playable pass.
