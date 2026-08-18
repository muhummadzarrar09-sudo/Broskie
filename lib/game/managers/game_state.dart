import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Game Cash Provider
final gameCashProvider = AsyncNotifierProvider<GameCashNotifier, int>(GameCashNotifier.new);

class GameCashNotifier extends AsyncNotifier<int> {
  static const _key = 'broskie_cash';

  @override
  Future<int> build() async {
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

// Game Progression Provider
final gameProgressionProvider = AsyncNotifierProvider<GameProgressionNotifier, int>(GameProgressionNotifier.new);

class GameProgressionNotifier extends AsyncNotifier<int> {
  static const _key = 'broskie_level';

  @override
  Future<int> build() async {
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
