import 'dart:math';

//Generates random Id
String generateRandomNoteId() {
  Random random = Random();
  int min = 100000; // Minimum 6-digit number
  int max = 999999; // Maximum 6-digit number
  int randomNumber = min + random.nextInt(max - min);
  return randomNumber.toString();
}
