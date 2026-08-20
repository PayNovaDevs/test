import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../../core/hd/impl/hd_wallet_service_impl.dart';
import '../../core/hd/hd_wallet_service.dart';
import '../../core/network/rpc_manager.dart';
import '../../features/networks/networks_service.dart';
import '../../features/transactions/pin_entry_dialog.dart';

class SendScreen extends StatefulWidget {
  final String fromAddress;
  final int fromIndex; // HD index for signing

  const SendScreen({Key? key, required this.fromAddress, required this.fromIndex}) : super(key: key);

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _toCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _isToken = false;
  bool _loading = false;
  String? _status;

  @override
  void dispose() {
    _toCtrl.dispose();
    _amountCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  BigInt _parseAmountToUint(String v, int decimals) {
    v = v.trim();
    if (v.isEmpty) return BigInt.zero;
    if (!v.contains('.')) {
      return BigInt.parse(v) * BigInt.from(10).pow(decimals);
    }
    final parts = v.split('.');
    final whole = parts[0].isEmpty ? BigInt.zero : BigInt.parse(parts[0]);
    var fracStr = parts[1];
    if (fracStr.length > decimals) fracStr = fracStr.substring(0, decimals);
    while (fracStr.length < decimals) fracStr = fracStr + '0';
    final frac = fracStr.isEmpty ? BigInt.zero : BigInt.parse(fracStr);
    return whole * BigInt.from(10).pow(decimals) + frac;
  }

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _status = null;
    });
    try {
      final ns = NetworksService();
      final net = ns.activeNetwork;
      if (net == null) throw Exception('No active network');
      if (net.rpcUrl.isEmpty) throw Exception('No RPC configured for ${net.name}');

      final rpc = RpcManager(net);
      final web3 = Web3Client(net.rpcUrl, Client());

      final to = _toCtrl.text.trim();
      if (to.isEmpty) throw Exception('Missing destination address');

      // Require PIN/biometric before proceeding
      final authOk = await showDialog<bool>(context: context, builder: (_) => const PinEntryDialog()) ?? false;
      if (!authOk) throw Exception('Authentication required');

      if (!_isToken) {
        final amountWei = _parseAmountToUint(_amountCtrl.text.trim(), net.decimals);
        final nonceHex = await rpc.getNonce(widget.fromAddress);
        final nonce = int.parse(nonceHex.substring(2), radix: 16);
        final gasPriceHex = await rpc.gasPrice();
        final gasPrice = BigInt.parse(gasPriceHex.substring(2), radix: 16);
        final tx = Transaction(
          to: EthereumAddress.fromHex(to),
          value: EtherAmount.inWei(amountWei),
          gasPrice: EtherAmount.inWei(gasPrice),
          maxGas: 21000,
          nonce: nonce,
        );

        final hd = HdWalletServiceImpl(SecureStorageService());
        final signedHex = await hd.signTransactionObject(tx, widget.fromIndex, net.chainId);
        final txHash = await rpc.sendRawTransaction(signedHex);

        setState(() {
          _status = 'Sent: $txHash';
        });
      } else {
        final tokenAddr = _tokenCtrl.text.trim();
        if (tokenAddr.isEmpty) throw Exception('Missing token contract address');

        final contract = DeployedContract(ContractAbi.fromJson(_erc20Abi, 'ERC20'), EthereumAddress.fromHex(tokenAddr));
        final transferFn = contract.function('transfer');

        // discover decimals via on-chain call
        final decimalsCall = await web3.call(contract: contract, function: contract.function('decimals'), params: []);
        final decimals = decimalsCall.isNotEmpty ? (decimalsCall.first as BigInt).toInt() : 18;

        final amount = _parseAmountToUint(_amountCtrl.text.trim(), decimals);

        final nonceHex = await rpc.getNonce(widget.fromAddress);
        final nonce = int.parse(nonceHex.substring(2), radix: 16);
        final gasPriceHex = await rpc.gasPrice();
        final gasPrice = BigInt.parse(gasPriceHex.substring(2), radix: 16);

        final tx = Transaction.callContract(
          contract: contract,
          function: transferFn,
          parameters: [EthereumAddress.fromHex(to), amount],
          maxGas: 100000,
          gasPrice: EtherAmount.inWei(gasPrice),
          nonce: nonce,
        );

        final hd = HdWalletServiceImpl(SecureStorageService());
        final signedHex = await hd.signTransactionObject(tx, widget.fromIndex, net.chainId);
        final txHash = await rpc.sendRawTransaction(signedHex);

        setState(() {
          _status = 'ERC20 sent: $txHash';
        });
      }

      web3.dispose();
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  static const _erc20Abi = '''[
  {"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
  {"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"},
  {"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"}
]''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _toCtrl, decoration: const InputDecoration(labelText: 'To (address)')),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _amountCtrl, decoration: const InputDecoration(labelText: 'Amount'))),
            const SizedBox(width: 8),
            Checkbox(value: _isToken, onChanged: (v) => setState(() => _isToken = v ?? false)),
            const SizedBox(width: 4),
            const Text('ERC20')
          ]),
          if (_isToken) ...[
            const SizedBox(height: 8),
            TextField(controller: _tokenCtrl, decoration: const InputDecoration(labelText: 'Token contract address')),
          ],
          const SizedBox(height: 16),
          _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _send, child: const Text('Estimate & Send')),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!)
          ]
        ]),
      ),
    );
  }
}
