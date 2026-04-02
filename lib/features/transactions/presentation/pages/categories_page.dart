import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/transactions_cubit.dart';
import '../cubit/transactions_state.dart';
import 'add_category_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

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
                  IconButton(icon: Icon(Icons.arrow_back, size: 24.w), onPressed: () => Navigator.pop(context)),
                  SizedBox(width: 8.w),
                  Text('Manage Categories', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TransactionsCubit, TransactionsState>(
                builder: (context, state) {
                  if (state is TransactionsLoaded) {
                    final categories = state.categories;
                    if (categories.isEmpty) {
                      return Center(child: Text('No categories yet.', style: TextStyle(fontSize: 16.sp)));
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(cat.colorValue).withValues(alpha: 0.2),
                      child: Icon(Icons.category, color: Color(cat.colorValue)),
                    ),
                    title: Text(cat.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        context.read<TransactionsCubit>().removeCategory(cat.id);
                      },
                    ),
                  ),
                );
              },
            );
          }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCategoryPage()),
          );
        },
        child: Icon(Icons.add, size: 28.w),
      ),
    );
  }
}
