import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  int _selectedIndex = 0;

  void _go(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ButtonOnlyCalculatorPage(),
      const FormFieldsCalculatorPage(),
    ];

    return MaterialApp(
      title: 'Exercise6a - Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_selectedIndex == 0
              ? 'Calculator (Buttons Only)'
              : 'Calculator (Form Fields)'),
          actions: [
            IconButton(
              tooltip: _selectedIndex == 0
                  ? 'Go to Form Fields'
                  : 'Go to Buttons Only',
              onPressed: () => _go(_selectedIndex == 0 ? 1 : 0),
              icon: const Icon(Icons.swap_horiz),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Exercise6a',
                    style: TextStyle(
                      fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calculate_outlined),
                title: const Text('Part-1: Buttons Only'),
                selected: _selectedIndex == 0,
                onTap: () {
                  Navigator.pop(context);
                  _go(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields_outlined),
                title: const Text('Part-2: Form Fields'),
                selected: _selectedIndex == 1,
                onTap: () {
                  Navigator.pop(context);
                  _go(1);
                },
              ),
            ],
          ),
        ),
        body: pages[_selectedIndex],
      ),
    );
  }
}

/// -------------------------
/// Part-1: Buttons-only calc
/// -------------------------
class ButtonOnlyCalculatorPage extends StatefulWidget {
  const ButtonOnlyCalculatorPage({super.key});

  @override
  State<ButtonOnlyCalculatorPage> createState() =>
      _ButtonOnlyCalculatorPageState();
}

class _ButtonOnlyCalculatorPageState extends State<ButtonOnlyCalculatorPage> {
  String _display = '0';
  String _expression = ''; // e.g. "12 + 7"
  double? _first;
  String? _op; // '+', '-', '×', '÷'
  bool _justEvaluated = false;

  void _press(String label) {
    setState(() {
      if ('0123456789'.contains(label)) {
        _inputDigit(label);
      } else if (label == '.') {
        _inputDot();
      } else if (['+', '-', '×', '÷'].contains(label)) {
        _setOperator(label);
      } else if (label == '=') {
        _evaluate();
      } else if (label == 'C') {
        _clearAll();
      } else if (label == '⌫') {
        _backspace();
      }
    });
  }

  void _inputDigit(String d) {
    if (_justEvaluated) {
      // Start new number after equals
      _display = d;
      _justEvaluated = false;
      _expression = '';
      _first = null;
      _op = null;
      return;
    }
    if (_display == '0') {
      _display = d;
    } else {
      _display += d;
    }
  }

  void _inputDot() {
    if (_justEvaluated) {
      _display = '0.';
      _justEvaluated = false;
      _expression = '';
      _first = null;
      _op = null;
      return;
    }
    if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void _setOperator(String op) {
    final current = double.tryParse(_display);
    if (current == null) return;

    if (_first != null && _op != null && !_justEvaluated) {
      // Chain calculate: first op current
      _evaluate();
    }

    _first = double.tryParse(_display);
    _op = op;
    _expression = '${_stripTrailingZeros(_first!)} $op';
    _display = '0';
    _justEvaluated = false;
  }

  void _evaluate() {
    if (_first == null || _op == null) return;
    final second = double.tryParse(_display);
    if (second == null) return;

    double result;
    try {
      switch (_op) {
        case '+':
          result = _first! + second;
          break;
        case '-':
          result = _first! - second;
          break;
        case '×':
          result = _first! * second;
          break;
        case '÷':
          if (second == 0) {
            _display = 'Error';
            _expression = '';
            _first = null;
            _op = null;
            _justEvaluated = true;
            return;
          }
          result = _first! / second;
          break;
        default:
          return;
      }
    } catch (_) {
      _display = 'Error';
      _expression = '';
      _first = null;
      _op = null;
      _justEvaluated = true;
      return;
    }

    _expression =
        '${_stripTrailingZeros(_first!)} $_op ${_stripTrailingZeros(second)} =';
    _display = _stripTrailingZeros(result);
    _first = result;
    _op = null;
    _justEvaluated = true;
  }

  void _clearAll() {
    _display = '0';
    _expression = '';
    _first = null;
    _op = null;
    _justEvaluated = false;
  }

  void _backspace() {
    if (_justEvaluated) {
      // After equals, backspace resets
      _clearAll();
      return;
    }
    if (_display.length <= 1) {
      _display = '0';
    } else {
      _display = _display.substring(0, _display.length - 1);
      if (_display == '-' || _display == '-0') _display = '0';
    }
  }

  String _stripTrailingZeros(num v) {
    final s = v.toString();
    if (s.contains('.') && s.endsWith('0')) {
      return s.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final btns = [
      ['C', '⌫', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _expression,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _display,
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                
                Row(
                  children: [
                    _calcButton('C', flex: 2, color: Colors.red),
                    const SizedBox(width: 8),
                    _calcButton('⌫', flex: 1),
                    const SizedBox(width: 8),
                    _calcButton('÷', flex: 1, color: Colors.indigo),
                  ],
                ),
                const SizedBox(height: 8),
                _rowOf(['7', '8', '9', '×']),
                const SizedBox(height: 8),
                _rowOf(['4', '5', '6', '-']),
                const SizedBox(height: 8),
                _rowOf(['1', '2', '3', '+']),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _calcButton('0', flex: 2),
                    const SizedBox(width: 8),
                    _calcButton('.', flex: 1),
                    const SizedBox(width: 8),
                    _calcButton('=', flex: 1, color: Colors.deepPurple),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowOf(List<String> labels) {
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          _calcButton(
            labels[i],
            color: (['+', '-', '×', '÷'].contains(labels[i]))
                ? Colors.indigo
                : null,
          ),
          if (i != labels.length - 1) const SizedBox(width: 8),
        ]
      ],
    );
  }

  Widget _calcButton(String label, {int flex = 1, Color? color}) {
    final isOp = ['+', '-', '×', '÷', '='].contains(label);
    final bg = color ??
        (isOp
            ? Colors.indigo
            : Theme.of(context).colorScheme.surfaceContainerHighest);
    final fg = isOp ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Expanded(
      flex: flex,
      child: SizedBox(
        height: 64,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => _press(label),
          child: Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

/// --------------------------------------
/// Part-2: Two TextFormFields + validation
/// --------------------------------------
class FormFieldsCalculatorPage extends StatefulWidget {
  const FormFieldsCalculatorPage({super.key});

  @override
  State<FormFieldsCalculatorPage> createState() =>
      _FormFieldsCalculatorPageState();
}

class _FormFieldsCalculatorPageState extends State<FormFieldsCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _aCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  String _operator = '+';
  String _result = '';

  final _numericInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'));

  void _compute() {
    if (!_formKey.currentState!.validate()) return;
    final a = double.parse(_aCtrl.text);
    final b = double.parse(_bCtrl.text);
    double out;

    switch (_operator) {
      case '+':
        out = a + b;
        break;
      case '-':
        out = a - b;
        break;
      case '×':
        out = a * b;
        break;
      case '÷':
        if (b == 0) {
          setState(() => _result = 'Error (division by zero)');
          return;
        }
        out = a / b;
        break;
      default:
        return;
    }
    setState(() => _result = _strip(out));
  }

  String _strip(num v) {
    final s = v.toString();
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  @override
  void dispose() {
    _aCtrl.dispose();
    _bCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w600);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Enter two numbers:', style: labelStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _aCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: [_numericInputFormatter],
                        decoration: const InputDecoration(
                          labelText: 'A',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Numbers only';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 72,
                      child: DropdownButtonFormField<String>(
                        value: _operator,
                        decoration: const InputDecoration(
                          labelText: 'Op',
                          border: OutlineInputBorder(),
                        ),
                        items: const ['+', '-', '×', '÷']
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: TextStyle(fontSize: 18)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _operator = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _bCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true, signed: true),
                        inputFormatters: [_numericInputFormatter],
                        decoration: const InputDecoration(
                          labelText: 'B',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Numbers only';
                          }
                          if (_operator == '÷' &&
                              double.tryParse(v) != null &&
                              double.parse(v) == 0) {
                            return 'Cannot divide by zero';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Compute', style: TextStyle(fontSize: 18)),
                    onPressed: _compute,
                  ),
                ),
                const SizedBox(height: 12),
                if (_result.isNotEmpty)
                  Card(
                    elevation: 0,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Result: $_result',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
