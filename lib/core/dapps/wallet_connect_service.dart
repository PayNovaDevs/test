/// WalletConnect service interfaces and adapters.
///
/// NOTE: This module provides a generic interface for WalletConnect v1 and v2. Implementations
/// should bind to concrete WalletConnect Dart packages. For v2 (recommended) you'll typically need
/// a ProjectID (relay / project credentials). Put the ProjectID in your environment (see README.md)
/// under the variable WC_PROJECT_ID. The app will load it at runtime and pass it to the v2 client.

import 'dart:async';

abstract class WalletConnectService {
  Future<void> init();
  Future<String> connect(); // returns uri for pairing (deep link)
  Future<void> disconnect();
  Stream<dynamic> get onSessionRequest;
  Future<String> signMessage({required String message, required String address});
  Future<String> signTransaction({required Map<String, dynamic> tx, required String address});
}

/// Placeholder implementations below provide the wiring points. You must add a concrete
/// implementation using a WalletConnect Dart package and inject it in your app providers.

class WalletConnectV1Service implements WalletConnectService {
  // Implement platform-specific WalletConnect v1 client here (e.g. using 'walletconnect_dart').
  // This placeholder throws to indicate not bound.

  @override
  Future<void> init() async {
    // initialize client
    return;
  }

  @override
  Future<String> connect() async {
    throw UnimplementedError('WalletConnectV1Service is not implemented. Add a concrete implementation using walletconnect_dart and wire it in providers.');
  }

  @override
  Future<void> disconnect() async {
    throw UnimplementedError('WalletConnectV1Service is not implemented.');
  }

  @override
  Stream get onSessionRequest => Stream.empty();

  @override
  Future<String> signMessage({required String message, required String address}) async {
    throw UnimplementedError('WalletConnectV1Service signMessage not implemented.');
  }

  @override
  Future<String> signTransaction({required Map<String, dynamic> tx, required String address}) async {
    throw UnimplementedError('WalletConnectV1Service signTransaction not implemented.');
  }
}

class WalletConnectV2Service implements WalletConnectService {
  final String? projectId;

  WalletConnectV2Service({this.projectId});

  @override
  Future<void> init() async {
    // v2 initialization requires a ProjectID (relay). Documented in README.
    if (projectId == null || projectId!.isEmpty) {
      // still allow initialization but connecting will fail until ProjectID provided via env or settings
      return;
    }
    // Initialize v2 client here using your preferred package and the provided projectId
  }

  @override
  Future<String> connect() async {
    throw UnimplementedError('WalletConnectV2Service is not implemented. Add concrete v2 client and pass projectId from config.');
  }

  @override
  Future<void> disconnect() async {
    throw UnimplementedError('WalletConnectV2Service.disconnect not implemented.');
  }

  @override
  Stream get onSessionRequest => Stream.empty();

  @override
  Future<String> signMessage({required String message, required String address}) async {
    throw UnimplementedError('WalletConnectV2Service signMessage not implemented.');
  }

  @override
  Future<String> signTransaction({required Map<String, dynamic> tx, required String address}) async {
    throw UnimplementedError('WalletConnectV2Service signTransaction not implemented.');
  }
}
