import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../cubit/transactions_cubit.dart';
import '../cubit/transactions_state.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterType = 'All'; // All, Income, Expense
  DateTimeRange? _selectedDateRange;
  TransactionCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 24.w),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8.w),
                  Text('History', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.date_range, size: 24.w),
                    onPressed: () async {
                      final pickedRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        initialDateRange: _selectedDateRange,
                      );
                      if (pickedRange != null) {
                        setState(() {
                          _selectedDateRange = pickedRange;
                        });
                      }
                    },
                  ),
                  if (_selectedDateRange != null)
                    IconButton(
                      icon: Icon(Icons.clear, size: 24.w),
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TransactionsCubit, TransactionsState>(
                builder: (context, state) {
                  if (state is TransactionsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TransactionsLoaded) {
                    return Column(
                      children: [
                        _buildFilters(state.categories),
                        Expanded(child: _buildTransactionList(state.transactions)),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<TransactionCategory> categories) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterType,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              items: ['All', 'Income', 'Expense']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14.sp))))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _filterType = val ?? 'All';
                });
              },
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: DropdownButtonFormField<TransactionCategory?>(
              value: _selectedCategory,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                hintText: 'Category',
              ),
              items: [
                DropdownMenuItem<TransactionCategory?>(value: null, child: Text('All Categories', style: TextStyle(fontSize: 14.sp))),
                ...categories.map((cat) => DropdownMenuItem<TransactionCategory?>(
                      value: cat,
                      child: Text(cat.name, style: TextStyle(fontSize: 14.sp)),
                    )),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionEntity> allTransactions) {
    // Apply filters
    List<TransactionEntity> filtered = allTransactions.where((t) {
      bool passType = true;
      if (_filterType == 'Income') passType = t.type == TransactionType.income;
      if (_filterType == 'Expense') passType = t.type == TransactionType.expense;

      bool passRange = true;
      if (_selectedDateRange != null) {
        passRange = t.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }

      bool passCategory = true;
      if (_selectedCategory != null) {
        passCategory = t.category.id == _selectedCategory!.id;
      }

      return passType && passRange && passCategory;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('No transactions found.', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        final tr = filtered[index];
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
                color: Color(tr.category.colorValue).withValues(alpha: 0.8),
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
