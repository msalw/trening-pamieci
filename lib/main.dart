// ============================================================
// MEMORY TRAINER - Aplikacja do treningu pamięci
// ============================================================
// Importy - biblioteki potrzebne do działania aplikacji

import 'package:flutter/material.dart';  // Główna biblioteka Flutter do tworzenia UI
import 'dart:async';  // Biblioteka do operacji asynchronicznych (Timer, Future)
import 'dart:math';   // Biblioteka matematyczna (Random do losowania znaków)

// ============================================================
// FUNKCJA MAIN - Punkt startowy aplikacji
// ============================================================
// Każda aplikacja Flutter zaczyna się od funkcji main()
void main() {
  runApp(const MemoryTrainerApp());  // Uruchamia aplikację
}

// ============================================================
// GŁÓWNA KLASA APLIKACJI
// ============================================================
// StatelessWidget - widget który się nie zmienia (bez stanu)
class MemoryTrainerApp extends StatelessWidget {
  const MemoryTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp - podstawowa struktura aplikacji Material Design
    // To "opakowanie" całej aplikacji
    return MaterialApp(
      title: 'Memory Trainer',  // Tytuł aplikacji (widoczny w pasku zadań)
      theme: ThemeData(          // Motyw kolorystyczny aplikacji
        primarySwatch: Colors.blue,  // Główny kolor - niebieski
        useMaterial3: true,          // Używa najnowszej wersji Material Design
      ),
      home: const HomeScreen(),  // Pierwszy ekran który się wyświetla po uruchomieniu
    );
  }
}

// ============================================================
// MODEL DANYCH - AttemptResult
// ============================================================
// Klasa przechowująca dane o pojedynczej próbie w sesji
// To jak "pudełko" na wyniki jednego testu
class AttemptResult {
  // final - wartość nie może się zmienić po utworzeniu obiektu
  final String correctSequence;    // Poprawny ciąg znaków (np. "A7B2K9")
  final String userAnswer;         // Odpowiedź użytkownika (np. "A7B2K8")
  final int responseTime;          // Całkowity czas w sekundach (zapamiętanie + wpisanie)
  final int displayTime;           // Czas tylko patrzenia na ciąg (w sekundach)
  final double accuracy;           // Dokładność w procentach (0.0 - 100.0)
  final int correctPositions;      // Ile znaków jest na właściwych pozycjach

  // Konstruktor - funkcja tworząca obiekt AttemptResult
  // required - wszystkie parametry są wymagane
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
// StatefulWidget - widget który może się zmieniać (ma stan)
// Stan to zmienne które mogą się zmieniać (np. ustawienia użytkownika)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Stan ekranu startowego - przechowuje zmienne które mogą się zmieniać
// _ przed nazwą klasy = prywatna (widoczna tylko w tym pliku)
class _HomeScreenState extends State<HomeScreen> {
  // ===== ZMIENNE STANU =====
  // Możemy je zmieniać używając setState()
  int sequenceLength = 6;        // Długość ciągu znaków (domyślnie 6)
  int numberOfAttempts = 10;     // Liczba prób w sesji (domyślnie 10)
  String sequenceType = 'Cyfry'; // Typ ciągu (Cyfry, Litery, lub Mieszane)

  @override
  Widget build(BuildContext context) {
    // build() - funkcja która buduje interfejs użytkownika
    // Jest wywoływana za każdym razem gdy stan się zmieni (setState)
    
    // Scaffold - podstawowa struktura ekranu
    // Zawiera AppBar (górny pasek), body (zawartość), drawer (menu boczne) itp.
    return Scaffold(
      // AppBar - górny pasek z tytułem
      appBar: AppBar(
        title: const Text('Memory Trainer'),
        centerTitle: true,  // Wyśrodkuj tytuł
      ),
      
      // body - główna zawartość ekranu
      body: Center(  // Center - wyśrodkowuje dziecko
        child: Padding(
          padding: const EdgeInsets.all(24.0),  // Odstępy ze wszystkich stron (24 piksele)
          
          // Column - układa dzieci pionowo (jeden pod drugim)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Wyśrodkuj w pionie
            children: [
              // ===== IKONA MÓZGU =====
              const Icon(
                Icons.psychology,  // Ikona mózgu z Material Icons
                size: 80,          // Rozmiar 80 pikseli
                color: Colors.blue // Niebieski kolor
              ),
              const SizedBox(height: 20),  // Odstęp pionowy 20 pikseli
              
              // ===== TYTUŁ =====
              const Text(
                'Trening Pamięci', 
                style: TextStyle(
                  fontSize: 32,              // Duża czcionka
                  fontWeight: FontWeight.bold // Pogrubiona
                )
              ),
              const SizedBox(height: 40),  // Większy odstęp
              
              // ===== USTAWIENIE DŁUGOŚCI CIĄGU =====
              // Wywołujemy funkcję która zwraca gotowy widget
              _buildCompactSetting(
                'Długość ciągu',      // Etykieta
                sequenceLength,       // Aktualna wartość
                3,                    // Minimalna wartość (3 znaki)
                15,                   // Maksymalna wartość (15 znaków)
                'znaków',             // Jednostka wyświetlana obok liczby
                // Funkcja wywoływana gdy wartość się zmieni
                // (value) => to krótki zapis funkcji: void function(int value) { ... }
                (value) => setState(() => sequenceLength = value)
              ),
              const SizedBox(height: 12),
              
              // ===== USTAWIENIE LICZBY PRÓB =====
              _buildCompactSetting(
                'Liczba prób',
                numberOfAttempts,
                1,                    // Minimum 1 próba
                50,                   // Maximum 50 prób
                'prób',
                (value) => setState(() => numberOfAttempts = value)
              ),
              const SizedBox(height: 12),
              
              // ===== WYBÓR TYPU CIĄGU =====
              _buildTypePicker(),
              const SizedBox(height: 40),
              
              // ===== PRZYCISK START =====
              // SizedBox z width: double.infinity = zajmuje całą szerokość
              SizedBox(
                width: double.infinity,  // Pełna szerokość rodzica
                child: ElevatedButton.icon(
                  // onPressed - funkcja wywoływana po kliknięciu
                  onPressed: () {
                    // Navigator.push - przechodzi do nowego ekranu
                    // MaterialPageRoute - definuje jak przejść do ekranu
                    Navigator.push(
                      context,  // Kontekst - informacje o miejscu w drzewie widgetów
                      MaterialPageRoute(
                        // builder - funkcja która tworzy nowy ekran
                        builder: (context) => SessionScreen(
                          // Przekazujemy ustawienia do SessionScreen
                          sequenceLength: sequenceLength,
                          numberOfAttempts: numberOfAttempts,
                          sequenceType: sequenceType,
                        ),
                      )
                    );
                  },
                  // Styl przycisku
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.green,  // Zielony przycisk
                    foregroundColor: Colors.white,  // Biały tekst i ikona
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)  // Zaokrąglone rogi
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 32),  // Ikona play
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

  // ============================================================
  // FUNKCJA POMOCNICZA: Widget ustawienia z przyciskami +/-
  // ============================================================
  // Tworzy kompaktowy widget do zmiany wartości liczbowej
  Widget _buildCompactSetting(
    String label,           // Etykieta (np. "Długość ciągu")
    int value,              // Aktualna wartość
    int min,                // Minimalna wartość
    int max,                // Maksymalna wartość
    String unit,            // Jednostka (np. "znaków")
    Function(int) onChanged // Funkcja callback wywoływana przy zmianie
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],  // Jasno szare tło
        borderRadius: BorderRadius.circular(12),  // Zaokrąglone rogi
      ),
      
      // Row - układa dzieci poziomo (obok siebie)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Rozciągnij między krańce
        children: [
          // ===== ETYKIETA PO LEWEJ =====
          Text(
            label, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
          ),
          
          // ===== PRZYCISKI I WARTOŚĆ PO PRAWEJ =====
          Row(
            children: [
              // PRZYCISK MINUS (-)
              IconButton(
                // Jeśli value > min to przycisk aktywny, inaczej wyłączony (null)
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.blue,
              ),
              
              // RAMKA Z AKTUALNĄ WARTOŚCIĄ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                // $ - interpolacja zmiennych w stringu
                // '$value $unit' np. "6 znaków"
                child: Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.blue
                  )
                ),
              ),
              
              // PRZYCISK PLUS (+)
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

  // ============================================================
  // FUNKCJA POMOCNICZA: Widget wyboru typu ciągu
  // ============================================================
  Widget _buildTypePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // Wyrównaj dzieci do lewej
        children: [
          const Text(
            'Typ ciągu', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 12),
          
          // Wrap - automatycznie łamie do nowej linii gdy brak miejsca
          Wrap(
            spacing: 8,  // Odstęp między chipami
            // .map() - przekształca każdy element listy
            // ['Cyfry', 'Litery', 'Mieszane'] -> lista widgetów
            children: ['Cyfry', 'Litery', 'Mieszane']
              .map((type) => _buildTypeChip(type))
              .toList(),  // Musi być lista widgetów (List<Widget>)
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FUNKCJA POMOCNICZA: Pojedynczy chip wyboru
  // ============================================================
  Widget _buildTypeChip(String type) {
    final isSelected = sequenceType == type;  // Czy ten typ jest aktualnie wybrany?
    
    // ChoiceChip - przycisk wyboru (może być tylko jeden wybrany)
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        // Jeśli kliknięto, zmień sequenceType i odśwież widok
        if (selected) {
          setState(() => sequenceType = type);
        }
      },
      selectedColor: Colors.blue,  // Kolor gdy wybrany
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
// Zarządza całą sesją treningową (wiele prób)
class SessionScreen extends StatefulWidget {
  // Parametry przekazane z HomeScreen
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
  // ===== ZMIENNE STANU SESJI =====
  int currentAttempt = 0;              // Numer aktualnej próby (0-based)
  List<AttemptResult> results = [];    // Lista wyników wszystkich prób
  bool isFirstAttempt = true;          // Czy to pierwsza próba? (dla odliczania 3,2,1)
  int nextAttemptCountdown = 3;        // Odliczanie do następnej próby
  Timer? countdownTimer;               // Timer do odliczania
  bool isWaitingForNext = false;       // Czy czekamy na następną próbę?

  // ============================================================
  // FUNKCJA: Rozpocznij następną próbę
  // ============================================================
  void _startNextAttempt() {
    // Sprawdź czy są jeszcze próby do wykonania
    if (currentAttempt < widget.numberOfAttempts) {
      setState(() => isWaitingForNext = false);
      
      // Navigator.push - przechodzi do ekranu wyświetlania ciągu
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => DisplayScreen(
            sequenceLength: widget.sequenceLength,
            sequenceType: widget.sequenceType,
            isFirstAttempt: isFirstAttempt,
            currentAttempt: currentAttempt + 1,
            totalAttempts: widget.numberOfAttempts,
            // onComplete - funkcja callback wywoływana gdy użytkownik zakończy próbę
            onComplete: (result) {
              // Dodaj wynik do listy
              setState(() {
                results.add(result);
                currentAttempt++;
                isFirstAttempt = false;  // Następne próby bez odliczania
              });
              
              // Sprawdź czy są jeszcze próby
              if (currentAttempt < widget.numberOfAttempts) {
                // Są jeszcze próby - pokaż odliczanie
                setState(() {
                  isWaitingForNext = true;
                  nextAttemptCountdown = 3;
                });
                
                // Timer.periodic - wykonuje funkcję co określony czas
                countdownTimer = Timer.periodic(
                  const Duration(seconds: 1),  // Co sekundę
                  (timer) {
                    setState(() => nextAttemptCountdown--);
                    
                    // Gdy odliczanie dojdzie do 0
                    if (nextAttemptCountdown <= 0) {
                      timer.cancel();  // Zatrzymaj timer
                      _startNextAttempt();  // Rozpocznij następną próbę
                    }
                  }
                );
              } else {
                // Koniec sesji - przejdź do ekranu wyników
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => SessionResultScreen(
                      results: results,
                      sequenceLength: widget.sequenceLength,
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

  @override
  void initState() {
    // initState() - wywoływane raz przy tworzeniu widgetu
    super.initState();
    // WidgetsBinding - czeka aż interfejs się zbuduje, potem wywołuje funkcję
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNextAttempt());
  }

  @override
  void dispose() {
    // dispose() - wywoływane gdy widget jest usuwany
    // Tutaj czyszczenie zasobów (zatrzymanie timerów)
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Oblicz średnią dokładność z dotychczasowych prób
    double currentAvgAccuracy = 0;
    if (results.isNotEmpty) {
      // .map() - przekształć każdy wynik na accuracy
      // .reduce() - zsumuj wszystkie wartości
      currentAvgAccuracy = results
        .map((r) => r.accuracy)
        .reduce((a, b) => a + b) / results.length;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Próba ${currentAttempt + 1}/${widget.numberOfAttempts}')
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== EKRAN ODLICZANIA LUB ŁADOWANIA =====
              if (isWaitingForNext) ...[
                // ... - spread operator, rozkłada listę elementów
                const Icon(Icons.timer, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  '$nextAttemptCountdown',  // Wyświetl liczbę 3, 2, 1
                  style: const TextStyle(
                    fontSize: 80, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.blue
                  )
                ),
                const SizedBox(height: 20),
                const Text(
                  'Następna próba za...', 
                  style: TextStyle(fontSize: 20, color: Colors.grey)
                ),
              ] else ...[
                // Ekran ładowania
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text(
                  'Ładowanie...', 
                  style: TextStyle(fontSize: 18, color: Colors.grey)
                ),
              ],
              
              const SizedBox(height: 40),
              
              // ===== KARTA Z POSTĘPEM SESJI =====
              Card(
                elevation: 4,  // Cień pod kartą
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'POSTĘP SESJI', 
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.blue
                        )
                      ),
                      const Divider(height: 30),  // Linia pozioma
                      
                      // Wiersz z ikoną i tekstem
                      _buildProgressRow(
                        Icons.fact_check, 
                        'Ukończono', 
                        '$currentAttempt z ${widget.numberOfAttempts}'
                      ),
                      const SizedBox(height: 12),
                      
                      _buildProgressRow(
                        Icons.pending_actions, 
                        'Pozostało', 
                        '${widget.numberOfAttempts - currentAttempt} ${_getProbyText(widget.numberOfAttempts - currentAttempt)}'
                      ),
                      
                      // Pokaż statystyki tylko jeśli są jakieś wyniki
                      if (results.isNotEmpty) ...[
                        const Divider(height: 30),
                        _buildProgressRow(
                          Icons.analytics, 
                          'Średnia dokładność', 
                          '${currentAvgAccuracy.toStringAsFixed(1)}%',
                          // Kolor zależny od dokładności
                          valueColor: currentAvgAccuracy >= 80 
                            ? Colors.green 
                            : Colors.orange
                        ),
                        const SizedBox(height: 12),
                        _buildProgressRow(
                          Icons.workspace_premium, 
                          'Perfekcyjne', 
                          // .where() - filtruj wyniki gdzie accuracy == 100
                          '${results.where((r) => r.accuracy == 100).length}',
                          valueColor: Colors.amber
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FUNKCJA POMOCNICZA: Odmień słowo "próba"
  // ============================================================
  // Polski ma różne formy: 1 próba, 2 próby, 5 prób
  String _getProbyText(int count) {
    if (count == 1) return 'próba';
    if (count >= 2 && count <= 4) return 'próby';
    return 'prób';
  }

  // ============================================================
  // FUNKCJA POMOCNICZA: Wiersz postępu
  // ============================================================
  Widget _buildProgressRow(
    IconData icon, 
    String label, 
    String value, 
    {Color? valueColor}  // Opcjonalny parametr
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(  // Expanded - zajmuje całą dostępną przestrzeń
          child: Text(label, style: const TextStyle(fontSize: 16))
        ),
        Text(
          value, 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: valueColor ?? Colors.black  // ?? - operator null-coalescing
          )
        ),
      ],
    );
  }
}

// ============================================================
// EKRAN WYŚWIETLANIA CIĄGU - DisplayScreen
// ============================================================
// Pokazuje ciąg znaków do zapamiętania
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
  // ===== ZMIENNE STANU =====
  String sequence = '';                // Wygenerowany ciąg znaków
  int countdown = 3;                   // Odliczanie 3, 2, 1
  bool showingSequence = false;        // Czy pokazujemy ciąg?
  Timer? countdownTimer;               // Timer odliczania
  Timer? displayTimer;                 // Timer czasu wyświetlania
  int elapsedSeconds = 0;              // Ile sekund użytkownik patrzy
  DateTime? displayStartTime;          // Kiedy zaczęto wyświetlać

  @override
  void initState() {
    super.initState();
    sequence = _generateSequence();  // Wygeneruj losowy ciąg
    
    // Jeśli pierwsza próba - pokaż odliczanie, inaczej od razu ciąg
    widget.isFirstAttempt ? _startCountdown() : _showSequence();
  }

  // ============================================================
  // FUNKCJA: Generuj losowy ciąg znaków
  // ============================================================
  String _generateSequence() {
    final random = Random();  // Generator liczb losowych
    String chars = '';  // Znaki do wyboru
    
    // Wybierz zestaw znaków zależnie od typu
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
    }
    
    // List.generate - tworzy listę o określonej długości
    // .join() - łączy elementy listy w string
    return List.generate(
      widget.sequenceLength,
      (index) => chars[random.nextInt(chars.length)]  // Losowy znak
    ).join();
  }

  // ============================================================
  // FUNKCJA: Rozpocznij odliczanie 3, 2, 1
  // ============================================================
  void _startCountdown() {
    countdownTimer = Timer.periodic(
      const Duration(seconds: 1), 
      (timer) {
        if (countdown > 0) {
          setState(() => countdown--);  // Zmniejsz licznik
        } else {
          timer.cancel();  // Zatrzymaj timer
          _showSequence();  // Pokaż ciąg
        }
      }
    );
  }

  // ============================================================
  // FUNKCJA: Pokaż ciąg znaków
  // ============================================================
  void _showSequence() {
    setState(() {
      showingSequence = true;
      elapsedSeconds = 0;
      displayStartTime = DateTime.now();  // Zapisz czas rozpoczęcia
    });
    
    // Timer zliczający sekundy wyświetlania
    displayTimer = Timer.periodic(
      const Duration(seconds: 1), 
      (timer) {
        setState(() => elapsedSeconds++);
      }
    );
  }

  // ============================================================
  // FUNKCJA: Przejdź do ekranu wprowadzania odpowiedzi
  // ============================================================
  void _goToInput([String? firstChar]) {
    // [String? firstChar] - opcjonalny parametr
    // Używany gdy użytkownik zaczął pisać podczas wyświetlania
    
    countdownTimer?.cancel();  // Zatrzymaj timery
    displayTimer?.cancel();
    
    // Oblicz czas wyświetlania
    final displayTime = displayStartTime != null 
        ? DateTime.now().difference(displayStartTime!).inSeconds 
        : 0;
    
    if (mounted) {  // Sprawdź czy widget nadal istnieje
      // Navigator.pushReplacement - zastępuje obecny ekran nowym
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => InputScreen(
            correctSequence: sequence,
            onComplete: widget.onComplete,
            firstChar: firstChar,  // Pierwszy wpisany znak (jeśli był)
            displayTime: displayTime,
            sequenceType: widget.sequenceType,
          ),
        )
      );
    }
  }

  @override
  void dispose() {
    // Zatrzymaj timery przy usuwaniu widgetu
    countdownTimer?.cancel();
    displayTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // FUNKCJA POMOCNICZA: Odmień słowo "próba"
  // ============================================================
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
        automaticallyImplyLeading: false,  // Bez przycisku wstecz
      ),
      
      // GestureDetector - wykrywa gesty (tap, swipe itp.)
      body: GestureDetector(
        onTap: showingSequence ? () => _goToInput() : null,
        
        // RawKeyboardListener - wykrywa naciśnięcia klawiszy
        child: RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          autofocus: true,
          onKey: (event) {
            // Jeśli pokazujemy ciąg i naciśnięto klawisz
            if (showingSequence && event.runtimeType.toString() == 'RawKeyDownEvent') {
              final char = event.character;
              if (char != null && char.isNotEmpty) {
                _goToInput(char);  // Przejdź z pierwszym znakiem
              }
            }
          },
          child: Container(
            color: Colors.white,
            child: Center(
              child: showingSequence
                  // ===== EKRAN WYŚWIETLANIA CIĄGU =====
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Wyświetl ciąg znaków dużą czcionką
                        Text(
                          sequence,
                          style: const TextStyle(
                            fontSize: 48, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 8  // Odstęp między literami
                          )
                        ),
                        const SizedBox(height: 40),
                        
                        // ===== LICZNIK CZASU =====
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
                        
                        // ===== INSTRUKCJA =====
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
                              // Informacja ile prób pozostało
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
                  // ===== EKRAN ODLICZANIA =====
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
  // TextEditingController - kontroluje zawartość pola tekstowego
  final TextEditingController _controller = TextEditingController();
  DateTime? startTime;  // Czas rozpoczęcia wpisywania

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();  // Zapisz czas rozpoczęcia
    
    // Jeśli był pierwszy znak, dodaj go do pola
    if (widget.firstChar != null) {
      _controller.text = widget.firstChar!;
      // Ustaw kursor na końcu tekstu
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length)
      );
    }
  }

  // ============================================================
  // FUNKCJA: Filtruj wpisywane znaki
  // ============================================================
  // Blokuje wpisywanie nieprawidłowych znaków
  String _filterInput(String input) {
    String filtered = '';
    
    // Regex (wyrażenie regularne) do filtrowania
    switch (widget.sequenceType) {
      case 'Cyfry':
        // [^0-9] - wszystko co NIE jest cyfrą
        filtered = input.replaceAll(RegExp(r'[^0-9]'), '');
        break;
      case 'Litery':
        // [^A-Za-z] - wszystko co NIE jest literą
        filtered = input.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
        break;
      case 'Mieszane':
        // [^A-Za-z0-9] - wszystko co NIE jest literą ani cyfrą
        filtered = input.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
        break;
    }
    
    // Ogranicz długość do długości ciągu
    if (filtered.length > widget.correctSequence.length) {
      filtered = filtered.substring(0, widget.correctSequence.length);
    }
    
    return filtered;
  }

  // ============================================================
  // FUNKCJA: Sprawdź odpowiedź
  // ============================================================
  void _checkAnswer() {
    final userAnswer = _controller.text.toUpperCase();
    final totalTime = DateTime.now().difference(startTime!).inSeconds;
    
    final correct = widget.correctSequence.toUpperCase();
    int correctPositions = 0;
    
    // Policz ile znaków jest na właściwych pozycjach
    for (int i = 0; i < correct.length && i < userAnswer.length; i++) {
      if (correct[i] == userAnswer[i]) correctPositions++;
    }
    
    // Oblicz dokładność w procentach
    final double accuracy = correctPositions / correct.length * 100;
    
    // Stwórz obiekt z wynikiem
    final result = AttemptResult(
      correctSequence: widget.correctSequence,
      userAnswer: userAnswer,
      responseTime: widget.displayTime + totalTime,  // Całkowity czas
      displayTime: widget.displayTime,
      accuracy: accuracy,
      correctPositions: correctPositions,
    );
    
    // Przejdź do ekranu feedbacku
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => QuickFeedbackScreen(
          result: result,
          onContinue: () {
            widget.onComplete(result);  // Wywołaj callback
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
              
              // ===== POLE TEKSTOWE =====
              TextField(
                controller: _controller,
                autofocus: true,  // Automatycznie aktywuj pole
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: widget.correctSequence.length,  // Max znaków
                style: const TextStyle(
                  fontSize: 32, 
                  letterSpacing: 8, 
                  fontWeight: FontWeight.bold
                ),
                decoration: InputDecoration(
                  hintText: 'Wpisz tutaj...',
                  // Licznik znaków X/Y
                  counterText: '${_controller.text.length}/${widget.correctSequence.length}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                ),
                // onChanged - wywoływane przy każdej zmianie tekstu
                onChanged: (value) {
                  final filtered = _filterInput(value);
                  if (filtered != value) {
                    // Zaktualizuj pole jeśli coś zostało odfiltrowane
                    _controller.value = TextEditingValue(
                      text: filtered,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: filtered.length)
                      ),
                    );
                  }
                },
                // onSubmitted - wywoływane po Enter
                onSubmitted: (_) => _checkAnswer(),
              ),
              const SizedBox(height: 40),
              
              // ===== PRZYCISK SPRAWDŹ =====
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
    _controller.dispose();  // Zwolnij zasoby
    super.dispose();
  }
}

// ============================================================
// EKRAN SZYBKIEGO FEEDBACKU - QuickFeedbackScreen
// ============================================================
// Pokazuje krótką informację o wyniku próby (2 sekundy)
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
    // Po 2 sekundach automatycznie przejdź dalej
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onContinue();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sprawdź czy odpowiedź była perfekcyjna
    final isPerfect = widget.result.correctSequence.toUpperCase() == 
                      widget.result.userAnswer.toUpperCase();

    return Scaffold(
      body: Container(
        // Kolor tła zależny od wyniku
        color: isPerfect ? Colors.green[50] : Colors.orange[50],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikona sukcesu lub informacji
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
                
                // ===== KARTA Z WYNIKAMI =====
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

  // Funkcja pomocnicza: wiersz z etykietą i wartością
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}
// ============================================================
// EKRAN WYNIKÓW SESJI - SessionResultScreen
// ============================================================
// Pokazuje szczegółowe statystyki z całej sesji treningowej
class SessionResultScreen extends StatelessWidget {
  final List<AttemptResult> results;
  final int sequenceLength;

  const SessionResultScreen({
    super.key,
    required this.results,
    required this.sequenceLength,
  });

  @override
  Widget build(BuildContext context) {
    // ===== OBLICZ STATYSTYKI =====
    
    // Średnia dokładność ze wszystkich prób
    final avgAccuracy = results
      .map((r) => r.accuracy)
      .reduce((a, b) => a + b) / results.length;
    
    // Średni całkowity czas
    final avgTotalTime = results
      .map((r) => r.responseTime)
      .reduce((a, b) => a + b) / results.length;
    
    // Średni czas zapamiętania
    final avgDisplayTime = results
      .map((r) => r.displayTime)
      .reduce((a, b) => a + b) / results.length;
    
    // Liczba perfekcyjnych odpowiedzi (100%)
    final perfectCount = results.where((r) => r.accuracy == 100.0).length;
    
    // Najlepsza dokładność
    final bestAccuracy = results
      .map((r) => r.accuracy)
      .reduce((a, b) => a > b ? a : b);
    
    // Najgorsza dokładność
    final worstAccuracy = results
      .map((r) => r.accuracy)
      .reduce((a, b) => a < b ? a : b);
    
    // Najkrótszy czas
    final shortestTime = results
      .map((r) => r.responseTime)
      .reduce((a, b) => a < b ? a : b);
    
    // Najdłuższy czas
    final longestTime = results
      .map((r) => r.responseTime)
      .reduce((a, b) => a > b ? a : b);
    
    // ===== OBLICZ TREND (CZY SIĘ POPRAWIASZ?) =====
    
    // Podziel wyniki na dwie połowy
    final firstHalf = results.take(results.length ~/ 2).toList();
    final secondHalf = results.skip(results.length ~/ 2).toList();
    
    // Średnia z pierwszej połowy
    final firstHalfAvg = firstHalf.isEmpty ? 0.0 : 
      firstHalf.map((r) => r.accuracy).reduce((a, b) => a + b) / firstHalf.length;
    
    // Średnia z drugiej połowy
    final secondHalfAvg = secondHalf.isEmpty ? 0.0 : 
      secondHalf.map((r) => r.accuracy).reduce((a, b) => a + b) / secondHalf.length;
    
    // Poprawa (może być ujemna jeśli pogorszenie)
    final improvement = secondHalfAvg - firstHalfAvg;

    // ===== OGÓLNA OCENA =====
    
    String overallRating;  // Tekst oceny
    Color ratingColor;     // Kolor oceny
    IconData ratingIcon;   // Ikona oceny
    
    // Przypisz ocenę na podstawie średniej dokładności
    if (avgAccuracy >= 90) {
      overallRating = 'DOSKONALE!';
      ratingColor = Colors.green;
      ratingIcon = Icons.emoji_events;  // Ikona pucharu
    } else if (avgAccuracy >= 70) {
      overallRating = 'DOBRZE!';
      ratingColor = Colors.blue;
      ratingIcon = Icons.thumb_up;
    } else if (avgAccuracy >= 50) {
      overallRating = 'NIEŹLE!';
      ratingColor = Colors.orange;
      ratingIcon = Icons.sentiment_satisfied;
    } else {
      overallRating = 'WYMAGAJ WIĘCEJ!';
      ratingColor = Colors.red;
      ratingIcon = Icons.trending_up;
    }

    // ===== BUDUJ INTERFEJS =====
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki Sesji'),
        automaticallyImplyLeading: false,  // Bez przycisku wstecz
      ),
      
      // SingleChildScrollView - umożliwia przewijanie gdy treść jest za długa
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // ===== OGÓLNA OCENA (NA GÓRZE) =====
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),  // Przezroczysty kolor
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ratingColor, width: 3),
                ),
                child: Column(
                  children: [
                    Icon(ratingIcon, size: 80, color: ratingColor),
                    const SizedBox(height: 16),
                    Text(
                      'SESJA ZAKOŃCZONA!',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: ratingColor
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      overallRating,
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold, 
                        color: ratingColor
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Średnia dokładność: ${avgAccuracy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20, 
                        color: ratingColor, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // ===== KARTA Z PODSUMOWANIEM =====
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'PODSUMOWANIE',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const Divider(),
                      
                      // Podstawowe statystyki
                      _buildStatRow('Liczba prób:', '${results.length}'),
                      _buildStatRow(
                        'Perfekcyjne:', 
                        '$perfectCount (${(perfectCount / results.length * 100).toStringAsFixed(1)}%)'
                      ),
                      
                      const Divider(height: 20),
                      const Text(
                        'DOKŁADNOŚĆ', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        )
                      ),
                      _buildStatRow('Średnia:', '${avgAccuracy.toStringAsFixed(1)}%'),
                      _buildStatRow('Najlepsza:', '${bestAccuracy.toStringAsFixed(1)}%'),
                      _buildStatRow('Najgorsza:', '${worstAccuracy.toStringAsFixed(1)}%'),
                      
                      // Pokaż trend tylko jeśli jest znaczący (>0.1%)
                      if (improvement.abs() > 0.1)
                        _buildStatRow(
                          'Trend:', 
                          improvement > 0 
                            ? '+${improvement.toStringAsFixed(1)}% ⬆️'  // Poprawa
                            : '${improvement.toStringAsFixed(1)}% ⬇️'   // Pogorszenie
                        ),
                      
                      const Divider(height: 20),
                      const Text(
                        'CZASY', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        )
                      ),
                      _buildStatRow(
                        'Średni całkowity:', 
                        '${avgTotalTime.toStringAsFixed(1)} sek'
                      ),
                      _buildStatRow(
                        'Średni zapamiętania:', 
                        '${avgDisplayTime.toStringAsFixed(1)} sek'
                      ),
                      _buildStatRow('Najkrótszy:', '$shortestTime sek'),
                      _buildStatRow('Najdłuższy:', '$longestTime sek'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // ===== KARTA Z WNIOSKAMI I RADAMI =====
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, 
                            color: Colors.amber[700], size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'WNIOSKI',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      
                      // ===== DYNAMICZNE WNIOSKI =====
                      
                      // Jeśli duża poprawa
                      if (improvement > 5) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '🎉 Świetnie! Twoja dokładność poprawiła się o ${improvement.toStringAsFixed(1)}% w drugiej połowie sesji!',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] 
                      // Jeśli duże pogorszenie
                      else if (improvement < -5) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '💡 Twoja dokładność spadła w drugiej połowie. Rozważ krótsze sesje lub więcej przerw.',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] 
                      // Jeśli stały poziom
                      else ...[
                        const Text(
                          '✓ Utrzymałeś stały poziom przez całą sesję.'
                        ),
                      ],
                      
                      // Rada jeśli szybko patrzy ale słabo
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
              
              // ===== SZCZEGÓŁY WSZYSTKICH PRÓB =====
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
                      
                      // List.generate - tworzy listę widgetów
                      // Dla każdego wyniku stwórz kontener
                      ...List.generate(results.length, (index) {
                        final result = results[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // Zielone tło dla perfekcyjnych odpowiedzi
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
                              // Nagłówek próby
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
                              
                              // Szczegóły próby
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
              
              // ===== PRZYCISKI NA DOLE =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Przycisk POWRÓT
                  ElevatedButton.icon(
                    onPressed: () {
                      // popUntil - usuwa ekrany ze stosu aż do pierwszego
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
                  
                  // Przycisk NOWA SESJA
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
      ),
    );
  }

  // ============================================================
  // FUNKCJA POMOCNICZA: Wiersz ze statystyką
  // ============================================================
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
// KONIEC PLIKU
// ============================================================