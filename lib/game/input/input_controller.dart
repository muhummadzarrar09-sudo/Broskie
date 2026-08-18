/// Combines keyboard and touch input without letting one source clobber the
/// other. Jump requests are buffered until the player consumes them.
class InputController {
  bool _keyboardLeft = false;
  bool _keyboardRight = false;
  bool _touchLeft = false;
  bool _touchRight = false;
  bool _running = false;
  bool _jumpQueued = false;
  bool _dashQueued = false;

  int get horizontalDirection {
    final left = _keyboardLeft || _touchLeft;
    final right = _keyboardRight || _touchRight;
    if (left == right) {
      return 0;
    }
    return left ? -1 : 1;
  }

  bool get isRunning => _running;

  void setKeyboard({
    required bool left,
    required bool right,
    required bool running,
  }) {
    _keyboardLeft = left;
    _keyboardRight = right;
    _running = running;
  }

  void setTouchLeft(bool pressed) => _touchLeft = pressed;

  void setTouchRight(bool pressed) => _touchRight = pressed;

  void queueJump() => _jumpQueued = true;

  bool takeJump() {
    final queued = _jumpQueued;
    _jumpQueued = false;
    return queued;
  }

  void queueDash() => _dashQueued = true;

  bool takeDash() {
    final queued = _dashQueued;
    _dashQueued = false;
    return queued;
  }

  void reset() {
    _keyboardLeft = false;
    _keyboardRight = false;
    _touchLeft = false;
    _touchRight = false;
    _running = false;
    _jumpQueued = false;
    _dashQueued = false;
  }
}
