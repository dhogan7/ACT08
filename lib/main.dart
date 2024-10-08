import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Import the just_audio package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HalloweenGame(),
    );
  }
}

class HalloweenGame extends StatefulWidget {
  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for sound effects
  final AudioPlayer _backgroundPlayer = AudioPlayer(); // Audio player for background music
  Timer? _movementTimer; // Timer for moving characters
  bool _isVisible = true; // Controls the visibility of characters
  bool gameOver = false;
  bool isWinner = false;

  // List of Halloween characters with their positions
  List<Offset> _characterPositions = [];
  final List<_SpookyCharacter> _characters = [
    _SpookyCharacter(name: 'Ghost', imagePath: 'assets/SpookyGhost Background Removed.png', isCorrect: false),
    _SpookyCharacter(name: 'Skeleton', imagePath: 'assets/GhostSkeleton Background Removed.png', isCorrect: true), // Correct item
    _SpookyCharacter(name: 'Dog', imagePath: 'assets/ScaryDog Background Removed.png', isCorrect: false),
  ];

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic(); // Play background music when the game starts
    _initializePositions(); // Initialize character positions
    _startCharacterMovement(); // Start automatic character movement
  }

  // Initialize character positions to be next to each other
  void _initializePositions() {
    _characterPositions = [
      const Offset(50, 300),
      const Offset(160, 300),
      const Offset(270, 300),
    ];
  }

  // Start moving characters automatically
  void _startCharacterMovement() {
    _movementTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _moveCharacters();
    });
  }

  // Move characters to random positions
  void _moveCharacters() {
    setState(() {
      _characterPositions = _characterPositions.map((pos) {
        return Offset(
          Random().nextDouble() * MediaQuery.of(context).size.width - 100,
          Random().nextDouble() * MediaQuery.of(context).size.height - 200,
        );
      }).toList();
    });
  }

  // Function to handle item selection and play sound effects
  void handleItemSelected(bool isCorrect) async {
    if (isCorrect) {
      await _audioPlayer.setAsset('assets/success_sound.wav');
      _audioPlayer.play();
      setState(() {
        isWinner = true;
        gameOver = true;
      });
    } else {
      await _audioPlayer.setAsset('assets/spooky_sound.wav');
      _audioPlayer.play();
      setState(() {
        gameOver = true;
      });
    }
    _movementTimer?.cancel(); // Stop movement after game ends
  }

  // Function to play looping background music
  Future<void> _playBackgroundMusic() async {
    try {
      await _backgroundPlayer.setAsset('assets/bg.mp3');
      _backgroundPlayer.setLoopMode(LoopMode.one);
      _backgroundPlayer.setVolume(1.0);
      _backgroundPlayer.play();
    } catch (e) {
      print("Error playing background music: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose audio players
    _backgroundPlayer.dispose();
    _movementTimer?.cancel(); // Cancel movement timer
    super.dispose();
  }

  // Toggle character visibility
  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Halloween Game'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          // Display characters at their respective positions
          for (int i = 0; i < _characters.length; i++)
            AnimatedPositioned(
              duration: const Duration(seconds: 2),
              left: _characterPositions[i].dx,
              top: _characterPositions[i].dy,
              child: GestureDetector(
                onTap: () => handleItemSelected(_characters[i].isCorrect),
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    _characters[i].imagePath,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
          // Display result message
          if (gameOver)
            Center(
              child: isWinner
                  ? const Text('Congratulations! You found the correct item!',
                      style: TextStyle(fontSize: 24, color: Colors.green))
                  : const Text('Spooky! You selected the wrong item!',
                      style: TextStyle(fontSize: 24, color: Colors.red)),
            ),
        ],
      ),
      // Button to toggle visibility of characters
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisibility,
        child: const Icon(Icons.play_arrow),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

// Helper class to represent a spooky character
class _SpookyCharacter {
  final String name;
  final String imagePath;
  final bool isCorrect;

  _SpookyCharacter({required this.name, required this.imagePath, required this.isCorrect});
}
