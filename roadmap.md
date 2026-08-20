# Broskie roadmap

Only things that are **not** in the build stay open.

## Done

- Four-stage campaign, ranks, checkpoints, boss-gated exit
- Touch-first Android controls, hold-A jump, invert on thumbs
- Mario camera, WORLD cards, lives wipe
- Easy / Normal / Hard
- Sequenced Foreman → Data-Broker
- Settings that write the mixer, wallet persist, NEW RUN wipe
- Immersive landscape crew APK path (`./build_broskie.ps1 -Target apk`)

## Remaining (needs a Flutter machine / a phone)

- [ ] `flutter analyze` + `flutter test` + `flutter build apk --debug` on Flutter **3.44+**
- [ ] Physical-device playtest (notch + gesture nav)
- [ ] Optional: compress stage themes to OGG (WAVs work; they are fat)
- [ ] Optional: hosted GitHub Actions (paste `tools/ci_flutter.yml` — App cannot push workflows)

## Not started, not pretending

Lord Static, Deep Web, ghost runs, iOS, Play Store signing.
