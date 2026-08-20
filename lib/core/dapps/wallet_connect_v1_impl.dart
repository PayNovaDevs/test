import 'dart:async';

import 'package:walletconnect_dart/walletconnect_dart.dart' as wc;
import 'package:url_launcher/url_launcher.dart';

import 'wallet_connect_service.dart';

/// Concrete WalletConnect v1 implementation using walletconnect_dart.
class WalletConnectV1Impl implements WalletConnectService {
  wc.WalletConnect? _connector;
  StreamController<dynamic> _sessionRequests = StreamController.broadcast();

  WalletConnectV1Impl();

  @override
  Future<void> init() async {
    _connector = wc.WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const wc.FullClientMeta(name: 'dex wallet', description: 'NOVA Wallet', url: 'https://example.com', icons: ['https://example.com/icon.png']),
    );

    _connector!.on('connect', (sess) {
      _sessionRequests.add({'type': 'connect', 'payload': sess});
    });
    _connector!.on('session_update', (payload) {
      _sessionRequests.add({'type': 'session_update', 'payload': payload});
    });
    _connector!.on('disconnect', (payload) {
      _sessionRequests.add({'type': 'disconnect', 'payload': payload});
    });
  }

  @override
  Future<String> connect() async {
    if (_connector == null) await init();
    if (!_connector!.connected) {
      final session = await _connector!.createSession(onDisplayUri: (uri) async {
        // Open the uri in external wallet
        if (await canLaunch(uri)) {
          await launch(uri);
        }
      });
      return session.toString();
    }
    return 'already_connected';
  }

  @override
  Future<void> disconnect() async {
    await _connector?.killSession();
  }

  @override
  Stream get onSessionRequest => _sessionRequests.stream;

  @override
  Future<String> signMessage({required String message, required String address}) async {
    if (_connector == null) throw Exception('WalletConnect not initialized');
    final hexMessage = '0x' + Uri.encodeComponent(message);
    final result = await _connector!.signPersonalMessage(message: hexMessage, address: address);
    return result;
  }

  @override
  Future<String> signTransaction({required Map<String, dynamic> tx, required String address}) async {
    if (_connector == null) throw Exception('WalletConnect not initialized');
    final res = await _connector!.sendCustomRequest(method: 'eth_sendTransaction', params: [tx]);
    return res.toString();
  }
}
