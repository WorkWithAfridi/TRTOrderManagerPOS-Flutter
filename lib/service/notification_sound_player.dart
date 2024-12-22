import 'package:audioplayers/audioplayers.dart';
import 'package:pdf_printer/service/debug/logger.dart';

class NotificationSoundPlayer {
  // Singleton instance
  static final NotificationSoundPlayer _instance = NotificationSoundPlayer._internal();

  // Private constructor
  NotificationSoundPlayer._internal();

  // Factory constructor to return the same instance
  factory NotificationSoundPlayer() => _instance;

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Method to play the notification sound
  Future<void> playNotification() async {
    try {
      // Load and play the audio asset
      await _audioPlayer.play(
        AssetSource(
          'sounds/notification.mp3',
        ),
      );
      logger.d("PLAYING NOTIFICATION SOUND");
    } catch (e) {
      // Handle error (optional)
      print('Error playing notification sound: $e');
    }
  }
}
