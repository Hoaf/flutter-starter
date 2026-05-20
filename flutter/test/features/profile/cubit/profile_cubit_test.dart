import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockGetUserProfileUseCase mockGetProfile;
  late MockLogoutUseCase mockLogout;
  late ProfileCubit cubit;

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
    mockGetProfile = MockGetUserProfileUseCase();
    mockLogout = MockLogoutUseCase();
    cubit = ProfileCubit(mockGetProfile, mockLogout);
  });

  tearDown(() => cubit.close());

  group('ProfileCubit', () {
    test('initial state is ProfileInitial', () {
      expect(cubit.state, const ProfileInitial());
    });

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] on successful profile load',
      build: () {
        when(() => mockGetProfile())
            .thenAnswer((_) async => const Success(mockUser));
        return cubit;
      },
      act: (c) => c.loadProfile(),
      expect: () => [
        const ProfileLoading(),
        const ProfileLoaded(user: mockUser),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] on API error',
      build: () {
        when(() => mockGetProfile()).thenAnswer(
            (_) async => const Failure('Failed to load user profile'));
        return cubit;
      },
      act: (c) => c.loadProfile(),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Failed to load user profile'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoggedOut] after logout()',
      build: () {
        when(() => mockLogout())
            .thenAnswer((_) async => const Success(null));
        return cubit;
      },
      act: (c) => c.logout(),
      expect: () => [const ProfileLoggedOut()],
    );
  });
}
