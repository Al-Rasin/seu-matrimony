import 'package:flutter_test/flutter_test.dart';
import 'package:seu_matrimony/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('required validator should return error message if value is null or empty', () {
      expect(Validators.required(null), 'This field is required');
      expect(Validators.required(''), 'This field is required');
      expect(Validators.required('  '), 'This field is required');
      expect(Validators.required('Test'), isNull);
    });

    test('email validator should return error for invalid emails', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email('invalid-email'), 'Please enter a valid email address');
      expect(Validators.email('test@example'), 'Please enter a valid email address');
      expect(Validators.email('test@example.com'), isNull);
    });

    test('password validator should return error if password is too short', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password('12345'), 'Password must be at least 6 characters');
      expect(Validators.password('123456'), isNull);
    });

    test('phone validator should return error for invalid Bangladesh numbers', () {
      expect(Validators.phone(null), 'Phone number is required');
      expect(Validators.phone('1234567890'), 'Please enter a valid phone number');
      expect(Validators.phone('0171234567'), 'Please enter a valid phone number'); // Too short
      expect(Validators.phone('01712345678'), isNull);
      expect(Validators.phone('+8801712345678'), isNull);
    });

    test('seuStudentId validator should return error for invalid format', () {
      expect(Validators.seuStudentId(null), 'Student ID is required');
      expect(Validators.seuStudentId('2020160001'), 'Please enter a valid SEU Student ID (e.g., 2020-1-60-001)');
      expect(Validators.seuStudentId('2020-1-60-001'), isNull);
    });

    test('age validator should return error for values outside range', () {
      expect(Validators.age(null), 'Age is required');
      expect(Validators.age('17'), 'You must be at least 18 years old');
      expect(Validators.age('101'), 'Please enter a valid age');
      expect(Validators.age('25'), isNull);
    });
  });
}
