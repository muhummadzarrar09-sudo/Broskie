import 'package:broskie_game/game/input/input_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputController', () {
    test('combines keyboard and touch without clobbering either source', () {
      final input = InputController();

      input.setKeyboard(left: true, right: false, running: true);
      expect(input.horizontalDirection, -1);
      expect(input.isRunning, isTrue);

      input.setTouchRight(true);
      expect(input.horizontalDirection, 0);

      input.setKeyboard(left: false, right: false, running: false);
      expect(input.horizontalDirection, 1);
    });

    test('buffers each jump request exactly once', () {
      final input = InputController();

      expect(input.takeJump(), isFalse);
      input.queueJump();
      expect(input.takeJump(), isTrue);
      expect(input.takeJump(), isFalse);
    });

    test('reset releases every held input', () {
      final input = InputController();
      input
        ..setKeyboard(left: true, right: false, running: true)
        ..setTouchRight(true)
        ..queueJump()
        ..reset();

      expect(input.horizontalDirection, 0);
      expect(input.isRunning, isFalse);
      expect(input.takeJump(), isFalse);
    });
  });
}
