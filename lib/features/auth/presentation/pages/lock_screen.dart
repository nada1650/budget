import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../features/main_nav/presentation/pages/main_page.dart';
import '../../../../injection_container.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final BiometricService _biometricService = sl<BiometricService>();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    bool authenticated = await _biometricService.authenticate();
    if (authenticated && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80.w, color: Theme.of(context).primaryColor),
            SizedBox(height: 24.h),
            Text('App Locked', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Please authenticate to continue', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: _checkAuth,
              icon: Icon(Icons.fingerprint, size: 24.w),
              label: Text('Unlock', style: TextStyle(fontSize: 16.sp)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
