import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Import the just_audio package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HalloweenGame(),
    );
  }
}

class HalloweenGame extends StatefulWidget {
  const HalloweenGame({super.key});

  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  bool _isVisible = true;
  bool gameOver = false;
  bool isWinner = false;

  // List of Halloween characters with their positions
  final List<_SpookyCharacter> _characters = [
    _SpookyCharacter(name: 'Ghost', imagePath: 'assets/SpookyGhost Background Removed.png', isCorrect: false),
    _SpookyCharacter(name: 'Skeleton', imagePath: 'assets/GhostSkeleton Background Removed.png', isCorrect: true), // This is the correct item
    _SpookyCharacter(name: 'Dog', imagePath: 'assets/ScaryDog Background Removed.png', isCorrect: false),
  ];

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic(); // Play background music when the game starts
  }

  // Function to handle item selection and play sound effects
  void handleItemSelected(bool isCorrect) async {
    if (isCorrect) {
      // Play success sound
      await _audioPlayer.setAsset('assets/bg.mp3');
      _audioPlayer.play();
      setState(() {
        isWinner = true;
        gameOver = true;
      });
    } else {
      // Play spooky sound
      await _audioPlayer.setAsset('assets/bg.mp3');
      _audioPlayer.play();
      setState(() {
        gameOver = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose of the audio player
    super.dispose();
  }

  // Function to play looping background music
  void _playBackgroundMusic() async {
    await _audioPlayer.setAsset('assets/bg.mp3');
    _audioPlayer.setLoopMode(LoopMode.one); // Loop the background music
    _audioPlayer.play();
  }

  // Function to randomly toggle visibility
  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const imageWidth = 100.0;
    const imageHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Halloween Game'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          // Iterate through spooky characters and display them
          for (var character in _characters)
            AnimatedPositioned(
              duration: const Duration(seconds: 3),
              left: Random().nextDouble() * (screenWidth - imageWidth),
              top: Random().nextDouble() * (screenHeight - imageHeight),
              child: GestureDetector(
                onTap: () => handleItemSelected(character.isCorrect),
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    character.imagePath,
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ),
              ),
            ),
          // Show the game result
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
