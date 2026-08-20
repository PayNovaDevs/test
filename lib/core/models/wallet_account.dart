class WalletAccount {
  final String id;
  final String name;
  final String address;
  final int derivationIndex;

  WalletAccount({
    required this.id,
    required this.name,
    required this.address,
    required this.derivationIndex,
  });
}
