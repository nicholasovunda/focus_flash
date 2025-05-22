import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedFlashcard extends StatefulWidget {
  final String question;
  final String answer;
  final VoidCallback? onCorrect; // Optional: Callback when answer is correct
  final VoidCallback?
  onIncorrect; // Optional: Callback when answer is incorrect

  const AnimatedFlashcard({
    super.key,
    required this.question,
    required this.answer,
    this.onCorrect,
    this.onIncorrect,
  });

  @override
  _AnimatedFlashcardState createState() => _AnimatedFlashcardState();
}

class _AnimatedFlashcardState extends State<AnimatedFlashcard>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation; // For horizontal shake offset

  final TextEditingController _answerController = TextEditingController();
  bool _isFrontVisible = true; // Tracks the logical side of the card
  bool _showErrorBorder = false;
  bool _isAnimatingFlip = false; // To prevent multiple flip triggers

  @override
  void initState() {
    super.initState();

    // Flip Animation (0.0 to 1.0, representing 0 to PI radians)
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    // Shake Animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -10.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10.0, end: 10.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 10.0, end: -10.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10.0, end: 10.0),
        weight: 2,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shakeController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_isAnimatingFlip || !_isFrontVisible) {
      return;
    }

    final userAnswer = _answerController.text.trim();
    if (userAnswer.toLowerCase() == widget.answer.toLowerCase()) {
      // Correct Answer
      setState(() {
        _showErrorBorder = false;
        _isAnimatingFlip = true;
      });

      _flipController.forward().then((_) {
        if (mounted) {
          setState(() {
            _isFrontVisible = false; // Logically, back is now visible
            _isAnimatingFlip = false;
          });
          widget.onCorrect?.call();
        }
      });
      _answerController.clear();
    } else {
      // Incorrect Answer
      setState(() {
        _showErrorBorder = true;
      });
      _shakeController.forward(from: 0.0).then((_) {
        // Optionally, remove border after a short delay
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && _showErrorBorder) {
            // Check if still relevant
            setState(() {
              _showErrorBorder = false;
            });
          }
        });
      });
      widget.onIncorrect?.call();
    }
  }

  // Allows flipping back to the front (e.g., for a new question or reset)
  void flipToFront() {
    if (_isAnimatingFlip || _isFrontVisible) return;

    setState(() {
      _isAnimatingFlip = true;
    });
    _flipController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isFrontVisible = true;
          _isAnimatingFlip = false;
        });
      }
    });
  }

  Widget _buildCardFace(String text, Color backgroundColor) {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color:
              ThemeData.estimateBrightnessForColor(backgroundColor) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Animated Card
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: AnimatedBuilder(
            animation: _flipAnimation, // Listens to the flip animation progress
            builder: (BuildContext context, Widget? child) {
              // Calculate the rotation angle based on animation value
              final angle = _flipAnimation.value * math.pi; // 0 to PI

              // Determine which side of the card is currently facing the user
              // This logic ensures the content switches exactly halfway through the flip.
              final isFrontHalf = _flipAnimation.value < 0.5;

              Widget cardContent;
              // If _isFrontVisible is true, it means the stable state IS the front.
              // So, during animation, if it's the first half, show front. If second, show back.
              // If _isFrontVisible is false, it means the stable state IS the back.
              // So, during animation (reverse), if it's first half (value > 0.5), show back. If second (value < 0.5), show front.
              if (_isFrontVisible) {
                // Currently showing front, or animating from front to back
                cardContent =
                    isFrontHalf
                        ? _buildCardFace(widget.question, Colors.blue.shade100)
                        : Transform(
                          // Counter-rotate the back face
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildCardFace(
                            widget.answer,
                            Colors.green.shade100,
                          ),
                        );
              } else {
                // Currently showing back, or animating from back to front
                cardContent =
                    isFrontHalf
                        ? Transform(
                          // Counter-rotate the back face
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildCardFace(
                            widget.answer,
                            Colors.green.shade100,
                          ),
                        )
                        : _buildCardFace(widget.question, Colors.blue.shade100);
              }

              return Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective effect
                      ..rotateY(angle), // Actual rotation
                alignment: Alignment.center,
                child: Card(
                  elevation: 0, // Shadow is handled by _buildCardFace
                  color: Colors.transparent, // Card itself is transparent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side:
                        _showErrorBorder
                            ? BorderSide(color: Colors.red.shade400, width: 3.0)
                            : BorderSide.none,
                  ),
                  child: cardContent,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Answer Text Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(),
              hintText: 'Type your answer here',
            ),
            onSubmitted: (_) => _checkAnswer(),
            enabled: _isFrontVisible && !_isAnimatingFlip,
          ),
        ),
        const SizedBox(height: 10),

        // Submit Button
        ElevatedButton(
          onPressed:
              (_isFrontVisible && !_isAnimatingFlip) ? _checkAnswer : null,
          child: const Text('Submit Answer'),
        ),

        // Example: Button to flip back (for testing or new card)
        // TextButton(
        //   onPressed: flipToFront,
        //   child: Text("Show Question Again"),
        // ),
      ],
    );
  }
}
