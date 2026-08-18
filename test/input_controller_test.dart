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

    test('buffers jump and dash requests exactly once', () {
      final input = InputController();

      expect(input.takeJump(), isFalse);
      expect(input.takeDash(), isFalse);
      input
        ..queueJump()
        ..queueDash();
      expect(input.takeJump(), isTrue);
      expect(input.takeJump(), isFalse);
      expect(input.takeDash(), isTrue);
      expect(input.takeDash(), isFalse);
    });

    test('reset releases every held input', () {
      final input = InputController();
      input
        ..setKeyboard(left: true, right: false, running: true)
        ..setTouchRight(true)
        ..queueJump()
        ..queueDash()
        ..reset();

      expect(input.horizontalDirection, 0);
      expect(input.isRunning, isFalse);
      expect(input.takeJump(), isFalse);
      expect(input.takeDash(), isFalse);
    });
  });
}
