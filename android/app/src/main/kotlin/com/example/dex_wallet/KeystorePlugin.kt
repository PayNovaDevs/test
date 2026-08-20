package com.paynova.dex

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class KeystorePlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  private lateinit var channel : MethodChannel
  private val KEY_ALIAS = "dex_wallet_wrap_key"
  private val ANDROID_KEYSTORE = "AndroidKeyStore"

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "com.paynova.dex/keystore")
    channel.setMethodCallHandler(this)
  }

  private fun ensureKey() {
    val ks = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    if (ks.containsAlias(KEY_ALIAS)) return
    val kpg = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
    val spec = KeyGenParameterSpec.Builder(KEY_ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
        .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
        .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
        .setUserAuthenticationRequired(true)
        .setUserAuthenticationValidityDurationSeconds(0)
        .setKeySize(256)
        .build()
    kpg.init(spec)
    kpg.generateKey()
  }

  private fun getSecretKey(): SecretKey {
    val ks = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    return (ks.getEntry(KEY_ALIAS, null) as KeyStore.SecretKeyEntry).secretKey
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "ensureWrapKey" -> {
        ensureKey()
        result.success(null)
      }
      "wrapKey" -> {
        val keyB64 = call.argument<String>("key")!!
        val keyBytes = Base64.decode(keyB64, Base64.URL_SAFE or Base64.NO_WRAP)
        val secret = getSecretKey()
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, secret)
        val out = cipher.doFinal(keyBytes)
        val combined = cipher.iv + out
        result.success(Base64.encodeToString(combined, Base64.URL_SAFE or Base64.NO_WRAP))
      }
      "unwrapKey" -> {
        val wrapped = call.argument<String>("wrapped")!!
        val combined = Base64.decode(wrapped, Base64.URL_SAFE or Base64.NO_WRAP)
        val iv = combined.copyOfRange(0, 12)
        val cipherText = combined.copyOfRange(12, combined.size)
        val secret = getSecretKey() // triggers auth if required
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, secret, GCMParameterSpec(128, iv))
        val plain = cipher.doFinal(cipherText)
        result.success(Base64.encodeToString(plain, Base64.URL_SAFE or Base64.NO_WRAP))
      }
      "deleteWrapKey" -> {
        val ks = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        ks.deleteEntry(KEY_ALIAS)
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
