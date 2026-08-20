class AddressUtils {
  static bool isValidEthereumAddress(String address) {
    if (address.isEmpty) return false;
    final a = address.toLowerCase();
    if (!a.startsWith('0x')) return false;
    if (a.length != 42) return false;
    final hexPart = a.substring(2);
    final validHex = RegExp(r'^[0-9a-f]{40}\$');
    return validHex.hasMatch(hexPart);
  }
}
