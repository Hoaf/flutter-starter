import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockIAuthRepository mockRepo;
  late LoginUseCase useCase;

  const mockUser = UserEntity(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    age: 25,
    role: 'user',
  );

  setUp(() {
    mockRepo = MockIAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  group('LoginUseCase', () {
    test('returns Success when repository returns a user', () async {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => const Success(mockUser));

      final result = await useCase('testuser', 'password123');

      expect(result, isA<Success<UserEntity, String>>());
      final success = result as Success<UserEntity, String>;
      expect(success.value.username, 'testuser');
    });

    test('returns Failure when repository returns an error', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer(
          (_) async => const Failure('Invalid username or password'));

      final result = await useCase('testuser', 'wrongpass');

      expect(result, isA<Failure<UserEntity, String>>());
      final failure = result as Failure<UserEntity, String>;
      expect(failure.exception, 'Invalid username or password');
    });

    test('delegates to repository with correct arguments', () async {
      when(() => mockRepo.login('user1', 'pass1'))
          .thenAnswer((_) async => const Success(mockUser));

      await useCase('user1', 'pass1');

      verify(() => mockRepo.login('user1', 'pass1')).called(1);
    });
  });

  group('LogoutUseCase', () {
    late LogoutUseCase logoutUseCase;

    setUp(() {
      logoutUseCase = LogoutUseCase(mockRepo);
    });

    test('returns Success when logout succeeds', () async {
      when(() => mockRepo.logout())
          .thenAnswer((_) async => const Success(null));

      final result = await logoutUseCase();

      expect(result, isA<Success<void, String>>());
    });

    test('delegates to repository logout()', () async {
      when(() => mockRepo.logout())
          .thenAnswer((_) async => const Success(null));

      await logoutUseCase();

      verify(() => mockRepo.logout()).called(1);
    });
  });
}
