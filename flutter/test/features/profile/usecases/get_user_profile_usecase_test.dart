import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/profile/domain/repositories/i_user_repository.dart';
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIUserRepository extends Mock implements IUserRepository {}

void main() {
  late MockIUserRepository mockRepo;
  late GetUserProfileUseCase useCase;

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
    mockRepo = MockIUserRepository();
    useCase = GetUserProfileUseCase(mockRepo);
  });

  group('GetUserProfileUseCase', () {
    test('returns Success with user when repository succeeds', () async {
      when(() => mockRepo.getProfile())
          .thenAnswer((_) async => const Success(mockUser));

      final result = await useCase();

      expect(result, isA<Success<UserEntity, String>>());
      final success = result as Success<UserEntity, String>;
      expect(success.value.username, 'testuser');
    });

    test('returns Failure when repository fails', () async {
      when(() => mockRepo.getProfile()).thenAnswer(
          (_) async => const Failure('Failed to load user profile'));

      final result = await useCase();

      expect(result, isA<Failure<UserEntity, String>>());
      final failure = result as Failure<UserEntity, String>;
      expect(failure.exception, 'Failed to load user profile');
    });

    test('delegates to repository getProfile()', () async {
      when(() => mockRepo.getProfile())
          .thenAnswer((_) async => const Success(mockUser));

      await useCase();

      verify(() => mockRepo.getProfile()).called(1);
    });
  });
}
