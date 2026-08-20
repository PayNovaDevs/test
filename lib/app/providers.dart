import 'package:flutter_riverpod/flutter_riverpod.dart';

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
