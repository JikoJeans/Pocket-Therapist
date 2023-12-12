import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:hashlib/hashlib.dart';
import 'package:app/provider/settings.dart' as settings;
import 'package:flutter/foundation.dart' as thread;

String _passwordHash = "";
String _keyCipher = "";
String _recoveryKeyCipher = "";
String _recoveryHash = "";

/// [_recovery] temporary storage for the recovery phrase
String? _recovery = "";

// Held in memory
Encrypter? _encrypter;

// Argon2 parameters
const int parallelPower = 4;
const int consumeMemory = 500000;
const int iterations =
    6; //9 2x recommended minimum, updated to 6 to speed up unit test
//------------------------------------------------------------------------------
const int pwHashLength = 32;

/// [setPassword] should only be called if setting a password.
/// password is the provided passphrase that the user shall remember
Future<void> setPassword(String password) async {
  if (password.isEmpty) {
    return;
  }
  // Generate the actual signing key
  Key signingKey = Key.fromSecureRandom(pwHashLength);

  // Used for file encryption
  _encrypter = Encrypter(AES(signingKey, mode: AESMode.gcm));
  await _generateKeyEncryptionKey(password, signingKey);
  await _generateRecoveryPhrase(signingKey);
  settings.setEncryptionStatus(true); // password is set, this is true.
}

/// [getRecoveryPhrase] only works once after calling [generateRecoveryPhrase].
String? getRecoveryPhrase() {
  String? temp =
      _recovery; // This varibel will be cleared once this ends so the phrase is secure.
  _recovery = null;
  return temp;
}

/// [resetCredentials] is the entry point for the reset pasword process
/// Accept user input
/// call this method with that input
/// If matches -> call [setPassword], which will overwrite the credentials
///   Then call [getRecoveryPhrase] which will return and erase the recovery phrase from memory
/// else -> reprompt till successful.
///
/// Either password or recovery phrase will work with this, but it expects
/// the recovery phrase first.
Future<bool> resetCredentials(String phrase) async {
  // Try to unlock assuming password
  // Then try to unlock assuming recovery phrase
  if (await verifyPassword(phrase)) {
    Argon2 hasher = await thread.compute(Argon2.fromEncoded, _passwordHash);
    //Generate KEK for internal encryption of actual key
    Argon2HashDigest keyEncryptionKey =
        await thread.compute(hasher.convert, phrase.codeUnits);
    // Used for Encrypting the secret key, temporary.
    Encrypter keyEncrypter =
        Encrypter(AES(Key(keyEncryptionKey.bytes), mode: AESMode.gcm));
    // Split the package between the IV and the cipher K
    List<String> package = _keyCipher.split(':');
    IV secretIV = IV.fromBase64(package[0]);
    Encrypted eKey = Encrypted.fromBase64(package[1]);
    package.clear(); // Dont need package anymore

    // the encrypter internall decodes it into a string, so we just re-encode it to get the bytes
    Uint8List keyBytes =
        Uint8List.fromList(keyEncrypter.decryptBytes(eKey, iv: secretIV));
    Key signingKey = Key(keyBytes);
    //Decrypt database
    signingKey;
    // Wipe
    _passwordHash = "";
    _keyCipher = "";
    _recoveryKeyCipher = "";
    _recoveryHash = "";
    _recovery = "";
    _encrypter = null;
    settings.setConfigured(false);
    settings.setEncryptionStatus(false); // Prevents a soft lock out of the app
    // Externally should call setPassword to complete the reset process.
    settings.save().whenComplete(() => null);
    return true;
  }
  if (await verifyRecoveryPhrase(phrase)) {
    Argon2 hasher = await thread.compute(Argon2.fromEncoded, _recoveryHash);
    //Generate KEK for internal encryption of actual key
    Argon2HashDigest keyEncryptionKey =
        await thread.compute(hasher.convert, phrase.codeUnits);
    // Used for Encrypting the secret key, temporary.
    Encrypter keyEncrypter =
        Encrypter(AES(Key(keyEncryptionKey.bytes), mode: AESMode.gcm));
    // Split the package between the IV and the cipher K
    List<String> package = _recoveryKeyCipher.split(':');
    IV secretIV = IV.fromBase64(package[0]);
    Encrypted eKey = Encrypted.fromBase64(package[1]);
    package.clear(); // Dont need package anymore

    // the encrypter internall decodes it into a string, so we just re-encode it to get the bytes
    Uint8List keyBytes =
        Uint8List.fromList(keyEncrypter.decryptBytes(eKey, iv: secretIV));

    Key signingKey = Key(keyBytes);
    signingKey;
    //Decrypt database

    // Wipe
    _passwordHash = "";
    _keyCipher = "";
    _recoveryKeyCipher = "";
    _recoveryHash = "";
    _recovery = "";
    _encrypter = null;
    settings.setConfigured(false);
    settings.setEncryptionStatus(false); // Prevents a soft lock out of the app
    // Externally should call setPassword to complete the reset process.
    settings.save().whenComplete(() => null);
    return true;
  }
  return false; // Entered is neither password nor recovery phrase...
}

/// [verifyPassword] returns true iff the password parameter matches the stored hash.
Future<bool> verifyPassword(String password) async {
  Argon2 hasher = await thread.compute(Argon2.fromEncoded, _passwordHash);
  //Generate KEK for internal encryption of actual key
  Argon2HashDigest keyEncryptionKey =
      await thread.compute(hasher.convert, password.codeUnits);
  String maybe = keyEncryptionKey.encoded();
  return maybe == _passwordHash;
}

/// [verifyRecoveryPhrase] returns true iff the recovery phrase matches the stored hash.
Future<bool> verifyRecoveryPhrase(String phrase) async {
  Argon2 hasher = await thread.compute(Argon2.fromEncoded, _recoveryHash);
  //Generate KEK for internal encryption of actual key
  Argon2HashDigest keyEncryptionKey =
      await thread.compute(hasher.convert, phrase.codeUnits);
  String maybe = keyEncryptionKey.encoded();
  return maybe == _recoveryHash;
}

/// [unlock] is responsible for unlocking and initializing the application after password has been set
/// The recovery boolean indicates if we are unlocking with the recovery method, this should
/// lead to a password reset, but it is not required.
Future<bool> unlock(String passwordPhrase, [bool recovery = false]) async {
  Future<bool> valid = !recovery
      ? verifyPassword(passwordPhrase)
      : verifyRecoveryPhrase(passwordPhrase);
  if (await valid) {
    Argon2 hasher = await thread.compute(
        Argon2.fromEncoded, (!recovery ? _passwordHash : _recoveryHash));
    //Generate KEK for internal encryption of actual key
    Argon2HashDigest keyEncryptionKey =
        await thread.compute(hasher.convert, passwordPhrase.codeUnits);
    // Used for Encrypting the secret key, temporary.
    Encrypter keyEncrypter =
        Encrypter(AES(Key(keyEncryptionKey.bytes), mode: AESMode.gcm));
    // Split the package between the IV and the cipher K
    List<String> package =
        (recovery ? _recoveryKeyCipher.split(':') : _keyCipher.split(':'));
    IV secretIV = IV.fromBase64(package[0]);
    Encrypted eKey = Encrypted.fromBase64(package[1]);
    package.clear(); // Dont need package anymore

    // the encrypter internall decodes it into a string, so we just re-encode it to get the bytes
    Uint8List keyBytes =
        Uint8List.fromList(keyEncrypter.decryptBytes(eKey, iv: secretIV));

    // Then we form the key from this and make the encryptor
    _encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.gcm));

    return true;
  } else {
    return false;
  }
}

// Utilities --------------------------------------
/// [generateKeyEncryptionKey] Generates an encryption key based on the password supplied and uses it to
/// Encrypt the provided signing Key.
/// the [nonce] [_passwordHash] and [_keyCipher] are all modified by this method
Future _generateKeyEncryptionKey(String password, Key signingKey) async {
  // Encryption Setup
  Random rand = Random.secure();
  List<int> nonce = List<int>.generate(16, (index) => rand.nextInt(256));
  Argon2 hasher = Argon2(
      salt: nonce,
      hashLength: pwHashLength,
      iterations: iterations,
      parallelism: parallelPower,
      memorySizeKB: consumeMemory);
  //Generate KEK for internal encryption of actual key
  Argon2HashDigest keyEncryptionKey =
      await thread.compute(hasher.convert, password.codeUnits);
  _passwordHash = keyEncryptionKey.encoded();
  // Used for Encrypting the secret key, temporary.
  Encrypter keyEncrypter = Encrypter(
      AES(Key(Uint8List.fromList(keyEncryptionKey.bytes)), mode: AESMode.gcm));

  // Generate random IV for key signing
  // Need 96 bit IV for clear GCM mode
  IV secretKeyIV = IV.fromSecureRandom(12); // 12 bytes = 8 * 12 = 96 bit
  Encrypted cryptoKey =
      keyEncrypter.encryptBytes(signingKey.bytes, iv: secretKeyIV);
  _keyCipher = "${secretKeyIV.base64}:${cryptoKey.base64}";
}

/// [generateRecoveryPhrase] Generates a recovery phrase and uses that to encrypt the provided signingKey
/// The [_recovery] [_recoveryHash] and [_recoveryKeyCipher] are all modified by this method
Future _generateRecoveryPhrase(Key signingKey) async {
  Random rand = Random.secure();
  List<int> recIV = List<int>.generate(16, (index) => rand.nextInt(256));
  _recovery = Key.fromSecureRandom(20)
      .base64; // Generate random passphrase of sufficient length (stored for user)
  Argon2 hasher = Argon2(
      salt: recIV,
      hashLength: pwHashLength,
      iterations: iterations,
      parallelism: parallelPower,
      memorySizeKB: consumeMemory);
  Argon2HashDigest keyEncryptionKey =
      await thread.compute(hasher.convert, _recovery!.codeUnits);
  _recoveryHash = keyEncryptionKey.encoded();
  Encrypter keyEncrypter = Encrypter(
      AES(Key(Uint8List.fromList(keyEncryptionKey.bytes)), mode: AESMode.gcm));

  // Recovery key encryptor
  IV secretKeyIV = IV.fromSecureRandom(12);
  Encrypted cryptoKey =
      keyEncrypter.encryptBytes(signingKey.bytes, iv: secretKeyIV);
  _recoveryKeyCipher = "${secretKeyIV.base64}:${cryptoKey.base64}";
}

String compressContents() => hexEncode(utf8
    .encode("$_passwordHash#$_keyCipher#$_recoveryKeyCipher#$_recoveryHash"));

void save() {
  Map<String, String> x = {
    "data": compressContents(),
    "sig": sha512sum(compressContents()),
  };
  settings.setOtherSetting("enc", x);
}

void load() {
  Object? map = settings.getOtherSetting('enc');
  if (map != null && map is Map<String, dynamic>) {
    String data = map['data']!;
    List<String> actualData = utf8.decode(hexDecode(data)).split('#');

    String dataSig = sha512sum(data);
    String receivedSig = map['sig']!;
    data = "";
    map = {};
    if (dataSig != receivedSig) {
      dataSig = "";
      receivedSig = "";
      actualData.clear();
      throw Exception(
          "Signatures did not match, data integrity has been compromised!");
    }
    // Get the hash, salt is built into the hash
    _passwordHash = actualData[0];
    // Get the cipher
    _keyCipher = actualData[1];
    _recoveryKeyCipher = actualData[2];
    _recoveryHash = actualData[3];

    actualData.clear();
  }
}

void reset() {
  _encrypter = null;
  _passwordHash = "";
  _keyCipher = "";
  _recoveryKeyCipher = "";
  _recoveryHash = "";
  _recovery = "";
}

/// Password can be empty, this is only used if the password is supplied
bool validatePassword(String password) =>
    (password.length >= 10 && // length must be 10+      AND
        password.contains(
            RegExp(r'[!@#$%^&*()]+')) && // contains special char   AND
        password.contains(RegExp(r'\d+'))); // contains at least 1 num

/// This is used within any field that needs to validate a password input.
String? defaultValidator(String? value) => (value == null ||
        value.isEmpty ||
        validatePassword(value))
    ? null
    : "Passwords must have the following:\n1. 10 or more characters\n2. At least one special character\n3.at least one number (!@#\$%^&*())";

// Encryption -------------------------------------
String encrypt(String plainText) {
  IV secretIV = IV.fromSecureRandom(12);
  final encrypted = _encrypter!.encrypt(plainText, iv: secretIV);
  return '${secretIV.base64}:${encrypted.base64}';
}

String decrypt(String cipherTextb64) {
  List<String> package = cipherTextb64.split(":");
  IV secretIV = IV.fromBase64(package[0]);
  Encrypted cipherText = Encrypted.fromBase64(package[1]);
  final decrypted = _encrypter!.decrypt(cipherText, iv: secretIV);
  return decrypted;
}

// Encodings ---------------------------------------
String hexEncode(List<int> bytes) {
  const hexDigits = '0123456789abcdef';
  var charCodes = Uint8List(bytes.length * 2);
  for (var i = 0, j = 0; i < bytes.length; i++) {
    var byte = bytes[i];
    charCodes[j++] = hexDigits.codeUnitAt((byte >> 4) & 0xF);
    charCodes[j++] = hexDigits.codeUnitAt(byte & 0xF);
  }
  return String.fromCharCodes(charCodes);
}

List<int> hexDecode(String hexString) {
  var bytes = <int>[];
  for (var i = 0; i < hexString.length; i += 2) {
    var byte = int.parse(hexString.substring(i, i + 2), radix: 16);
    bytes.add(byte);
  }
  return bytes;
}
