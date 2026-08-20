# WalletConnect and 1inch integration

This document explains how to configure WalletConnect and 1inch integration in the project.

WalletConnect v1
- Implemented using `walletconnect_dart`. The concrete implementation is in `lib/core/dapps/wallet_connect_v1_impl.dart`.
- It will open the WalletConnect URI in an external wallet using `url_launcher`.

WalletConnect v2
- A placeholder implementation is provided in `lib/core/dapps/wallet_connect_v2_impl.dart` which reads a ProjectID from env `WC_PROJECT_ID` using `flutter_dotenv`.
- Provide `WC_PROJECT_ID` in your local `.env` or environment to enable v2 initialization.

Where to put the ProjectID
- Locally, create a `.env` file in the project root with:

  WC_PROJECT_ID=your_project_id_here

- Do not commit `.env` to git.
- Alternatively set the environment variable before running the app:

  export WC_PROJECT_ID=your_project_id_here
  flutter run

1inch
- The adapter is implemented in `lib/core/dex/one_inch_adapter.dart` and wrapped by `lib/core/dex/dex_manager.dart`.
- Swaps are disabled by default (DexManager.enabled = false). To enable swaps change the provider where DexManager is constructed.

Security
- Never commit API keys or secrets to the repository.
- WalletConnect v2 ProjectID and any 1inch keys must be stored in environment variables or CI secrets.

Tests
- Basic unit tests for WalletConnect init live in `test/walletconnect/walletconnect_test.dart`. These do not connect to external relays but ensure the service initializes locally.
