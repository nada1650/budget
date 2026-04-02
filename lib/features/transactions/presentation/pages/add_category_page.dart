import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../cubit/transactions_cubit.dart';
import '../../domain/entities/category.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final List<int> _colors = [
    0xFFFFE0B2, 0xFFBBDEFB, 0xFFE1BEE7, 0xFFB2EBF2, 0xFFDCEDC8,
    0xFFFFCC80, 0xFFB2DFDB, 0xFFF8BBD0, 0xFFCFD8DC, 0xFFD7CCC8
  ];
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors[0];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newCategory = TransactionCategory(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        iconFolder: 'custom', // custom generic icon folder marker
        colorValue: _selectedColor,
      );

      context.read<TransactionsCubit>().addNewCategory(newCategory);
      Navigator.pop(context); // Pop AddCategory
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
                  Text('New Category', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                          ),
                          prefixIcon: Icon(Icons.label, size: 24.w, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter a name';
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      Text('Select Color', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16.h),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        alignment: WrapAlignment.center,
                        children: _colors.map((colorVal) {
                          final isSelected = _selectedColor == colorVal;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = colorVal;
                              });
                            },
                            child: CircleAvatar(
                              radius: 24.r,
                              backgroundColor: Color(colorVal),
                              child: isSelected ? Icon(Icons.check, color: Colors.black87, size: 28.w) : null,
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 32.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          backgroundColor: Color(_selectedColor),
                        ),
                        onPressed: _submitForm,
                        child: Text('Save Category', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
