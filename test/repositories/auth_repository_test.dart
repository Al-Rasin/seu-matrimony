import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:seu_matrimony/core/services/storage_service.dart';
import 'package:seu_matrimony/core/services/auth_service.dart';
import 'package:seu_matrimony/core/services/mock_data_service.dart';
import 'package:seu_matrimony/data/repositories/auth_repository.dart';
import 'package:seu_matrimony/data/models/user_model.dart';

@GenerateNiceMocks([
  MockSpec<StorageService>(),
  MockSpec<AuthService>(),
  MockSpec<MockDataService>(),
])
import 'auth_repository_test.mocks.dart';

void main() {
  late AuthRepository authRepository;
  late MockStorageService mockStorage;
  late MockAuthService mockAuthService;
  late MockMockDataService mockMockData;

  setUp(() {
    mockStorage = MockStorageService();
    mockAuthService = MockAuthService();
    mockMockData = MockMockDataService();

    authRepository = AuthRepository(
      storageService: mockStorage,
      authService: mockAuthService,
      mockDataService: mockMockData,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthRepository Tests', () {
    test('login should use Firebase when mock data is disabled', () async {
      // Setup
      when(mockAuthService.signInWithEmail(email: 'test@seu.edu', password: 'password'))
          .thenAnswer((_) async => AuthResult.success(null, userData: {
                'id': 'user_123',
                'email': 'test@seu.edu',
                'fullName': 'Test User',
              }));

      // Action
      final user = await authRepository.login(email: 'test@seu.edu', password: 'password');

      // Verify
      expect(user.email, 'test@seu.edu');
      expect(user.fullName, 'Test User');
      verify(mockAuthService.signInWithEmail(email: 'test@seu.edu', password: 'password')).called(1);
      verify(mockStorage.isLoggedIn = true).called(1);
    });

    test('login should throw exception on failure', () async {
      // Setup
      when(mockAuthService.signInWithEmail(email: 'test@seu.edu', password: 'wrong'))
          .thenAnswer((_) async => AuthResult.failure('Invalid credentials'));

      // Action & Verify
      expect(
        () => authRepository.login(email: 'test@seu.edu', password: 'wrong'),
        throwsException,
      );
    });

    test('logout should clear storage and sign out from firebase', () async {
      await authRepository.logout();

      verify(mockAuthService.signOut()).called(1);
      verify(mockStorage.clearAuthData()).called(1);
    });
  });
}
