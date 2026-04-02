import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';
import '../../../calculator/presentation/pages/calculator_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const AnalyticsPage(),
    const CalculatorPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        backgroundColor: AppTheme.primaryDarkColor,
        shape: const CircleBorder(),
        elevation: 4,
        child: Icon(Icons.add, size: 32.w, color: Colors.white),
      ),
      floatingActionButtonLocation: const _CustomFabLocation(),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        shadowColor: Colors.black45,
        surfaceTintColor: Colors.transparent,
        height: 90.h,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.list_alt, label: 'Records', index: 0),
              _buildNavItem(icon: Icons.pie_chart_outline, label: 'Chart', index: 1),
              SizedBox(width: 48.w), // Space for FAB
              _buildNavItem(icon: Icons.calculate_outlined, label: 'Calc', index: 2),
              _buildNavItem(icon: Icons.person_outline, label: 'Me', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryDarkColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.w),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _CustomFabLocation extends FloatingActionButtonLocation {
  const _CustomFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Get the standard centerDocked offset
    final Offset offset = FloatingActionButtonLocation.centerDocked.getOffset(scaffoldGeometry);
    // Shift the FAB down by 16 pixels
    return Offset(offset.dx, offset.dy + 16.0); 
  }
}
