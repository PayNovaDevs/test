import 'package:flutter_test/flutter_test.dart';

import 'package:dex_wallet/core/dapps/wallet_connect_service.dart';
import 'package:dex_wallet/core/dapps/wallet_connect_v1_impl.dart';

void main() {
  test('WalletConnect v1 init does not throw', () async {
    final svc = WalletConnectV1Impl();
    await svc.init();
    expect(svc.onSessionRequest, isNotNull);
  });

  test('WalletConnect v2 placeholder init with no project id does not throw', () async {
    final svc = WalletConnectV2Impl();
    await svc.init();
    expect(svc.onSessionRequest, isNotNull);
  });
}
