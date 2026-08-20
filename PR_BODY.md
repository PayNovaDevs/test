FINALIZACIÓN: Fase UI/Onboarding (Phase 1) - PR body

Resumen de cambios
- Tema y componentes visuales: Material3 dark theme, GlassCard, GradientButton, SkeletonLoader, Sparkline.
- Onboarding: Splash, Welcome, Onboarding screens with localized strings (ES/EN).
- Home: Balance card with mini-chart, tokens list, FAB Send.
- Receive & Scan: Receive screen with QR, QR scanner (mobile_scanner) and copy/share UX.
- Transactions: Confirmation UI with EIP-1559 fee breakdown (maxPriorityFee, maxFee, estimated total), PIN + biometric approval flow, PIN lockout on repeated failures.
- Security: SecureStorageService and PinService (salted SHA-256) for PIN storage/verification.
- DApps: WalletConnect v1 integration and sessions manager + sessions screen (list/revoke).
- i18n: ARB files for English and Spanish and wiring via AppLocalizations delegate.
- Tests: unit/widget tests for fee utils, PinService integration test, PIN dialog widget test.

Notas de seguridad y QA
- Do NOT commit .env or secrets. Use .env for WC_PROJECT_ID, ONEINCH_KEY, RPC keys.
- PIN stored as salted SHA-256; for production use hardware-backed key storage and PBKDF2/KDF and perform an independent security audit before handling real funds.
- The PIN lockout is: 5 failed attempts -> 5 minute cooldown (configurable in code). This is a basic protection; consider rate-limiting and secure enclave usage.
- WalletConnect v2 is left as placeholder and requires WC_PROJECT_ID.

Cómo probar localmente
1) git fetch origin
2) git checkout main
3) flutter pub get
4) flutter run
- For QR scanning on Android/iOS add camera permissions in the platform manifests.
- To test WalletConnect v2 or 1inch integration add WC_PROJECT_ID / ONEINCH_KEY to a .env file at repo root (do not commit it).

Siguientes pasos recomendados
- Audit the cryptographic/key handling and secure storage design.
- Add integration tests that mock RPC endpoints for send/sign flows.
- Polish branding and assets (logos SVG/PNG) and finalize theme tokens.

Branch de trabajo: feat/ui-onboarding-phase1
Merge: los cambios ya han sido fusionados en main en este commit.
