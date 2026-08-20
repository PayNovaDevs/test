import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../core/security/secure_storage_service.dart';
import '../core/hd/impl/hd_wallet_service_impl.dart';
import '../core/hd/hd_wallet_service.dart';
import '../core/network/rpc_manager.dart';
import '../core/models/network_config.dart';

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
