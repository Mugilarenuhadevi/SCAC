import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/air_quality_data.dart';
import '../services/mock_data_service.dart';
import '../services/firebase_service.dart';
import '../services/voice_alert_service.dart';

// Live Air Quality Data Provider - streams real-time data from Firebase
final liveAirQualityProvider = StreamProvider<AirQualityData>((ref) {
  try {
    return FirebaseService.getLiveReadings().handleError((e) {
      debugPrint('Live Data Stream Error: $e');
      return MockDataService.generateReading();
    });
  } catch (e) {
    debugPrint('Live Data Provider Error: $e');
    return MockDataService.getLiveReadings();
  }
});

// Current reading as a state (synced with the live provider)
final currentReadingProvider = StateNotifierProvider<CurrentReadingNotifier, AirQualityData>((ref) {
  final notifier = CurrentReadingNotifier();
  
  // Listen to the live stream and update the state
  ref.listen(liveAirQualityProvider, (previous, next) {
    next.whenData((data) {
      notifier.updateState(data);
    });
  });
  
  return notifier;
});

class CurrentReadingNotifier extends StateNotifier<AirQualityData> {
  CurrentReadingNotifier() : super(MockDataService.generateReading());

  void updateState(AirQualityData data) {
    state = data;
    VoiceAlertService.checkAndAlert(data.aqi);
  }

  void refresh() {
    state = MockDataService.generateReading();
  }
}

// Neutralizer state
final neutralizerActiveProvider = StateProvider<bool>((ref) => false);

// History data from Firebase
final historyDataProvider = FutureProvider.family<List<AirQualityData>, int>((ref, hours) async {
  try {
    return await FirebaseService.getHistory(limit: hours * 4);
  } catch (e) {
    debugPrint('History Provider Error: $e. Falling back to Mock Data.');
    return MockDataService.generateHistory(hours: hours);
  }
});

// Selected date for history
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Sensor nodes for map
final sensorNodesProvider = Provider<List<SensorNode>>((ref) {
  return MockDataService.getSensorNodes();
});

// Health tips based on current AQI
final healthTipsProvider = Provider<List<HealthTip>>((ref) {
  final reading = ref.watch(currentReadingProvider);
  return MockDataService.getHealthTips(reading.aqi);
});

// Prediction data
final predictionProvider = Provider<Map<String, dynamic>>((ref) {
  ref.watch(currentReadingProvider); // Re-compute when reading changes
  return MockDataService.getPrediction();
});

// Chat messages
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier()
      : super([
          ChatMessage(
            text: 'Hello! 👋 I\'m your Air Quality AI Assistant. Ask me anything about air quality, the neutralizer system, or health recommendations!',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]);

  void sendMessage(String text) {
    // Add user message
    state = [
      ...state,
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    ];

    // Simulate AI response delay
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = MockDataService.getChatResponse(text);
      state = [
        ...state,
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      ];
    });
  }

  void clearChat() {
    state = [
      ChatMessage(
        text: 'Chat cleared. How can I help you?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

// Navigation index
final selectedTabProvider = StateProvider<int>((ref) => 0);
