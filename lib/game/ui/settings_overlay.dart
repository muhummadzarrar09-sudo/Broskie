import 'package:broskie_game/game/audio_manager.dart';
import 'package:broskie_game/game/broskie_game.dart';
import 'package:broskie_game/game/ui/broskie_style.dart';
import 'package:flutter/material.dart';

class SettingsOverlay extends StatelessWidget {
  final BroskieGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 340,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        padding: const EdgeInsets.all(20),
        decoration: broskiePanel(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SETTINGS', style: broskieHeadline()),
                  GestureDetector(
                    onTap: () {
                      BroskieAudio.playUiClick();
                      game.dismissOverlay('Settings');
                    },
                    child: const Icon(Icons.close,
                        color: BroskieColors.bone, size: 22),
                  ),
                ],
              ),
              const Divider(color: Color(0x33F2E6D4), height: 20),
              _switch('SOUND FX', game.sfxEnabled, (v) {
                game.sfxEnabled.value = v;
                BroskieAudio.setSfx(v);
                game.savePrefs();
              }),
              ValueListenableBuilder<double>(
                valueListenable: game.sfxVolume,
                builder: (context, vol, _) => _slider('FX LEVEL', vol, (v) {
                  game.sfxVolume.value = v;
                  BroskieAudio.setSfxVolume(v);
                  game.savePrefs();
                }),
              ),
              _switch('MUSIC', game.musicEnabled, (v) {
                game.musicEnabled.value = v;
                BroskieAudio.setMusicEnabled(v);
                game.savePrefs();
              }),
              ValueListenableBuilder<double>(
                valueListenable: game.musicVolume,
                builder: (context, vol, _) => _slider('MUSIC LEVEL', vol, (v) {
                  game.musicVolume.value = v;
                  BroskieAudio.setMusicVolume(v);
                  game.savePrefs();
                }),
              ),
              _switch('TOUCH CONTROLS', game.touchControlsEnabled, (v) {
                game.touchControlsEnabled.value = v;
                game.savePrefs();
              }),
              _switch('HAPTICS', game.hapticsEnabled, (v) {
                game.hapticsEnabled.value = v;
                game.savePrefs();
              }),
              ValueListenableBuilder<double>(
                valueListenable: game.shakeScale,
                builder: (context, scale, _) =>
                    _slider('SCREEN SHAKE', scale, (v) {
                  game.shakeScale.value = v;
                  game.savePrefs();
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BroskieColors.amber,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () {
                    BroskieAudio.playUiClick();
                    game.dismissOverlay('Settings');
                  },
                  child: const Text('CLOSE',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switch(String label, ValueNotifier<bool> n, ValueChanged<bool> on) {
    return ValueListenableBuilder<bool>(
      valueListenable: n,
      builder: (context, onVal, _) => SwitchListTile(
        activeThumbColor: BroskieColors.amber,
        contentPadding: EdgeInsets.zero,
        title: Text(label,
            style: const TextStyle(
                color: BroskieColors.bone,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1)),
        value: onVal,
        onChanged: on,
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> on) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: BroskieColors.bone, fontFamily: 'monospace')),
            Text('${(value * 100).toInt()}%',
                style: const TextStyle(
                    color: BroskieColors.amber, fontFamily: 'monospace')),
          ],
        ),
        Slider(
          activeColor: BroskieColors.amber,
          inactiveColor: const Color(0x33F2E6D4),
          value: value,
          min: 0,
          max: 1,
          divisions: 10,
          onChanged: on,
        ),
      ],
    );
  }
}
