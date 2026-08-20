## OneInch and WalletConnect configuration

This commit includes:
- OneInchAdapter (lib/core/dex/one_inch_adapter.dart): uses the public 1inch API v5 to fetch quotes and build swap transactions. The adapter will be used by DexManager but swaps are disabled by default in the UI. To enable swaps later, configure DexManager.enabled = true in your providers and add UI to present quotes and request approval for swap tx.

- WalletConnect service interfaces (lib/core/dapps/wallet_connect_service.dart): generic interface for v1 and v2. Concrete bindings to packages are intentionally left as adapters so you can choose the package/version you prefer. For v2 you will need a ProjectID (relay credentials) which must be set in your environment.

Where to put ProjectID (WC v2)
- Do NOT commit the ProjectID to the repository.
- Recommended: put WC ProjectID in environment variables or CI secrets. Example:

  WC_PROJECT_ID=your_project_id_here

- Locally, you can set it in a .env file (not committed) or set the variable in your shell before running the app:

  export WC_PROJECT_ID=your_project_id_here
  flutter run

- AppConfig / providers should read this env variable and pass it to WalletConnectV2Service(projectId: envValue).

OneInch notes
- 1inch quote endpoint: `GET https://api.1inch.io/v5.0/{chainId}/quote?fromTokenAddress={from}&toTokenAddress={to}&amount={amount}`
- 1inch swap endpoint: `GET https://api.1inch.io/v5.0/{chainId}/swap?...` returns a `tx` object with fields `{to, data, value, gas, gasPrice}` which you should present to the user.
- For production or high request rates consider an API key (do not commit keys to the repo). Put keys into environment variables and configure Dio headers accordingly.

How swaps are disabled by default
- DexManager has an `enabled` flag (default false). The UI does not expose swap actions yet. When ready, flip the flag in your provider to enable swap flows.

Security
- As always, never send unsigned private keys or mnemonic to any remote service. 1inch API is used only to build calldata and quote; the user must sign the resulting tx locally and the app sends the raw signed tx to the RPC via eth_sendRawTransaction.

