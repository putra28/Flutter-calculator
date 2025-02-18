import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 43, 39, 44),
        textTheme: GoogleFonts.fredokaTextTheme(textTheme).copyWith(
          bodyLarge: GoogleFonts.fredoka(
            textStyle: textTheme.bodyLarge,
            fontSize: height * 0.05,
          ),
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
  late AnimationController localAnimationController;
  String _expression = "";
  String _result = "";
  bool _isDarkMode = true;
  bool _isHistoryOpen = false;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history);
  }

  void _addToHistory(String expression, String result) {
    String entry = "$expression = $result";
    setState(() {
      _history.insert(0, entry);
    });
    _saveHistory();
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    _saveHistory();
  }

  void _removeHistoryItem(int index) {
    setState(() {
      _history.removeAt(index);
    });
    _saveHistory();
  }

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

  void _evaluateExpressionwithHistory() {
    try {
      if (_expression.isNotEmpty) {
        Parser p = Parser();
        Expression exp = p.parse(_expression.replaceAll('x', '*'));
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);
        _result = eval % 1 == 0 ? eval.toInt().toString() : eval.toString();
        _addToHistory(_expression, _result);
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
          _evaluateExpressionwithHistory();
          _expression = _result;
        }
      } else {
        _expression += value;
      }
      _evaluateExpression();
    });
  }

  void _toggleHistory() {
    setState(() {
      _isHistoryOpen = !_isHistoryOpen;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode; // Ganti status tema
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color.fromARGB(255, 47, 55, 73) : const Color.fromARGB(255, 235, 235, 235),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _expression));
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.success(
                              message: "Copied!!",
                            ),
                            displayDuration: const Duration(milliseconds: 30),
                            onAnimationControllerInit: (controller) =>
                                localAnimationController = controller,
                          );
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true, // Agar teks terbaru tetap terlihat di ujung kanan
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 140),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Text(
                              _expression,
                              key: ValueKey(_expression),
                              style: TextStyle(
                                fontSize: height * 0.07,
                                color: _isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
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
              icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                  color: _isDarkMode ? Colors.white : Colors.black),
              onPressed: _toggleTheme,
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.functions,
                  color: _isDarkMode ? Colors.white : Colors.black),
              onPressed: _toggleHistory,
            ),
          ),
          _isHistoryOpen ? _buildHistoryPanel() : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
                  child: Text("History", style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_history[index], style: TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeHistoryItem(index),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextButton(
                    onPressed: _clearHistory,
                    child: Text("Hapus semua", style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildButton(BuildContext context, String text) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 6,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: height * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
                child: _buildButton(btn,
                    color: const Color.fromARGB(255, 51, 119, 54),
                    heightFactor: 1),
              );
            } else if (btn.isEmpty) {
              return SizedBox(width: 0); // Empty space for alignment
            } else {
              return _buildButton(
                btn,
                color: btn == "C"
                    ? Colors.red
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(vertical: 24.0 * heightFactor),
            backgroundColor: color ?? const Color.fromARGB(0, 66, 66, 66),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24.0,
              color: (_isDarkMode ? 
                          (value == "+" || value == "x" || value == "-" || value == "+" || value == "÷" || value == "%") ? Colors.green
                          : (value == "DEL") ? Colors.red 
                          : Colors.white
                          : (value == "+" || value == "x" || value == "-" || value == "+" || value == "÷" || value == "%") ? const Color.fromARGB(255, 41, 126, 43) 
                          : (value == "DEL") ? const Color.fromARGB(255, 179, 47, 38) 
                          :Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

