import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/transactions/transaction_service.dart';
import '../../core/hd/hd_wallet_service.dart';
import '../../core/network/rpc_manager.dart';

final sendControllerProvider = StateNotifierProvider.family<SendController, SendState, SendDeps>((ref, deps) {
  return SendController(deps, ref.read);
});

class SendDeps {
  final RpcManager rpc;
  final HdWalletService hd;
  final int chainId;
  SendDeps({required this.rpc, required this.hd, required this.chainId});
}

class SendState {
  final bool loading;
  final String? error;
  final String? txHash;

  SendState({this.loading = false, this.error, this.txHash});

  SendState copyWith({bool? loading, String? error, String? txHash}) => SendState(
        loading: loading ?? this.loading,
        error: error,
        txHash: txHash ?? this.txHash,
      );
}

class SendController extends StateNotifier<SendState> {
  final SendDeps deps;
  final Reader read;
  final TransactionService _txService;

  SendController(this.deps, this.read)
      : _txService = TransactionService(deps.rpc, deps.hd),
        super(SendState());

  Future<void> send({required String fromAddress, required String toAddress, required String amountDecimal, required String tokenAddress, required int derivationIndex}) async {
    try {
      state = state.copyWith(loading: true, error: null);
      final hash = await _txService.buildSignAndSend(
        fromAddress: fromAddress,
        toAddress: toAddress,
        amountDecimal: amountDecimal,
        tokenAddress: tokenAddress,
        derivationIndex: derivationIndex,
        chainId: deps.chainId,
      );
      state = state.copyWith(loading: false, txHash: hash);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
