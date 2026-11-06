import 'dart:io';

void main() {
  print('--- Welcome to the 5th Grade Math Quiz! ---');
  print('Question 1: What is 15 % 4? (Hint: Find the remainder)');
  
  // Reading the user's input from the terminal
  String? userInput = stdin.readLineSync();
  
  // Using the == relational operator to check the answer
  if (userInput == '3') {
    print('Correct! Great job.');
  } else {
    print('Oops! The correct answer is 3.');
  }
}