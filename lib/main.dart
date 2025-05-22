import 'package:flutter/material.dart';
import 'package:focus_flash/widgets/flashcards/animated_flashcard_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Flashcards',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FlashcardScreen(),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  // Example questions and answers
  final List<Map<String, String>> _flashcardData = [
    {"question": "What is the capital of France?", "answer": "Paris"},

    {"question": "What is 2 + 2?", "answer": "4"},
    {"question": "What language is Flutter written in?", "answer": "Dart"},
    {
      "question": "What does API stand for?",
      "answer": "Application Programming Interface",
    },
    {
      "question": "What is the largest planet in our solar system?",
      "answer": "Jupiter",
    },
  ];

  int _currentIndex = 0;
  bool _isTransitioning = false; // Prevent rapid button presses

  void _nextCard() {
    if (_isTransitioning) return; // Prevent multiple rapid presses

    setState(() {
      _isTransitioning = true;
    });

    // Small delay to ensure smooth transition
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _flashcardData.length;
          _isTransitioning = false;
        });
      }
    });
  }

  void _previousCard() {
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentIndex =
              _currentIndex == 0
                  ? _flashcardData.length - 1
                  : _currentIndex - 1;
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _flashcardData[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Flashcards'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Progress indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Card ${_currentIndex + 1} of ${_flashcardData.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 10.0,
                ),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _flashcardData.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // The flashcard widget
              AnimatedFlashcard(
                key: ValueKey(_currentIndex),
                question: currentCard['question']!,
                answer: currentCard['answer']!,
                onCorrect: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Correct! 🎉'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Auto-advance to next card after showing the answer for a moment
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) _nextCard();
                  });
                },
                onIncorrect: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect. Try again! 🤔'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: _isTransitioning ? null : _previousCard,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                  ),

                  // Reset button (recreates the widget)
                  ElevatedButton.icon(
                    onPressed:
                        _isTransitioning
                            ? null
                            : () {
                              setState(() {
                                // This will recreate the AnimatedFlashcard widget
                              });
                            },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[300],
                      foregroundColor: Colors.black87,
                    ),
                  ),

                  // Next button
                  ElevatedButton.icon(
                    onPressed: _isTransitioning ? null : _nextCard,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
