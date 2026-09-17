import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech used by voice reminders, daily orientation and familiar
/// faces (FR-10, FR-12, FR-13). Works fully offline.
class SpeechService {
  SpeechService() {
    _tts
      ..setLanguage('ar-SA')
      ..setSpeechRate(0.42)
      ..setPitch(1.0);
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());
