import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "0";
  String _operand1 = "0";
  String _operand2 = "0";
  String _operator = "";

  void _buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _output = "0";
      _operand1 = "0";
      _operand2 = "0";
      _operator = "";
    } else if (buttonText == "⌫") {
      if (_output.length > 1) {
        _output = _output.substring(0, _output.length - 1);
      } else {
        _output = "0";
      }
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
      _operand1 = _output;
      _operator = buttonText;
      _output = "0";
    } else if (buttonText == "%") {
       double val = double.parse(_output);
       _output = (val / 100).toString();
       if (_output.endsWith(".0")) {
         _output = _output.substring(0, _output.length - 2);
       }
    } else if (buttonText == ".") {
      if (_output.contains(".")) {
        return;
      } else {
        _output = _output + buttonText;
      }
    } else if (buttonText == "=") {
      _operand2 = _output;
      double num1 = double.parse(_operand1);
      double num2 = double.parse(_operand2);

      if (_operator == "+") {
        _output = (num1 + num2).toString();
      }
      if (_operator == "-") {
        _output = (num1 - num2).toString();
      }
      if (_operator == "×") {
        _output = (num1 * num2).toString();
      }
      if (_operator == "÷") {
        _output = (num1 / num2).toString();
      }

      _operand1 = "0";
      _operand2 = "0";
      _operator = "";
      
      if (_output.endsWith(".0")) {
        _output = _output.substring(0, _output.length - 2);
      }
    } else {
      if (_output == "0") {
        _output = buttonText;
      } else {
        _output = _output + buttonText;
      }
    }

    setState(() {});
  }

  Widget _buildButton(String buttonText, Color textColor, {Color? bgColor}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(6.w),
        height: 64.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? Theme.of(context).cardColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Calculator', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_operator.isNotEmpty) 
                   Text(
                     '$_operand1 $_operator', 
                     style: TextStyle(fontSize: 20.sp, color: Colors.grey)
                   ),
                SizedBox(height: 8.h),
                Text(
                  _output,
                  style: TextStyle(
                    fontSize: 56.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2D3748) : Colors.grey.shade100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton("C", Colors.redAccent),
                    _buildButton("⌫", Colors.orange),
                    _buildButton("%", primaryColor),
                    _buildButton("÷", primaryColor),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("7", Theme.of(context).colorScheme.onSurface),
                    _buildButton("8", Theme.of(context).colorScheme.onSurface),
                    _buildButton("9", Theme.of(context).colorScheme.onSurface),
                    _buildButton("×", primaryColor),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("4", Theme.of(context).colorScheme.onSurface),
                    _buildButton("5", Theme.of(context).colorScheme.onSurface),
                    _buildButton("6", Theme.of(context).colorScheme.onSurface),
                    _buildButton("-", primaryColor),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("1", Theme.of(context).colorScheme.onSurface),
                    _buildButton("2", Theme.of(context).colorScheme.onSurface),
                    _buildButton("3", Theme.of(context).colorScheme.onSurface),
                    _buildButton("+", primaryColor),
                  ],
                ),
                Row(
                  children: [
                    _buildButton(".", Theme.of(context).colorScheme.onSurface),
                    _buildButton("0", Theme.of(context).colorScheme.onSurface),
                    _buildButton("00", Theme.of(context).colorScheme.onSurface),
                    _buildButton("=", Colors.white, bgColor: primaryColor),
                  ],
                ),
                SizedBox(height: 16.h), 
              ],
            ),
          )
        ],
      ),
      ),
    );
  }
}
