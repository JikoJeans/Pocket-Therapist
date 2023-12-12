import 'package:app/provider/encryptor.dart' as encrypter;
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("Testing hex encode and decode", () async {
    String message = "No ill never tell ;)";
    stdout.writeln(message);
    String hex = encrypter.hexEncode(message.codeUnits);
    stdout.writeln(hex);
    expect(message != hex, true);
    List<int> stringCodeUnits = encrypter.hexDecode(hex);
    String original = String.fromCharCodes(stringCodeUnits);
    stdout.writeln(original);
    expect(message == original, true);
  });
}
