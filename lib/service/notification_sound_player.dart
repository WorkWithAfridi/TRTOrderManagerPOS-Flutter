import 'package:audioplayers/audioplayers.dart';
import 'package:order_manager/service/debug/logger.dart';

class NotificationSoundPlayer {
  // Singleton instance
  static final NotificationSoundPlayer _instance =
      NotificationSoundPlayer._internal();

  // Private constructor
  NotificationSoundPlayer._internal();

  // Factory constructor to return the same instance
  factory NotificationSoundPlayer() => _instance;

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Method to play the notification sound in a loop
  Future<void> playNotification() async {
    try {
      // Set the looping mode to loop the audio
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

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

  // Method to stop the notification sound
  Future<void> stopNotification() async {
    try {
      // Stop the audio playback
      await _audioPlayer.stop();
      logger.d("STOPPED NOTIFICATION SOUND");
    } catch (e) {
      // Handle error (optional)
      print('Error stopping notification sound: $e');
    }
  }
}
