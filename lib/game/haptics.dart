import 'package:flutter/services.dart';

/// One telephone line to the thumbs. Every call is wrapped so haptics
/// can never crash a web/test/desktop build.
class BroskieHaptics {
  static void light() => _safe(HapticFeedback.lightImpact);
  static void medium() => _safe(HapticFeedback.mediumImpact);
  static void heavy() => _safe(HapticFeedback.heavyImpact);

  static void _safe(Future<void> Function() fn) {
    try {
      // ignore: discarded_futures
      fn();
    } catch (_) {}
  }
}
