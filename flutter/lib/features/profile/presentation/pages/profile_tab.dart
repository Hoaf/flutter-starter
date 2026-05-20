import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';
import 'package:flutter_demo/presentation/routes/routers.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_demo/features/profile/presentation/cubit/profile_state.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoggedOut) {
          Navigator.pushReplacementNamed(context, AppRouter.loginRoute);
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state is ProfileLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.cyan),
                    ),
                  )
                else if (state is ProfileError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.paleSky),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: AppFontSizes.fs_14,
                            color: AppColors.paleSky,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () =>
                              context.read<ProfileCubit>().loadProfile(),
                          icon: const Icon(Icons.refresh,
                              color: AppColors.cyan),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: AppColors.cyan),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (state is ProfileLoaded)
                  _buildProfileContent(context, state.user),

                const SizedBox(height: 16),

                // Logout button (always visible)
                _logoutButton(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserEntity user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Avatar card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar circle with initials
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.cyan,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shark,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: const TextStyle(
                  fontSize: AppFontSizes.fs_12,
                  color: AppColors.paleSky,
                ),
              ),
              const SizedBox(height: 10),
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cyanLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: AppFontSizes.fs_12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cyan,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Account details card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Details',
                style: TextStyle(
                  fontSize: AppFontSizes.fs_15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shark,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const SizedBox(height: 12),
              _fieldRow('Email', user.email, readOnly: true),
              _fieldRow('First Name', user.firstName),
              _fieldRow('Last Name', user.lastName),
              _fieldRow('Age', '${user.age}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldRow(String label, String value, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppFontSizes.fs_12,
              fontWeight: FontWeight.w500,
              color: AppColors.paleSky,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: readOnly
                  ? AppColors.lightGrey
                  : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppFontSizes.fs_14,
                color: readOnly ? AppColors.paleSky : AppColors.shark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context, ProfileState state) {
    final isLoggingOut = state is ProfileLoading;
    return GestureDetector(
      onTap: isLoggingOut
          ? null
          : () => context.read<ProfileCubit>().logout(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.redSec,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🚪', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: AppFontSizes.fs_14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ),
            const Text(
              '›',
              style: TextStyle(fontSize: 20, color: Color(0xFFBDBDBD)),
            ),
          ],
        ),
      ),
    );
  }
}
