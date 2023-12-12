import 'package:app/provider/encryptor.dart' as encrypter;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test("Testing encryption and decryption", () async {
    String message = "No ill never tell ;)";
    String password = "password123@";
    // After setting the password we should be able to encrypt and decrypt
    await encrypter.setPassword(password);
    String recoveryPhrase1 = encrypter.getRecoveryPhrase()!;

    // reset unlocks with all combinations
    bool value = await encrypter.verifyPassword(password);
    await expectLater(value, true);
    value = await encrypter.unlock(password);
    await expectLater(value, true);
    value = await encrypter.unlock(recoveryPhrase1);
    await expectLater(value, false); // fails because not in recovery mode
    value = await encrypter.unlock(recoveryPhrase1, true);
    await expectLater(value, true);
    value = await encrypter.verifyRecoveryPhrase(recoveryPhrase1);
    await expectLater(value, true);

    String cipher = encrypter.encrypt(message);
    await expectLater(cipher != message, true);
    String decrypted = encrypter.decrypt(cipher);
    await expectLater(decrypted == message, true);

    // Erase the encryption key
    bool diff = !await encrypter.resetCredentials("${password}diff");
    await expectLater(diff, true); // fail to erase cause wrong password

    await encrypter.setPassword(password); // reset w/ savme password
    String recoveryPhrase2 = encrypter.getRecoveryPhrase()!;
    await expectLater(recoveryPhrase1 != recoveryPhrase2,
        true); // should be different recovery phrases
    diff = !await encrypter
        .resetCredentials(recoveryPhrase2); // reset with the passphrase
    // If password isnt set then we will have no password.
    await expectLater(diff, false);
    await encrypter.setPassword(password); // reset the pasword
    cipher = encrypter.encrypt(message);

    encrypter.save();

    // Encryption key is encrypted inside this, w/ PBKDF
    await expectLater(
        () => encrypter.load(), returnsNormally); // load the encryption key

    // This will overwrite the encrypter with something else, so
    // If it can still decrypt the original cipher text, then it is correct.
    bool valid = await encrypter.unlock(password);
    await expectLater(valid, true);
    decrypted = encrypter.decrypt(cipher);
    await expectLater(decrypted == message, true);
    //6 minutes is minimum time test needs to complete
  }, timeout: const Timeout(Duration(minutes: 5)));
}
