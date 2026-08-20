import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

import '../network/rpc_manager.dart';
import '../hd/hd_wallet_service.dart';

class TransactionService {
  final RpcManager _rpc;
  final HdWalletService _hd;

  TransactionService(this._rpc, this._hd);

  Future<String> buildSignAndSend({required String fromAddress, required String toAddress, required String amountDecimal, required String tokenAddress, required int derivationIndex, required int chainId}) async {
    // If tokenAddress is empty -> native transfer
    if (tokenAddress.isEmpty) {
      // native transfer
      final nonceHex = await _rpc.getNonce(fromAddress);
      final nonce = int.parse(nonceHex.substring(2), radix: 16);

      // get gas estimate
      final gasLimitHex = await _rpc.estimateGas({
        'from': fromAddress,
        'to': toAddress,
        'value': '0x' + BigInt.parse((double.parse(amountDecimal) * BigInt.from(1).toInt()).toString()).toRadixString(16)
      });
      final gasLimit = int.parse(gasLimitHex.substring(2), radix: 16);

      // Try to detect EIP-1559 via eth_feeHistory or presence of baseFeePerGas in block header
      // For simplicity, we'll try eth_feeHistory with 1 block
      try {
        final feeResult = await _rpc._postRpc('eth_feeHistory', [1, 'latest', []]);
        // If no error, use EIP-1559 fields
        final baseFeePerGasHex = feeResult['baseFeePerGas'][0] as String;
        final baseFeePerGas = BigInt.parse(baseFeePerGasHex.substring(2), radix: 16);
        // choose priority
        final maxPriorityFeePerGas = baseFeePerGas ~/ BigInt.from(10); // simple heuristic
        final maxFeePerGas = baseFeePerGas + maxPriorityFeePerGas;

        final value = EtherAmount.fromUnitAndValue(EtherUnit.ether, amountDecimal);

        final tx = Transaction(
          to: EthereumAddress.fromHex(toAddress),
          from: EthereumAddress.fromHex(fromAddress),
          maxGas: gasLimit,
          maxPriorityFeePerGas: EtherAmount.inWei(maxPriorityFeePerGas),
          maxFeePerGas: EtherAmount.inWei(maxFeePerGas),
          value: value,
          nonce: nonce,
        );

        final signed = await _hd.signTransactionObject(tx, derivationIndex, chainId);
        final txHash = await _rpc.sendRawTransaction(signed);
        return txHash;
      } catch (e) {
        // fallback to legacy gasPrice
        final gasPriceResp = await _rpc._postRpc('eth_gasPrice', []);
        final gasPriceHex = gasPriceResp['result'] as String;
        final gasPrice = EtherAmount.inWei(BigInt.parse(gasPriceHex.substring(2), radix: 16));

        final value = EtherAmount.fromUnitAndValue(EtherUnit.ether, amountDecimal);
        final tx = Transaction(
          to: EthereumAddress.fromHex(toAddress),
          from: EthereumAddress.fromHex(fromAddress),
          maxGas: gasLimit,
          gasPrice: gasPrice,
          value: value,
          nonce: nonce,
        );
        final signed = await _hd.signTransactionObject(tx, derivationIndex, chainId);
        final txHash = await _rpc.sendRawTransaction(signed);
        return txHash;
      }
    } else {
      // ERC20 transfer: build data for transfer(address,uint256)
      final toClean = toAddress;
      final amount = BigInt.from((double.parse(amountDecimal) * pow(10, 18)).toInt());
      final data = buildERC20TransferData(toClean, amount);

      final nonceHex = await _rpc.getNonce(fromAddress);
      final nonce = int.parse(nonceHex.substring(2), radix: 16);

      final gasLimitHex = await _rpc.estimateGas({'from': fromAddress, 'to': tokenAddress, 'data': data});
      final gasLimit = int.parse(gasLimitHex.substring(2), radix: 16);

      try {
        final feeResult = await _rpc._postRpc('eth_feeHistory', [1, 'latest', []]);
        final baseFeePerGasHex = feeResult['baseFeePerGas'][0] as String;
        final baseFeePerGas = BigInt.parse(baseFeePerGasHex.substring(2), radix: 16);
        final maxPriorityFeePerGas = baseFeePerGas ~/ BigInt.from(10);
        final maxFeePerGas = baseFeePerGas + maxPriorityFeePerGas;

        final tx = Transaction(
          to: EthereumAddress.fromHex(tokenAddress),
          from: EthereumAddress.fromHex(fromAddress),
          maxGas: gasLimit,
          maxPriorityFeePerGas: EtherAmount.inWei(maxPriorityFeePerGas),
          maxFeePerGas: EtherAmount.inWei(maxFeePerGas),
          data: hex.decode(data.replaceFirst('0x', '')) as Uint8List,
          nonce: nonce,
        );

        final signed = await _hd.signTransactionObject(tx, derivationIndex, chainId);
        final txHash = await _rpc.sendRawTransaction(signed);
        return txHash;
      } catch (e) {
        final gasPriceResp = await _rpc._postRpc('eth_gasPrice', []);
        final gasPriceHex = gasPriceResp['result'] as String;
        final gasPrice = EtherAmount.inWei(BigInt.parse(gasPriceHex.substring(2), radix: 16));

        final tx = Transaction(
          to: EthereumAddress.fromHex(tokenAddress),
          from: EthereumAddress.fromHex(fromAddress),
          maxGas: gasLimit,
          gasPrice: gasPrice,
          data: hex.decode(data.replaceFirst('0x', '')) as Uint8List,
          nonce: nonce,
        );

        final signed = await _hd.signTransactionObject(tx, derivationIndex, chainId);
        final txHash = await _rpc.sendRawTransaction(signed);
        return txHash;
      }
    }
  }

  String buildERC20TransferData(String to, BigInt amount) {
    final method = 'a9059cbb'; // transfer(address,uint256)
    final toClean = to.replaceFirst('0x', '').padLeft(64, '0');
    final amountHex = amount.toRadixString(16).padLeft(64, '0');
    return '0x' + method + toClean + amountHex;
  }
}
