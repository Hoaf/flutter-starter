import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_demo/core/models/result.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_event.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late MockLoginUseCase mockUseCase;
  late LoginBloc bloc;

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
    mockUseCase = MockLoginUseCase();
    bloc = LoginBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('LoginBloc', () {
    test('initial state is LoginInitial', () {
      expect(bloc.state, const LoginInitial());
    });

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginSuccess] on successful login',
      build: () {
        when(() => mockUseCase(any(), any()))
            .thenAnswer((_) async => const Success(mockUser));
        return bloc;
      },
      act: (b) => b.add(const LoginSubmitEvent(
          username: 'testuser', password: 'password123')),
      expect: () => [
        const LoginLoading(),
        const LoginSuccess(user: mockUser),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginFailure] on wrong password',
      build: () {
        when(() => mockUseCase(any(), any())).thenAnswer(
            (_) async => const Failure('Invalid username or password'));
        return bloc;
      },
      act: (b) => b.add(const LoginSubmitEvent(
          username: 'testuser', password: 'wrongpassword')),
      expect: () => [
        const LoginLoading(),
        const LoginFailure(message: 'Invalid username or password'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginFailure] immediately when username is empty (no API call)',
      build: () => bloc,
      act: (b) =>
          b.add(const LoginSubmitEvent(username: '', password: 'pass')),
      expect: () => [
        const LoginFailure(
            message: 'Please enter your username and password'),
      ],
      verify: (_) => verifyNever(() => mockUseCase(any(), any())),
    );
  });
}
