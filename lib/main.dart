import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.fredokaTextTheme(textTheme).copyWith(
        bodyLarge: GoogleFonts.fredoka(textStyle: textTheme.bodyLarge),
        ),
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = "";
  String _result = "";
  bool _isDarkMode = true; // Variabel untuk menyimpan status tema

  void _evaluateExpression() {
    try {
      if (_expression.isNotEmpty) {
        Parser p = Parser();
        Expression exp = p.parse(_expression.replaceAll('x', '*'));
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);
        _result = eval % 1 == 0 ? eval.toInt().toString() : eval.toString();
      }
    } catch (e) {
      if (!_expression.contains(RegExp(r'[0-9]$'))) {
        _result = _expression;
      } else {
        _result = "Error";
      }
    }
    setState(() {});
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "";
      } else if (value == "DEL") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == "%") {
        if (_expression.isNotEmpty) {
          _expression += "/100";
        }
      } else if (value == "=") {
        if (_result.isNotEmpty) {
          _expression = _result;
        }
      } else {
        _expression += value;
      }
      _evaluateExpression();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode; // Ganti status tema
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          _expression,
                          key: ValueKey(_expression),
                          style: TextStyle(fontSize: 50, color: _isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _buildButtons(),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay, color: _isDarkMode ? Colors.white : Colors.black),
              onPressed: _toggleTheme,
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.functions, color: _isDarkMode ? Colors.white : Colors.black),
              onPressed: _toggleTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final buttons = [
      ["C", "÷", "x", "DEL"],
      ["7", "8", "9", "-"],
      ["4", "5", "6", "+"],
      ["1", "2", "3", "%"],
      [".", "0", "00", "="]
    ];

    return Column(
      children: buttons.asMap().entries.map((entry) {
        int rowIndex = entry.key;
        List<String> row = entry.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((btn) {
            if (btn == "=" && rowIndex >= 3) {
              return Expanded(
                child: _buildButton(btn, color: const Color.fromARGB(255, 51, 119, 54), heightFactor: 1),
              );
            } else if (btn.isEmpty) {
              return SizedBox(width: 0); // Empty space for alignment
            } else {
              return _buildButton(
                btn,
                color: btn == "C"
                    ? Colors.red
                    : (btn == "÷" || btn == "x" || btn == "-" || btn == "+" || btn == "DEL" || btn == "%")
                        ? Colors.green
                        : const Color.fromARGB(0, 255, 255, 255),
              );
            }
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String value, {Color? color, int heightFactor = 1}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(value),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(vertical: 24.0 * heightFactor),
            backgroundColor: color ?? const Color.fromARGB(0, 66, 66, 66),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24.0,
              color: (_isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}