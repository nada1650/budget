import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../features/transactions/presentation/cubit/transactions_cubit.dart';
import '../../../../features/transactions/presentation/cubit/transactions_state.dart';
import '../../../../features/transactions/domain/entities/transaction.dart';
import '../../../../features/transactions/presentation/pages/history_page.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
          if (state is TransactionsLoading || state is TransactionsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionsError) {
            return Center(child: Text(state.message, style: TextStyle(fontSize: 14.sp)));
          } else if (state is TransactionsLoaded) {
            return _buildDashboardContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, TransactionsLoaded state) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    double overallIncome = 0;
    double overallExpense = 0;
    
    double monthlyIncome = 0;
    double monthlyExpense = 0;
    
    List<TransactionEntity> monthlyTransactions = [];

    for (var t in state.transactions) {
      if (t.type == TransactionType.income) overallIncome += t.amount;
      if (t.type == TransactionType.expense) overallExpense += t.amount;

      if (t.date.year == _currentMonth.year && t.date.month == _currentMonth.month) {
        monthlyTransactions.add(t);
        if (t.type == TransactionType.income) monthlyIncome += t.amount;
        if (t.type == TransactionType.expense) monthlyExpense += t.amount;
      }
    }
    
    double totalBalance = overallIncome - overallExpense;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransactionsCubit>().loadData();
      },
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildMonthSelector(context),
          SizedBox(height: 24.h),
          _buildBalanceSection(context, currencyFormat, totalBalance),
          SizedBox(height: 24.h),
          _buildIncomeExpenseCards(context, monthlyIncome, monthlyExpense),
          SizedBox(height: 32.h),
          _buildBudgetProgress(context, monthlyExpense, monthlyIncome > 0 ? monthlyIncome : 2000.0),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transactions', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryPage()),
                  );
                },
                child: Text('See All', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.sp)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildRecentTransactions(monthlyTransactions),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Theme.of(context).colorScheme.surface : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _previousMonth,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(Icons.arrow_back_ios_new, size: 18.w, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18.w, color: Theme.of(context).colorScheme.onSurface),
              SizedBox(width: 8.w),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          InkWell(
            onTap: _nextMonth,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(Icons.arrow_forward_ios, size: 18.w, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context, NumberFormat format, double balance) {
    return Column(
      children: [
        Text('Total Balance', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        SizedBox(height: 8.h),
        Text(format.format(balance), style: TextStyle(
          fontSize: 32.sp, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).colorScheme.onSurface,
        )),
      ],
    );
  }

  Widget _buildIncomeExpenseCards(BuildContext context, double income, double expense) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context: context,
            title: 'Income',
            amount: income,
            amountColor: AppTheme.incomeColor,
            icon: Icons.south_west,
            iconColor: AppTheme.incomeColor,
            bgColor: AppTheme.incomeColor.withValues(alpha: 0.1),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildSummaryCard(
            context: context,
            title: 'Expense',
            amount: expense,
            amountColor: AppTheme.expenseColor,
            icon: Icons.north_east,
            iconColor: AppTheme.expenseColor,
            bgColor: AppTheme.expenseColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required double amount,
    required Color amountColor,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Theme.of(context).colorScheme.surface : Colors.white;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.w, color: iconColor),
              ),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
          SizedBox(height: 12.h),
          Text(NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount), style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: amountColor,
          )),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(BuildContext context, double currentExpense, double budgetLimit) {
    final double percentage = (currentExpense / budgetLimit).clamp(0.0, 1.0);
    final Color progressColor = percentage > 0.8 ? Colors.orange : (percentage >= 1.0 ? AppTheme.expenseColor : AppTheme.primaryColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Budget', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 10.h,
          borderRadius: BorderRadius.circular(8.r),
        ),
        SizedBox(height: 4.h),
        Text('${(percentage * 100).toStringAsFixed(1)}% used of \$${budgetLimit.toStringAsFixed(0)}', style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildRecentTransactions(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text('No transactions yet.', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        ),
      );
    }

    final recent = transactions.take(5).toList();
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recent.length,
      itemBuilder: (context, index) {
        final tr = recent[index];
        final isIncome = tr.type == TransactionType.income;
        IconData catIcon = Icons.category;
        
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            leading: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Color(tr.category.colorValue).withValues(alpha: 0.8), // Using pastel color
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(catIcon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 20.w),
            ),
            title: Text(tr.category.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(tr.date), style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                if (tr.note != null && tr.note!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(tr.note!, style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}\$${tr.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}

