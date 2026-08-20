import 'dart:async';

import 'package:flutter/foundation.dart';

import 'wallet_connect_service.dart';

/// Simple manager that maintains an in-memory list of WalletConnect v1 session-like entries
/// based on events emitted from the concrete WalletConnectService implementation.
///
/// This is intentionally lightweight: it records session metadata when a 'connect' event
/// is observed from WalletConnectV1Impl and allows simple revocation by calling disconnect()
/// on the underlying service. For a production-ready implementation persist sessions and
/// surface more metadata from the WalletConnect client's session store.
class WalletConnectManager {
  final WalletConnectService _service;
  final List<Map<String, dynamic>> _sessions = [];
  final StreamController<List<Map<String, dynamic>>> _sessionsController = StreamController.broadcast();
  StreamSubscription? _sub;

  WalletConnectManager(this._service);

  Future<void> init() async {
    await _service.init();
    // listen to session-related events and populate sessions list
    _sub = _service.onSessionRequest.listen((event) {
      try {
        if (event is Map && event['type'] == 'connect') {
          final payload = event['payload'];
          final id = payload is Map ? (payload['handshakeId'] ?? DateTime.now().toIso8601String()) : DateTime.now().toIso8601String();
          final meta = {
            'id': id,
            'raw': payload,
            'createdAt': DateTime.now().toIso8601String(),
          };
          _sessions.add(meta);
          _sessionsController.add(List.unmodifiable(_sessions));
        } else if (event is Map && event['type'] == 'disconnect') {
          // best effort remove by handshakeId if present
          final payload = event['payload'];
          if (payload is Map && payload['handshakeId'] != null) {
            _sessions.removeWhere((s) => s['id'] == payload['handshakeId']);
            _sessionsController.add(List.unmodifiable(_sessions));
          }
        }
      } catch (e) {
        // ignore
      }
    });
  }

  Stream<List<Map<String, dynamic>>> get sessionsStream => _sessionsController.stream;

  List<Map<String, dynamic>> get sessions => List.unmodifiable(_sessions);

  Future<void> dispose() async {
    await _sub?.cancel();
    await _sessionsController.close();
  }

  /// Revoke a session. This implementation will call disconnect on the underlying service
  /// which typically kills the active session (for v1). For v2 more detailed session
  /// revocation may be necessary.
  Future<void> revokeSession(String id) async {
    // Attempt to kill session via WalletConnectService
    await _service.disconnect();
    _sessions.removeWhere((s) => s['id'] == id);
    _sessionsController.add(List.unmodifiable(_sessions));
  }
}
