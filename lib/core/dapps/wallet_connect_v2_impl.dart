import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'wallet_connect_service.dart';

/// WalletConnect v2 integration placeholder using walletconnect_flutter_v2.
/// This implementation reads WC_PROJECT_ID from environment and will initialize the client
/// if available. For full functionality provide WC_PROJECT_ID in your .env or environment.
class WalletConnectV2Impl implements WalletConnectService {
  final String? projectId;
  StreamController<dynamic> _sessionRequests = StreamController.broadcast();

  WalletConnectV2Impl({this.projectId});

  @override
  Future<void> init() async {
    // If no project id provided, we keep the service in a not-ready state. The UI should detect this and warn the user.
    final pid = projectId ?? dotenv.env['WC_PROJECT_ID'];
    if (pid == null || pid.isEmpty) {
      // Not ready to initialize v2
      return;
    }
    // Initialize v2 client from package here. Example pseudocode (replace with actual library calls):
    // final client = WalletConnectV2(projectId: pid, metadata: ...);
    // client.onSessionProposal((p) => _sessionRequests.add({'type':'proposal', 'payload':p}));

    // For now we only expose the stream; concrete implementation should be added in a follow-up if desired.
  }

  @override
  Future<String> connect() async {
    throw UnimplementedError('WalletConnect v2 connect not implemented in this placeholder. Provide a project id and bind a v2 client implementation.');
  }

  @override
  Future<void> disconnect() async {
    // implement v2 disconnect
    return;
  }

  @override
  Stream get onSessionRequest => _sessionRequests.stream;

  @override
  Future<String> signMessage({required String message, required String address}) async {
    throw UnimplementedError('v2 signMessage not implemented in placeholder');
  }

  @override
  Future<String> signTransaction({required Map<String, dynamic> tx, required String address}) async {
    throw UnimplementedError('v2 signTransaction not implemented in placeholder');
  }
}
