import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtils {
  // Hashes the password using SHA-256 algorithm
  static String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Apply SHA-256 hash function
    return digest.toString(); // Convert digest to string
  }

  // Compares the given password with the hashed password
  static bool comparePasswords(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }
}
