import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/quiz_progress_repository.dart';
import '../utils/app_colors.dart';
import 'kid_quiz_data.dart';
import 'quizzes_page.dart';

class _Vehicle {
  final String name;
  final String emoji;
  final String sound;
  final String soundFile; // lives in assets/sounds/
  final String fact;
  final Color color; // soft pastel card colour

  const _Vehicle({
    required this.name,
    required this.emoji,
    required this.sound,
    required this.soundFile,
    required this.fact,
    required this.color,
  });
}

// Sound effects sourced from Mixkit (https://mixkit.co/free-sound-effects/),
// used under the Mixkit Free License. Each file lives in assets/sounds/.
const List<_Vehicle> _vehicles = [
  _Vehicle(
    name: 'Car',
    emoji: '🚗',
    sound: 'Vrooom!',
    soundFile: 'car.mp3',
    fact: 'Cars take families on trips. We buckle up to stay safe!',
    color: Color(0xFFB3E5FC),
  ),
  _Vehicle(
    name: 'Bus',
    emoji: '🚌',
    sound: 'Beep beep!',
    soundFile: 'bus.mp3',
    fact: 'Buses carry lots of people to school and around town.',
    color: Color(0xFFFFE0B2),
  ),
  _Vehicle(
    name: 'Train',
    emoji: '🚂',
    sound: 'Choo choo!',
    soundFile: 'train.mp3',
    fact: 'Trains ride on metal tracks and can be very, very long!',
    color: Color(0xFFD7CCC8),
  ),
  _Vehicle(
    name: 'Airplane',
    emoji: '✈️',
    sound: 'Whoosh!',
    soundFile: 'airplane.mp3',
    fact: 'Airplanes fly high in the sky and carry people over oceans!',
    color: Color(0xFFB2DFDB),
  ),
  _Vehicle(
    name: 'Boat',
    emoji: '⛵',
    sound: 'Splish splash!',
    soundFile: 'boat.mp3',
    fact: 'Boats float on water and take us across rivers and seas.',
    color: Color(0xFF90CAF9),
  ),
  _Vehicle(
    name: 'Bicycle',
    emoji: '🚲',
    sound: 'Ring ring!',
    soundFile: 'bicycle.mp3',
    fact: 'You pedal a bicycle with your legs. Ring the bell to say hi!',
    color: Color(0xFFC8E6C9),
  ),
  _Vehicle(
    name: 'Motorcycle',
    emoji: '🏍️',
    sound: 'Vroom vroom!',
    soundFile: 'motorcycle.mp3',
    fact: 'Motorcycles are fast. Riders always wear a helmet!',
    color: Color(0xFFFFCCBC),
  ),
  _Vehicle(
    name: 'Helicopter',
    emoji: '🚁',
    sound: 'Whirrr!',
    soundFile: 'helicopter.mp3',
    fact: 'Helicopters have big spinning blades and can fly straight up!',
    color: Color(0xFFFFF59D),
  ),
  _Vehicle(
    name: 'Fire Truck',
    emoji: '🚒',
    sound: 'Nee-naw!',
    soundFile: 'fire_truck.mp3',
    fact: 'Fire trucks rush to fires and carry a long, squirting hose.',
    color: Color(0xFFFFCDD2),
  ),
  _Vehicle(
    name: 'Ambulance',
    emoji: '🚑',
    sound: 'Wee-woo!',
    soundFile: 'ambulance.mp3',
    fact: 'Ambulances help doctors get to people who are sick or hurt.',
    color: Color(0xFFE1BEE7),
  ),
];

/// Vehicles learning page for young children (3-6 years).
/// Tap a vehicle to hear its sound. Tap the "i" for a fun fact.
/// Tap "Take Quiz!" to play the vehicles quiz.
class VehiclesPage extends StatefulWidget {
  /// The child quiz progress is saved for. When null, the active
  /// child profile is resolved automatically when the quiz starts.
  final String? childId;

  const VehiclesPage({super.key, this.childId});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  static final FirestoreQuizProgressRepository _repository =
      FirestoreQuizProgressRepository();

  final AudioPlayer _player = AudioPlayer();
  int? _activeIndex;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  /// Plays the recorded vehicle sound effect from assets/sounds/.
  Future<void> _playSound(_Vehicle vehicle) async {
    HapticFeedback.lightImpact();
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/${vehicle.soundFile}'));
    } catch (e) {
      // Missing/unsupported file should never crash the page.
      debugPrint('Could not play ${vehicle.soundFile}: $e');
    }
  }

  Future<void> _onVehicleTap(int index) async {
    setState(() => _activeIndex = index);
    _playSound(_vehicles[index]);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted && _activeIndex == index) {
      setState(() => _activeIndex = null);
    }
  }

  void _showVehicleInfo(_Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: vehicle.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vehicle.emoji, style: const TextStyle(fontSize: 96)),
              Text(
                '${vehicle.name[0]} is for ${vehicle.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _playSound(vehicle),
                icon: const Icon(Icons.volume_up_rounded, size: 32),
                label: Text(
                  vehicle.sound,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  vehicle.fact,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.4,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.yellow,
                  size: 30,
                ),
                label: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startQuiz() async {
    try {
      final childId = widget.childId ?? await _repository.loadActiveChildId();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuizScreen(
            category: vehiclesQuizCategory,
            childId: childId,
            repository: _repository,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Could not start the vehicles quiz: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a child profile before starting the quiz.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startQuiz,
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.quiz_rounded, size: 30),
        label: const Text(
          'Take Quiz!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          final active = _activeIndex == index;
          return AnimatedScale(
            scale: active ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            child: GestureDetector(
              onTap: () => _onVehicleTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: vehicle.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: active ? AppColors.yellow : Colors.transparent,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            vehicle.emoji,
                            style: const TextStyle(fontSize: 76),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.yellow
                                  : Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.volume_up_rounded,
                                  size: 20,
                                  color: active
                                      ? Colors.white
                                      : AppColors.yellow,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    vehicle.sound,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? Colors.white
                                          : AppColors.yellow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        onPressed: () => _showVehicleInfo(vehicle),
                        icon: const Icon(Icons.info_rounded, size: 30),
                        color: AppColors.yellow,
                        tooltip: 'Learn more',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
