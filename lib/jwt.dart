
import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateJWT(String apiKey, String apiSecret) {
  final header = {'alg': 'HS256', 'typ': 'JWT'};
  final payload = {
    'iss': apiKey,
    'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 // 1 hour expiry
  };

  final base64Header = base64UrlEncode(utf8.encode(json.encode(header)));
  final base64Payload = base64UrlEncode(utf8.encode(json.encode(payload)));
  final signature = Hmac(sha256, utf8.encode(apiSecret))
      .convert(utf8.encode('$base64Header.$base64Payload'))
      .toString();

  return '$base64Header.$base64Payload.$signature';
}
