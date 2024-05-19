import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

String generateHmacSha256(String key, String message) {
  final keyBytes = utf8.encode(key);
  final messageBytes = utf8.encode(message);

  final hmacSha256 = Hmac(sha256, keyBytes);
  final digest = hmacSha256.convert(messageBytes);

  return digest.toString(); // This returns the digest as a hex string
}

void myLaunchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
