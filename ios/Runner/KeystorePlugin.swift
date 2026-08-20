import Flutter
import UIKit
import Security

public class KeystorePlugin: NSObject, FlutterPlugin {
  private let keyTag = "com.example.dex_wallet.wrapkey"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.example.dex_wallet/keystore", binaryMessenger: registrar.messenger())
    let instance = KeystorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ensureWrapKey":
      ensureKey()
      result(nil)
    case "wrapKey":
      guard let args = call.arguments as? [String: Any], let keyB64 = args["key"] as? String else { result(FlutterError(code:"bad", message:"missing", details:nil)); return }
      result(wrapKey(base64: keyB64))
    case "unwrapKey":
      guard let args = call.arguments as? [String: Any], let wrapped = args["wrapped"] as? String else { result(FlutterError(code:"bad", message:"missing", details:nil)); return }
      unwrapKey(wrappedBase64: wrapped, result: result)
    case "deleteWrapKey":
      deleteKey()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func ensureKey() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: keyTag,
      kSecReturnRef as String: true
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == errSecSuccess { return }
    let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
      kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: keyTag,
        kSecAttrAccessControl as String: access as Any
      ]
    ]
    var error: Unmanaged<CFError>?
    _ = SecKeyCreateRandomKey(attributes as CFDictionary, &error)
  }

  func loadPrivateKey() -> SecKey? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: keyTag,
      kSecReturnRef as String: true,
      kSecAttrKeyType as String: kSecAttrKeyTypeEC
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == errSecSuccess { return (item as! SecKey) }
    return nil
  }

  func wrapKey(base64: String) -> String? {
    guard let privateKey = loadPrivateKey(), let publicKey = SecKeyCopyPublicKey(privateKey) else { return nil }
    guard let keyData = Data(base64Encoded: base64) else { return nil }
    let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
    var error: Unmanaged<CFError>?
    if let cipher = SecKeyCreateEncryptedData(publicKey, algorithm, keyData as CFData, &error) {
      return (cipher as Data).base64EncodedString()
    }
    return nil
  }

  func unwrapKey(wrappedBase64: String, result: @escaping FlutterResult) {
    guard let privateKey = loadPrivateKey() else { result(FlutterError(code:"no_key", message:nil, details:nil)); return }
    guard let cipherData = Data(base64Encoded: wrappedBase64) else { result(FlutterError(code:"bad", message:nil, details:nil)); return }
    let algorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
    var error: Unmanaged<CFError>?
    if let plain = SecKeyCreateDecryptedData(privateKey, algorithm, cipherData as CFData, &error) {
      result((plain as Data).base64EncodedString())
    } else {
      result(FlutterError(code:"unwrap_failed", message: error?.takeRetainedValue().localizedDescription, details:nil))
    }
  }

  func deleteKey() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: keyTag
    ]
    SecItemDelete(query as CFDictionary)
  }
}
