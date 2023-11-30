import 'package:wallet_core/core.dart';

int _kMaxAttempts = 9;
int _kAttemptsBeforeTimeout = 3;

class PinManager {
  String? _selectedPin;
  int _attempts = 0;

  bool get isRegistered => _selectedPin != null;

  void setPin(String pin) {
    if (isRegistered) throw StateError('Pin already configured');
    _selectedPin = pin;
  }

  WalletInstructionResult checkPin(String pin) {
    if (!isRegistered) throw StateError('Cannot unlock before registration');
    // We've already reached our max attempts, notify blocked.
    if (_attempts >= _kMaxAttempts) return WalletInstructionResult.blocked();

    // Pin matches, grant access and reset state
    if (pin == _selectedPin) {
      _attempts = 0;
      return WalletInstructionResult.ok();
    }

    // Increase the nr of attempts and figure out the new state
    _attempts++;
    // Max attempts reached, block the app
    if (_attempts >= _kMaxAttempts) return WalletInstructionResult.blocked();
    // Intermediate timeout, report as such
    if (_attempts % _kAttemptsBeforeTimeout == 0) {
      return WalletInstructionResult.timeout(timeoutMillis: Duration(seconds: _attempts * 2).inMilliseconds);
    }
    // No timeout, not yet blocked, notify about the attempts left
    return WalletInstructionResult.incorrectPin(
      leftoverAttempts: _kAttemptsBeforeTimeout - (_attempts % _kAttemptsBeforeTimeout),
      isFinalAttempt: _attempts == (_kMaxAttempts - 1),
    );
  }

  Future<void> resetPin() async {
    _attempts = 0;
    _selectedPin = null;
  }
}
