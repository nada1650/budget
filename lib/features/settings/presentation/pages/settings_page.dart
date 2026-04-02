import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../cubit/theme_cubit.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../features/transactions/presentation/pages/categories_page.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../../../features/transactions/presentation/cubit/transactions_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isBiometricEnabled;
  late final Box _settingsBox;

  @override
  void initState() {
    super.initState();
    _settingsBox = sl<Box>(instanceName: 'settingsBox');
    _isBiometricEnabled = _settingsBox.get('isBiometricEnabled', defaultValue: false);
  }

  void _toggleBiometric(bool value) async {
    if (value) {
      // Trying to enable it, verify first
      final biometricService = sl<BiometricService>();
      bool available = await biometricService.isBiometricAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometrics not available or not setup on this device')),
          );
        }
        return;
      }
      // Authenticate to enable
      bool auth = await biometricService.authenticate();
      if (!auth) return;
    }

    _settingsBox.put('isBiometricEnabled', value);
    setState(() {
      _isBiometricEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
          final isDark = themeMode == ThemeMode.dark ||
              (themeMode == ThemeMode.system &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Text('Settings', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Dark Mode', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      subtitle: Text('Enable dark theme', style: TextStyle(fontSize: 12.sp)),
                      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 24.w),
                      value: isDark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme(value);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text('App Lock (Biometric)', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      subtitle: Text('Require fingerprint to open app', style: TextStyle(fontSize: 12.sp)),
                      secondary: Icon(Icons.fingerprint, size: 24.w),
                      value: _isBiometricEnabled,
                      onChanged: _toggleBiometric,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  leading: Icon(Icons.category, size: 24.w),
                  title: Text('Manage Categories', style: TextStyle(fontSize: 16.sp)),
                  subtitle: Text('Add or remove custom categories', style: TextStyle(fontSize: 12.sp)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.w),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesPage()),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Text('Cloud Sync', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    // Trigger initial sync when user logs in via settings
                    context.read<TransactionsCubit>().syncDataToCloud(state.user.id);
                  }
                },
                builder: (context, state) {
                  if (state is Authenticated) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              child: Text(state.user.displayName?[0].toUpperCase() ?? 'U',
                                  style: TextStyle(color: Theme.of(context).primaryColor)),
                            ),
                            title: Text(state.user.displayName ?? 'User', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            subtitle: Text(state.user.email ?? '', style: TextStyle(fontSize: 12.sp)),
                            trailing: IconButton(
                              icon: const Icon(Icons.logout, color: Colors.redAccent),
                              onPressed: () => context.read<AuthCubit>().logout(),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.sync),
                            title: const Text('Sync Data Now'),
                            subtitle: const Text('Update cloud with local changes'),
                            onTap: () => context.read<TransactionsCubit>().syncDataToCloud(state.user.id),
                          ),
                        ],
                      ),
                    );
                  } else if (state is AuthLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                  } else {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: ListTile(
                        leading: const Icon(Icons.cloud_upload_outlined),
                        title: const Text('Backup to Cloud'),
                        subtitle: const Text('Sign in to save your data permanently'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 16.h),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  leading: Icon(Icons.info, size: 24.w),
                  title: Text('About Expense Tracker', style: TextStyle(fontSize: 16.sp)),
                  subtitle: Text('Version 1.1.0 (Cloud Sync)', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
