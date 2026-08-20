import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// RpcWsClient provides a lightweight WebSocket JSON-RPC client for subscriptions.
class RpcWsClient {
  final Uri uri;
  WebSocketChannel? _channel;
  int _id = 1;
  final StreamController<Map<String, dynamic>> _messages = StreamController.broadcast();

  RpcWsClient(String wsUrl) : uri = Uri.parse(wsUrl);

  Stream<Map<String, dynamic>> get messages => _messages.stream;

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(uri);
    _channel!.stream.listen((event) {
      try {
        final parsed = jsonDecode(event as String) as Map<String, dynamic>;
        _messages.add(parsed);
      } catch (e) {
        // ignore
      }
    }, onError: (e) {
      _messages.addError(e);
    }, onDone: () {
      _messages.close();
    });
  }

  Future<int> subscribe(String method, [List params = const []]) async {
    if (_channel == null) throw Exception('WS not connected');
    final id = _id++;
    final payload = jsonEncode({'jsonrpc': '2.0', 'id': id, 'method': method, 'params': params});
    _channel!.sink.add(payload);
    return id;
  }

  Future<void> close() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
