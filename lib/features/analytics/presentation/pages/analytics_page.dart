import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../features/transactions/presentation/cubit/transactions_cubit.dart';
import '../../../../features/transactions/presentation/cubit/transactions_state.dart';
import '../../../../features/transactions/domain/entities/transaction.dart';
import '../../../../core/theme/app_theme.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionsLoaded) {
            if (state.transactions.isEmpty) {
              return Center(child: Text('No data to display.', style: TextStyle(fontSize: 16.sp)));
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Analytics', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  Text('Expenses by Category', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  _buildPieChart(context, state.transactions),
                  SizedBox(height: 32.h),
                  Text('Income vs Expense (Last 6 Months)', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  _buildBarChart(context, state.transactions),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, List<TransactionEntity> transactions) {
    // Calculate expenses per category
    final Map<String, double> categoryExpenses = {};
    final Map<String, int> categoryColors = {};

    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        categoryExpenses[t.category.name] = (categoryExpenses[t.category.name] ?? 0) + t.amount;
        categoryColors[t.category.name] = t.category.colorValue;
      }
    }

    if (categoryExpenses.isEmpty) {
      return Center(child: Text('No expenses recorded.', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))));
    }

    // Prepare data for fl_chart
    List<PieChartSectionData> sections = [];

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    categoryExpenses.forEach((key, value) {
      Color baseColor = Color(categoryColors[key]!);
      Color displayColor = isDarkMode ? Color.lerp(baseColor, Colors.black, 0.2)! : baseColor;

      sections.add(
        PieChartSectionData(
          color: displayColor,
          value: value,
          title: key,
          radius: 60.r,
          titleStyle: TextStyle(
            fontSize: 12.sp, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 2)],
          ),
        ),
      );
    });

    return SizedBox(
      height: 200.h,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40.r,
          sectionsSpace: 2,
        ),
        swapAnimationDuration: Duration.zero,
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<TransactionEntity> transactions) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final incomeColor = isDarkMode ? Color.lerp(AppTheme.incomeColor, Colors.black, 0.2)! : AppTheme.incomeColor;
    final expenseColor = isDarkMode ? Color.lerp(AppTheme.expenseColor, Colors.black, 0.2)! : AppTheme.expenseColor;

    // Example fixed to Current Month for MVP (can expand to 6 months)
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) totalIncome += t.amount;
      if (t.type == TransactionType.expense) totalExpense += t.amount;
    }

    return SizedBox(
      height: 200.h,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Income', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12.sp, fontWeight: FontWeight.bold));
                    case 1:
                      return Text('Expense', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12.sp, fontWeight: FontWeight.bold));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: totalIncome, color: incomeColor, width: 20.w, borderRadius: BorderRadius.circular(6.r))],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: totalExpense, color: expenseColor, width: 20.w, borderRadius: BorderRadius.circular(6.r))],
            ),
          ],
        ),
        swapAnimationDuration: Duration.zero,
      ),
    );
  }
}
