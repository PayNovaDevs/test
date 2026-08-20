# dex wallet

This repository contains the initial foundation of "dex wallet" — a premium, non-custodial EVM wallet for Flutter 3.x.

What is included in this commit
- Project structure (Clean Architecture + feature-based)
- pubspec.yaml with recommended dependencies
- Core models: NetworkConfig, TokenConfig, WalletAccount
- Core security: WalletVault interface and a high-level implementation outline
- SecureStorageService (wrapper for flutter_secure_storage)
- HdWalletService interface (abstraction for BIP39/BIP44 derivation & signing)
- RpcManager: HTTP JSON-RPC client using Dio
- HomeScreen: Material 3, dark theme, Riverpod + GoRouter wiring
- Basic tests skeleton for BIP39 (unit test)

Security notes
- Never log or persist mnemonic or private keys in plaintext.
- The WalletVault and HdWalletService abstractions are responsible for keeping secrets within secure storage and limiting their exposure.
- Do NOT use this code in production with real funds until a third-party security audit and hardening is performed.

Next steps
- Provide a concrete HdWalletService implementation (e.g. using bip39 + bip32 + web3dart credentials) and ensure keys are stored/used only in secure storage.
- Implement PIN / biometric flows and session locking (SessionManager)
- Implement RPC mocks and connect to a testnet for integration tests
- Implement WalletConnect/DApp integration and Swap architecture

Notes about dependencies
- Versions chosen are compatible with Flutter 3.x at the time of authoring. If package APIs change, update implementations and document the change in this README.

Branch: feat/wallet-vault-initial
