import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../core/security/secure_storage_service.dart';
import '../core/hd/impl/hd_wallet_service_impl.dart';
import '../core/hd/hd_wallet_service.dart';
import '../core/network/rpc_manager.dart';
import '../core/models/network_config.dart';
import '../core/dapps/wallet_connect_v1_impl.dart';
import '../core/dapps/wallet_connect_manager.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final hdWalletServiceProvider = Provider<HdWalletService>((ref) => HdWalletServiceImpl(ref.read(secureStorageProvider)));

final defaultNetworkProvider = Provider<NetworkConfig>((ref) => NetworkConfig(
      id: 'local',
      name: 'Local',
      chainId: 1,
      symbol: 'ETH',
      rpcUrl: '',
      wsRpcUrl: null,
      explorerUrl: '',
      decimals: 18,
      isTestnet: false,
    ));

final rpcManagerProvider = Provider<RpcManager>((ref) => RpcManager(ref.read(defaultNetworkProvider)));

// WalletConnect manager: creates the v1 impl and wraps it
final walletConnectServiceProvider = Provider<WalletConnectV1Impl>((ref) {
  final svc = WalletConnectV1Impl();
  svc.init();
  return svc;
});

final walletConnectManagerProvider = Provider<WalletConnectManager>((ref) {
  final svc = ref.read(walletConnectServiceProvider);
  final manager = WalletConnectManager(svc);
  manager.init();
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
});

// Locale management: persisted in secure storage under key 'app_lang'
class LocaleNotifier extends StateNotifier<Locale> {
  final Reader read;
  LocaleNotifier(this.read) : super(const Locale('es')) {
    _load();
  }

  static const _key = 'app_lang';

  Future<void> _load() async {
    try {
      final storage = read(secureStorageProvider);
      final l = await storage.read(_key);
      if (l != null && l.isNotEmpty) state = Locale(l);
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final storage = read(secureStorageProvider);
    await storage.write(_key, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier(ref.read));
