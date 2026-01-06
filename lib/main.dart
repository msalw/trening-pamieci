// ============================================================
// MEMORY TRAINER - Aplikacja do treningu pamięci
// ============================================================
// WERSJA POPRAWIONA - Naprawione błędy:
// - Memory leak z Timer (dodano dispose)
// - Walidacja długości inputu
// - Obsługa błędów w generowaniu ciągu
// - Optymalizacja obliczania dokładności
// - Zabezpieczenie przed dzieleniem przez zero
// ============================================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// ============================================================
// FUNKCJA MAIN - Punkt startowy aplikacji
// ============================================================
void main() {
  runApp(const MemoryTrainerApp());
}

// ============================================================
// GŁÓWNA KLASA APLIKACJI
// ============================================================
class MemoryTrainerApp extends StatelessWidget {
  const MemoryTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Trainer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// MODEL DANYCH - AttemptResult
// ============================================================
class AttemptResult {
  final String correctSequence;
  final String userAnswer;
  final int responseTime;
  final int displayTime;
  final double accuracy;
  final int correctPositions;

  AttemptResult({
    required this.correctSequence,
    required this.userAnswer,
    required this.responseTime,
    required this.displayTime,
    required this.accuracy,
    required this.correctPositions,
  });
}

// ============================================================
// EKRAN STARTOWY - HomeScreen
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int sequenceLength = 6;
  int numberOfAttempts = 10;
  String sequenceType = 'Cyfry';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Trainer'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.psychology,
                size: 80,
                color: Colors.blue
              ),
              const SizedBox(height: 20),
              const Text(
                'Trening Pamięci',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 40),
              _buildCompactSetting(
                'Długość ciągu',
                sequenceLength,
                3,
                15,
                'znaków',
                (value) => setState(() => sequenceLength = value)
              ),
              const SizedBox(height: 12),
              _buildCompactSetting(
                'Liczba prób',
                numberOfAttempts,
                1,
                50,
                'prób',
                (value) => setState(() => numberOfAttempts = value)
              ),
              const SizedBox(height: 12),
              _buildTypePicker(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                // ✅ POPRAWKA: Walidacja przed startem
                child: ElevatedButton.icon(
                  onPressed: sequenceLength >= 3 && numberOfAttempts >= 1
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionScreen(
                              sequenceLength: sequenceLength,
                              numberOfAttempts: numberOfAttempts,
                              sequenceType: sequenceType,
                            ),
                          )
                        );
                      }
                    : null, // Przycisk nieaktywny gdy nieprawidłowe wartości
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 32),
                  label: const Text(
                    'ROZPOCZNIJ TRENING',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSetting(
    String label,
    int value,
    int min,
    int max,
    String unit,
    Function(int) onChanged
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.blue,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue
                  )
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Typ ciągu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['Cyfry', 'Litery', 'Mieszane']
              .map((type) => _buildTypeChip(type))
              .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = sequenceType == type;
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => sequenceType = type);
        }
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

// ============================================================
// EKRAN SESJI - SessionScreen
// ============================================================
class SessionScreen extends StatefulWidget {
  final int sequenceLength;
  final int numberOfAttempts;
  final String sequenceType;

  const SessionScreen({
    super.key,
    required this.sequenceLength,
    required this.numberOfAttempts,
    required this.sequenceType,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int currentAttempt = 0;
  List<AttemptResult> results = [];
  bool isFirstAttempt = true;
  int nextAttemptCountdown = 3;
  Timer? countdownTimer;
  bool isWaitingForNext = false;

  void _startNextAttempt() {
    if (currentAttempt < widget.numberOfAttempts) {
      setState(() => isWaitingForNext = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayScreen(
            sequenceLength: widget.sequenceLength,
            sequenceType: widget.sequenceType,
            isFirstAttempt: isFirstAttempt,
            currentAttempt: currentAttempt + 1,
            totalAttempts: widget.numberOfAttempts,
            onComplete: (result) {
              setState(() {
                results.add(result);
                currentAttempt++;
                isFirstAttempt = false;
              });
              if (currentAttempt < widget.numberOfAttempts) {
                setState(() {
                  isWaitingForNext = true;
                  nextAttemptCountdown = 3;
                });
                countdownTimer = Timer.periodic(
                  const Duration(seconds: 1),
                  (timer) {
                    setState(() => nextAttemptCountdown--);
                    if (nextAttemptCountdown <= 0) {
                      timer.cancel();
                      _startNextAttempt();
                    }
                  }
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsScreen(
                      results: results,
                      sequenceLength: widget.sequenceLength,
                      numberOfAttempts: widget.numberOfAttempts,
                      sequenceType: widget.sequenceType,
                    ),
                  )
                );
              }
            },
          ),
        )
      );
    }
  }

  // ✅ POPRAWKA: Dodano dispose() do zatrzymania timera
  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentAttempt == 0 && !isWaitingForNext) {
      Future.microtask(() => _startNextAttempt());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sesja: ${currentAttempt}/${widget.numberOfAttempts}'),
      ),
      body: Center(
        child: isWaitingForNext
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Następna próba za:',
                  style: const TextStyle(fontSize: 24)
                ),
                const SizedBox(height: 20),
                Text(
                  nextAttemptCountdown.toString(),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue
                  )
                ),
                const SizedBox(height: 40),
                LinearProgressIndicator(
                  value: currentAttempt / widget.numberOfAttempts,
                  minHeight: 8,
                ),
                const SizedBox(height: 20),
                Text(
                  'Ukończono: $currentAttempt/${widget.numberOfAttempts}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey)
                ),
              ],
            )
          : const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildProgressItem(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 16))
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black
          )
        ),
      ],
    );
  }
}

// ============================================================
// EKRAN WYŚWIETLANIA CIĄGU - DisplayScreen
// ============================================================
class DisplayScreen extends StatefulWidget {
  final int sequenceLength;
  final String sequenceType;
  final bool isFirstAttempt;
  final int currentAttempt;
  final int totalAttempts;
  final Function(AttemptResult) onComplete;

  const DisplayScreen({
    super.key,
    required this.sequenceLength,
    required this.sequenceType,
    required this.isFirstAttempt,
    required this.currentAttempt,
    required this.totalAttempts,
    required this.onComplete,
  });

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  String sequence = '';
  int countdown = 3;
  bool showingSequence = false;
  Timer? countdownTimer;
  Timer? displayTimer;
  int elapsedSeconds = 0;
  DateTime? displayStartTime;

  @override
  void initState() {
    super.initState();
    sequence = _generateSequence();
    widget.isFirstAttempt ? _startCountdown() : _showSequence();
  }

  // ✅ POPRAWKA: Obsługa błędów + fallback do cyfr
  String _generateSequence() {
    final random = Random();
    String chars;
    
    switch (widget.sequenceType) {
      case 'Cyfry':
        chars = '0123456789';
        break;
      case 'Litery':
        chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        break;
      case 'Mieszane':
        chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        break;
      default:
        // Fallback do cyfr + log ostrzeżenia
        chars = '0123456789';
        debugPrint('⚠️ Nieznany typ ciągu: ${widget.sequenceType}. Używam cyfr.');
    }
    
    return List.generate(
      widget.sequenceLength,
      (index) => chars[random.nextInt(chars.length)]
    ).join();
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (countdown > 0) {
          setState(() => countdown--);
        } else {
          timer.cancel();
          _showSequence();
        }
      }
    );
  }

  void _showSequence() {
    setState(() {
      showingSequence = true;
      elapsedSeconds = 0;
      displayStartTime = DateTime.now();
    });
    displayTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() => elapsedSeconds++);
      }
    );
  }

  void _goToInput([String? firstChar]) {
    countdownTimer?.cancel();
    displayTimer?.cancel();
    final displayTime = displayStartTime != null
        ? DateTime.now().difference(displayStartTime!).inSeconds
        : 0;
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InputScreen(
            correctSequence: sequence,
            onComplete: widget.onComplete,
            firstChar: firstChar,
            displayTime: displayTime,
            sequenceType: widget.sequenceType,
          ),
        )
      );
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    displayTimer?.cancel();
    super.dispose();
  }

  String _getProbyText(int count) {
    if (count == 1) return 'próba';
    if (count >= 2 && count <= 4) return 'próby';
    return 'prób';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Próba ${widget.currentAttempt}/${widget.totalAttempts}'),
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: showingSequence ? () => _goToInput() : null,
        child: RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          autofocus: true,
          onKey: (event) {
            if (showingSequence && event.runtimeType.toString() == 'RawKeyDownEvent') {
              final char = event.character;
              if (char != null && char.isNotEmpty) {
                _goToInput(char);
              }
            }
          },
          child: Container(
            color: Colors.white,
            child: Center(
              child: showingSequence
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sequence,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8
                        )
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer,
                              color: Colors.orange, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              '$elapsedSeconds sek',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.keyboard,
                                  color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Zacznij pisać gdy zapamiętasz',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pozostało: ${widget.totalAttempts - widget.currentAttempt + 1} ${_getProbyText(widget.totalAttempts - widget.currentAttempt + 1)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        countdown > 0 ? countdown.toString() : 'GO!',
                        style: TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          color: countdown > 0 ? Colors.blue : Colors.green
                        )
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Przygotuj się...',
                        style: TextStyle(fontSize: 24, color: Colors.grey)
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EKRAN WPROWADZANIA ODPOWIEDZI - InputScreen
// ============================================================
class InputScreen extends StatefulWidget {
  final String correctSequence;
  final Function(AttemptResult) onComplete;
  final String? firstChar;
  final int displayTime;
  final String sequenceType;

  const InputScreen({
    super.key,
    required this.correctSequence,
    required this.onComplete,
    this.firstChar,
    required this.displayTime,
    required this.sequenceType,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    if (widget.firstChar != null) {
      _controller.text = widget.firstChar!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length)
      );
    }
  }

  String _filterInput(String input) {
    String filtered = '';
    switch (widget.sequenceType) {
      case 'Cyfry':
        filtered = input.replaceAll(RegExp(r'[^0-9]'), '');
        break;
      case 'Litery':
        filtered = input.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
        break;
      case 'Mieszane':
        filtered = input.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
        break;
      default:
        filtered = input.replaceAll(RegExp(r'[^0-9]'), '');
    }
    
    // ✅ POPRAWKA: Ograniczenie długości
    if (filtered.length > widget.correctSequence.length) {
      filtered = filtered.substring(0, widget.correctSequence.length);
    }
    return filtered;
  }

  // ✅ POPRAWKA: Zoptymalizowana funkcja O(n) zamiast O(n²)
  void _checkAnswer() {
    final userAnswer = _controller.text.toUpperCase();
    final totalTime = DateTime.now().difference(startTime!).inSeconds;
    final correct = widget.correctSequence.toUpperCase();
    
    // Uzupełnij krótszą odpowiedź spacjami do porównania
    final paddedAnswer = userAnswer.padRight(correct.length, ' ');
    
    int correctPositions = 0;
    for (int i = 0; i < correct.length; i++) {
      if (paddedAnswer[i] == correct[i]) {
        correctPositions++;
      }
    }
    
    // Zabezpieczenie przed dzieleniem przez zero (teoretycznie niemożliwe, ale...)
    final double accuracy = correct.isEmpty 
      ? 0.0 
      : (correctPositions / correct.length) * 100;
    
    final result = AttemptResult(
      correctSequence: widget.correctSequence,
      userAnswer: userAnswer,
      responseTime: widget.displayTime + totalTime,
      displayTime: widget.displayTime,
      accuracy: accuracy,
      correctPositions: correctPositions,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuickFeedbackScreen(
          result: result,
          onContinue: () {
            widget.onComplete(result);
            if (mounted) Navigator.of(context).pop();
          },
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wpisz zapamiętany ciąg'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, size: 80, color: Colors.blue),
              const SizedBox(height: 40),
              const Text(
                'Wpisz zapamiętany ciąg:',
                style: TextStyle(fontSize: 24)
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: widget.correctSequence.length, // ✅ Ograniczenie długości
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  hintText: 'Wpisz tutaj...',
                  counterText: '${_controller.text.length}/${widget.correctSequence.length}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
                onChanged: (value) {
                  final filtered = _filterInput(value);
                  if (filtered != value) {
                    _controller.value = TextEditingValue(
                      text: filtered,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: filtered.length)
                      ),
                    );
                  }
                },
                onSubmitted: (_) => _checkAnswer(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _checkAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 16)
                ),
                child: const Text('Sprawdź',
                  style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ============================================================
// EKRAN SZYBKIEGO FEEDBACKU - QuickFeedbackScreen
// ============================================================
class QuickFeedbackScreen extends StatefulWidget {
  final AttemptResult result;
  final VoidCallback onContinue;

  const QuickFeedbackScreen({
    super.key,
    required this.result,
    required this.onContinue,
  });

  @override
  State<QuickFeedbackScreen> createState() => _QuickFeedbackScreenState();
}

class _QuickFeedbackScreenState extends State<QuickFeedbackScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onContinue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPerfect = widget.result.correctSequence.toUpperCase() ==
                      widget.result.userAnswer.toUpperCase();

    return Scaffold(
      body: Container(
        color: isPerfect ? Colors.green[50] : Colors.orange[50],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPerfect ? Icons.check_circle : Icons.info,
                  size: 100,
                  color: isPerfect ? Colors.green : Colors.orange
                ),
                const SizedBox(height: 20),
                Text(
                  isPerfect ? 'Doskonale!' : 'Wynik',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isPerfect ? Colors.green : Colors.orange
                  )
                ),
                const SizedBox(height: 40),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildRow('Poprawny:',
                          widget.result.correctSequence),
                        const Divider(),
                        _buildRow('Twoja odpowiedź:',
                          widget.result.userAnswer),
                        const Divider(),
                        _buildRow('Dokładność:',
                          '${widget.result.accuracy.toStringAsFixed(1)}%'),
                        const Divider(),
                        _buildRow('Czas zapamiętania:',
                          '${widget.result.displayTime} sek'),
                        const Divider(),
                        _buildRow('Całkowity czas:',
                          '${widget.result.responseTime} sek'),
                      ],
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

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EKRAN WYNIKÓW - ResultsScreen
// ============================================================
class ResultsScreen extends StatelessWidget {
  final List<AttemptResult> results;
  final int sequenceLength;
  final int numberOfAttempts;
  final String sequenceType;

  const ResultsScreen({
    super.key,
    required this.results,
    required this.sequenceLength,
    required this.numberOfAttempts,
    required this.sequenceType,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ POPRAWKA: Zabezpieczenie przed pustą listą (dzielenie przez zero)
    if (results.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wyniki')),
        body: const Center(
          child: Text('Brak wyników do wyświetlenia',
            style: TextStyle(fontSize: 18)),
        ),
      );
    }

    final avgAccuracy = results.map((r) => r.accuracy).reduce((a, b) => a + b) / results.length;
    final avgDisplayTime = results.map((r) => r.displayTime).reduce((a, b) => a + b) / results.length;
    final avgResponseTime = results.map((r) => r.responseTime).reduce((a, b) => a + b) / results.length;
    final perfectCount = results.where((r) => r.accuracy == 100).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyniki Sesji'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PODSUMOWANIE SESJI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildStatRow('Średnia dokładność',
                      '${avgAccuracy.toStringAsFixed(1)}%'),
                    _buildStatRow('Średni czas zapamiętania',
                      '${avgDisplayTime.toStringAsFixed(1)} sek'),
                    _buildStatRow('Średni czas całkowity',
                      '${avgResponseTime.toStringAsFixed(1)} sek'),
                    _buildStatRow('Perfekcyjne odpowiedzi',
                      '$perfectCount/${results.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ANALIZA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 10),
                    if (avgAccuracy >= 90) ...[
                      const Icon(Icons.celebration, color: Colors.green, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        '🎉 Świetna sesja! Twoja pamięć działa znakomicie.'
                      ),
                    ] else if (avgAccuracy >= 70) ...[
                      const Icon(Icons.thumb_up, color: Colors.orange, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        '👍 Dobra robota! Z każdą sesją będzie lepiej.'
                      ),
                    ] else ...[
                      const Icon(Icons.fitness_center, color: Colors.blue, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        '💪 Trening czyni mistrza! Kontynuuj ćwiczenia.'
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (perfectCount == results.length) ...[
                      const Text(
                        '✓ Perfekcyjna sesja! Wszystkie odpowiedzi były poprawne.'
                      ),
                    ] else if (perfectCount > results.length / 2) ...[
                      const Text(
                        '✓ Ponad połowa odpowiedzi była perfekcyjna!'
                      ),
                    ],
                    if (avgDisplayTime < 3 && avgAccuracy < 80) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.tips_and_updates, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '💡 Poświęć więcej czasu na zapamiętanie. Nie spiesz się!',
                                style: TextStyle(fontWeight: FontWeight.w500)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SZCZEGÓŁY WSZYSTKICH PRÓB',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(results.length, (index) {
                      final result = results[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: result.accuracy == 100
                            ? Colors.green[50]
                            : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: result.accuracy == 100
                              ? Colors.green
                              : Colors.grey
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Próba ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(
                                  '${result.accuracy.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: result.accuracy == 100
                                      ? Colors.green
                                      : Colors.orange
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Ciąg: ${result.correctSequence}'),
                            Text('Odpowiedź: ${result.userAnswer}'),
                            Text('Zapamiętanie: ${result.displayTime} sek'),
                            Text('Całkowity czas: ${result.responseTime} sek'),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Powrót'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16
                    )
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nowa sesja'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16
                    ),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}

// ============================================================
// KONIEC PLIKU - WERSJA POPRAWIONA
// ============================================================
// Główne poprawki:
// ✅ Naprawiono memory leak (dodano dispose() z cancel() dla timerów)
// ✅ Dodano walidację długości inputu (maxLength)
// ✅ Dodano obsługę błędów w _generateSequence() (fallback + log)
// ✅ Zoptymalizowano _calculateAccuracy() (O(n) zamiast O(n²))
// ✅ Zabezpieczono przed dzieleniem przez zero
// ✅ Dodano walidację przed startem sesji
// ============================================================