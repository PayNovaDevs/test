# dex wallet

This repository contains the initial foundation of "dex wallet" — a premium, non-custodial EVM wallet for Flutter 3.x.

What is included in this branch
- Full HD wallet implementation (bip39 + bip32) and secure storage
- WalletVault, SessionManager (PIN + Biometric), RpcManager with HTTP+WS support
- AppConfig + assets/networks.json for configurable networks
- TokenRegistry and NetworkRepository
- Home UI skeleton and recommended architecture

Configuration: how to add / edit RPCs and Networks

1) networks.json (assets)
- The canonical default networks live in `assets/networks.json`.
- Each entry follows this schema:

{
  "id": "ethereum",
  "name": "Ethereum",
  "chainId": 1,
  "symbol": "ETH",
  "rpcUrl": "https://your-rpc.example",
  "wsRpcUrl": "wss://your-ws.example",
  "explorerUrl": "https://explorer.example",
  "decimals": 18,
  "isTestnet": false
}

2) Runtime overrides and adding a new chain
- The app loads `assets/networks.json` on startup via `AppConfig`.
- To add or edit a network without modifying the app bundle, open the in-app Settings → Networks → Add Network (UI coming) or persist an override JSON via Secure Storage.
- For development you can edit `assets/networks.json` directly and rebuild the app.

3) .env / secrets
- Sensitive API keys (Infura, Alchemy, 1inch) should be provided via environment variables or CI secrets. See `.env.example` (to be created) and README instructions before production use.

Security notes
- Never store mnemonic or private keys in plaintext or push them to a remote service.
- The Vault stores seed/private keys only in OS-backed secure storage (Keychain/Keystore). For production, consider additional hardware-backed key wrapping or secure enclave usage.

How to run locally
1) flutter pub get
2) flutter run

When you're ready to compile
- I will finish the remaining integrations and then notify you. At that point pull the branch `feat/wallet-vault-initial`, run `flutter pub get` and `flutter run`.

Merging
- Per your request, when everything esté listo, haré el merge a `main` (te avisaré antes de hacer el merge final).
