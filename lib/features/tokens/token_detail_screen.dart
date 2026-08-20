import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../../features/networks/networks_service.dart';

class TokenDetailScreen extends StatefulWidget {
  final String tokenAddress;
  final String accountAddress;
  const TokenDetailScreen({Key? key, required this.tokenAddress, required this.accountAddress}) : super(key: key);

  @override
  State<TokenDetailScreen> createState() => _TokenDetailScreenState();
}

class _TokenDetailScreenState extends State<TokenDetailScreen> {
  String? _name;
  String? _symbol;
  int? _decimals;
  BigInt? _balance;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final ns = NetworksService();
      final net = ns.networks.first;
      if (net.rpcUrl.isEmpty) throw Exception('No RPC configured for network ${net.name}');
      final client = Web3Client(net.rpcUrl, Client());
      final contract = DeployedContract(ContractAbi.fromJson(_erc20Abi, 'ERC20'), EthereumAddress.fromHex(widget.tokenAddress));
      final nameFn = contract.function('name');
      final symbolFn = contract.function('symbol');
      final decimalsFn = contract.function('decimals');
      final balanceFn = contract.function('balanceOf');

      final nameRes = await client.call(contract: contract, function: nameFn, params: []);
      final symbolRes = await client.call(contract: contract, function: symbolFn, params: []);
      final decimalsRes = await client.call(contract: contract, function: decimalsFn, params: []);
      final balanceRes = await client.call(contract: contract, function: balanceFn, params: [EthereumAddress.fromHex(widget.accountAddress)]);

      setState(() {
        _name = nameRes.isNotEmpty ? nameRes.first as String : null;
        _symbol = symbolRes.isNotEmpty ? symbolRes.first as String : null;
        _decimals = decimalsRes.isNotEmpty ? (decimalsRes.first as BigInt).toInt() : null;
        _balance = balanceRes.isNotEmpty ? balanceRes.first as BigInt : null;
        _loading = false;
      });
      client.dispose();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  static const _erc20Abi = '''[
  {"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
  {"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"}
]''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_symbol ?? 'Token')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Name: ${_name ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('Symbol: ${_symbol ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('Decimals: ${_decimals ?? '-'}'),
                    const SizedBox(height: 8),
                    Text('Balance: ${_balance ?? BigInt.zero}'),
                    const Spacer(),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      ElevatedButton(onPressed: () {/* navigate to send flow */}, child: const Text('Send')),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: () {/* open receive QR */}, child: const Text('Receive')),
                    ])
                  ]),
                ),
    );
  }
}
