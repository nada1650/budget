import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../cubit/transactions_cubit.dart';
import '../cubit/transactions_state.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();
  TransactionCategory? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text) ?? 0.0;
      
      final newTransaction = TransactionEntity(
        id: const Uuid().v4(),
        amount: amount,
        date: _selectedDate,
        type: _selectedType,
        category: _selectedCategory!,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      context.read<TransactionsCubit>().addNewTransaction(newTransaction);
      Navigator.of(context).pop();
    }
  }

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
                  Text('Add Transaction', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TransactionsCubit, TransactionsState>(
                builder: (context, state) {
          if (state is TransactionsLoaded) {
            // Filter categories based on type if needed, but for MVP we use all
            final categories = state.categories;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Transaction Type Selector
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                        ButtonSegment(value: TransactionType.income, label: Text('Income')),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (Set<TransactionType> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                        });
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Amount Input
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money, size: 24.w),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter amount';
                        if (double.tryParse(value) == null) return 'Enter valid number';
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Category Dropdown
                    DropdownButtonFormField<TransactionCategory>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category, size: 24.w),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12.r,
                                backgroundColor: Color(cat.colorValue).withValues(alpha: 0.2),
                                child: Icon(Icons.label, color: Color(cat.colorValue), size: 14.w), // Fallback icon
                              ),
                              SizedBox(width: 8.w),
                              Text(cat.name, style: TextStyle(fontSize: 16.sp)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Date Picker
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      leading: Icon(Icons.calendar_today, size: 24.w),
                      title: Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: TextStyle(fontSize: 16.sp)),
                      trailing: Text('Change', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.sp)),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != _selectedDate) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Note Input
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: Icon(Icons.notes, size: 24.w),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 32.h),

                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: _selectedType == TransactionType.income ? AppTheme.incomeColor : AppTheme.expenseColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: _submitForm,
                      child: Text('Save Transaction', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
