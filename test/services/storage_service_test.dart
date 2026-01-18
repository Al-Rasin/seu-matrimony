import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seu_matrimony/core/services/storage_service.dart';
import 'package:seu_matrimony/core/constants/storage_keys.dart';

@GenerateMocks([GetStorage])
import 'storage_service_test.mocks.dart';

void main() {
  late StorageService storageService;
  late MockGetStorage mockStorage;

  setUp(() {
    mockStorage = MockGetStorage();
    storageService = StorageService(box: mockStorage);
  });

  group('StorageService Tests', () {
    test('isLoggedIn should return true if storage has true', () {
      when(mockStorage.read<bool>(StorageKeys.isLoggedIn)).thenReturn(true);
      expect(storageService.isLoggedIn, isTrue);
    });

    test('isLoggedIn should return false if storage is null', () {
      when(mockStorage.read<bool>(StorageKeys.isLoggedIn)).thenReturn(null);
      expect(storageService.isLoggedIn, isFalse);
    });

    test('set isLoggedIn should write to storage', () {
      storageService.isLoggedIn = true;
      verify(mockStorage.write(StorageKeys.isLoggedIn, true)).called(1);
    });

    test('userId should be readable and writable', () {
      when(mockStorage.read<String>(StorageKeys.userId)).thenReturn('user_123');
      expect(storageService.userId, 'user_123');

      storageService.userId = 'user_456';
      verify(mockStorage.write(StorageKeys.userId, 'user_456')).called(1);
    });

    test('clearAuthData should remove all auth keys', () async {
      await storageService.clearAuthData();
      
      verify(mockStorage.remove(StorageKeys.accessToken)).called(1);
      verify(mockStorage.remove(StorageKeys.userId)).called(1);
      verify(mockStorage.remove(StorageKeys.isLoggedIn)).called(1);
    });
  });
}
