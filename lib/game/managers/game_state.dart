import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'game_state.g.dart';

@Riverpod(keepAlive: true)
class GameCash extends _$GameCash {
  static const _key = 'broskie_cash';
  
  @override
  FutureOr<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> addCash(int amount) async {
    final current = state.value ?? 0;
    final newValue = current + amount;
    state = AsyncData(newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, newValue);
  }

  Future<bool> spendCash(int amount) async {
    final current = state.value ?? 0;
    if (current >= amount) {
      final newValue = current - amount;
      state = AsyncData(newValue);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, newValue);
      return true;
    }
    return false;
  }
}

@Riverpod(keepAlive: true)
class GameProgression extends _$GameProgression {
  static const _key = 'broskie_level';
  
  @override
  FutureOr<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 1;
  }

  Future<void> unlockLevel(int level) async {
    final current = state.value ?? 1;
    if (level > current) {
      state = AsyncData(level);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, level);
    }
  }
}
