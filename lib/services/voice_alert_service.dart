import 'package:flutter_tts/flutter_tts.dart';
import '../core/theme/app_theme.dart';

class VoiceAlertService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isSpeaking = false;
  static int? _lastAqi;

  static Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  static Future<void> checkAndAlert(int aqi, {String language = 'en-US'}) async {
    if (_lastAqi == aqi) return;
    _lastAqi = aqi;

    await _tts.setLanguage(language);
    bool isEnglish = language.startsWith('en');

    String label = AppColors.getAqiLabel(aqi);
    if (aqi > 100) {
      String message = isEnglish 
          ? "Warning. Air quality is $label. Air quality index is $aqi. Please turn on the neutralizer."
          : "चेतावनी। हवा की गुणवत्ता $label है। वायु गुणवत्ता सूचकांक $aqi है। कृपया न्यूट्रलाइज़र चालू करें।";
      await speak(message);
    } else if (aqi <= 50 && _isSpeaking) {
      await speak(isEnglish ? "Air quality is now Good. Thank you." : "हवा की गुणवत्ता अब अच्छी है। धन्यवाद।");
    }
  }

  static Future<void> speak(String message) async {
    _isSpeaking = true;
    await _tts.speak(message);
    _isSpeaking = false;
  }
}
