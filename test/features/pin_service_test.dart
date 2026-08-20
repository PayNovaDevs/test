import 'package:flutter_test/flutter_test.dart';
import 'package:dex_wallet/core/security/pin_service.dart';
import 'package:dex_wallet/core/security/secure_storage_service.dart';

void main() {
  test('PinService set and verify', () async {
    final storage = SecureStorageService();
    final pinService = PinService(storage);

    // Note: This test writes to real secure storage on device/emulator. In CI/mock use a fake storage implementation.
    await pinService.clearPin();
    await pinService.setPin('123456');
    final ok = await pinService.verifyPin('123456');
    expect(ok, true);
    final bad = await pinService.verifyPin('000000');
    expect(bad, false);
    await pinService.clearPin();
  }, timeout: Timeout.none);
}
