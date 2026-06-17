import 'dart:async';
import 'dart:math';
import '../models/air_quality_data.dart';

class MockDataService {
  static final Random _random = Random();

  /// Generate a realistic AQI reading with some variation
  static AirQualityData generateReading({String? location}) {
    final baseAqi = 40 + _random.nextInt(80);
    return AirQualityData(
      aqi: baseAqi,
      pm25: 5.0 + _random.nextDouble() * 45,
      pm10: 10.0 + _random.nextDouble() * 60,
      co2: 350.0 + _random.nextDouble() * 300,
      voc: _random.nextDouble() * 0.5,
      temperature: 20.0 + _random.nextDouble() * 10,
      humidity: 40.0 + _random.nextDouble() * 30,
      timestamp: DateTime.now(),
      location: location ?? 'Room A - Lab',
    );
  }

  /// Stream of live readings that updates every 3 seconds
  static Stream<AirQualityData> getLiveReadings({String? location}) {
    return Stream.periodic(
      const Duration(seconds: 3),
      (_) => generateReading(location: location),
    );
  }

  /// Generate historical data for the past N hours
  static List<AirQualityData> generateHistory({
    int hours = 24,
    String? location,
  }) {
    final now = DateTime.now();
    return List.generate(hours * 4, (i) {
      // Create a sine-wave-like pattern for realistic data
      final hourOffset = i / 4.0;
      final timeOfDay = (now.hour - hourOffset) % 24;
      final baseAqi = (50 + 30 * sin(timeOfDay * pi / 12)).round();
      final variation = _random.nextInt(20) - 10;
      final aqi = (baseAqi + variation).clamp(10, 300);

      return AirQualityData(
        aqi: aqi,
        pm25: 3.0 + aqi * 0.3 + _random.nextDouble() * 5,
        pm10: 8.0 + aqi * 0.4 + _random.nextDouble() * 8,
        co2: 300.0 + aqi * 2.5 + _random.nextDouble() * 50,
        voc: aqi * 0.002 + _random.nextDouble() * 0.1,
        temperature: 22.0 + 3 * sin(timeOfDay * pi / 12) + _random.nextDouble() * 2,
        humidity: 50.0 + 10 * cos(timeOfDay * pi / 12) + _random.nextDouble() * 5,
        timestamp: now.subtract(Duration(minutes: (i * 15).round())),
        location: location ?? 'Room A - Lab',
      );
    }).reversed.toList();
  }

  /// Generate mock sensor nodes
  static List<SensorNode> getSensorNodes() {
    final locations = [
      {'name': 'Room A - Lab', 'lat': 13.0827, 'lng': 80.2707},
      {'name': 'Room B - Office', 'lat': 13.0835, 'lng': 80.2715},
      {'name': 'Corridor - Floor 1', 'lat': 13.0830, 'lng': 80.2710},
      {'name': 'Cafeteria', 'lat': 13.0822, 'lng': 80.2720},
      {'name': 'Outdoor Sensor', 'lat': 13.0840, 'lng': 80.2700},
    ];

    return locations.asMap().entries.map((entry) {
      final loc = entry.value;
      return SensorNode(
        id: 'node_${entry.key}',
        name: loc['name'] as String,
        latitude: loc['lat'] as double,
        longitude: loc['lng'] as double,
        currentReading: generateReading(location: loc['name'] as String),
      );
    }).toList();
  }

  /// Get health tips based on AQI
  static List<HealthTip> getHealthTips(int aqi) {
    final allTips = [
      const HealthTip(
        title: 'Air Quality is Great!',
        description: 'Perfect conditions for outdoor activities. Enjoy the fresh air!',
        icon: '🌿',
        minAqi: 0,
        maxAqi: 50,
      ),
      const HealthTip(
        title: 'Open Windows for Ventilation',
        description: 'Natural ventilation can help maintain indoor air quality.',
        icon: '🪟',
        minAqi: 0,
        maxAqi: 50,
      ),
      const HealthTip(
        title: 'Moderate Air Quality',
        description: 'Air quality is acceptable. Consider reducing prolonged outdoor exertion.',
        icon: '⚠️',
        minAqi: 51,
        maxAqi: 100,
      ),
      const HealthTip(
        title: 'Keep Windows Closed',
        description: 'High PM2.5 detected. Please keep windows closed and use air purification.',
        icon: '🏠',
        minAqi: 51,
        maxAqi: 150,
      ),
      const HealthTip(
        title: 'Activate Air Neutralizer',
        description: 'The neutralizer can help reduce harmful particles. Consider activating it now.',
        icon: '🌬️',
        minAqi: 51,
        maxAqi: 200,
      ),
      const HealthTip(
        title: 'Wear Mask Outdoors',
        description: 'If you must go outside, use an N95 mask for protection against fine particles.',
        icon: '😷',
        minAqi: 101,
        maxAqi: 300,
      ),
      const HealthTip(
        title: 'Stay Indoors',
        description: 'Air quality is hazardous. Stay indoors and avoid all outdoor physical activities.',
        icon: '🚫',
        minAqi: 201,
        maxAqi: 500,
      ),
      const HealthTip(
        title: 'Hydrate Well',
        description: 'Drink plenty of water to help your body handle the pollutants.',
        icon: '💧',
        minAqi: 51,
        maxAqi: 300,
      ),
    ];

    return allTips.where((tip) => aqi >= tip.minAqi && aqi <= tip.maxAqi).toList();
  }

  /// AI prediction - mock forecast based on historical patterns
  static Map<String, dynamic> getPrediction() {
    final currentHour = DateTime.now().hour;
    // Simulate AQI tending to be worse in mornings and evenings (traffic)
    final nextHourAqi = (50 + 30 * sin((currentHour + 1) * pi / 12) + _random.nextInt(15)).round().clamp(15, 250);
    final nextDayAqi = (55 + 20 * sin((currentHour + 12) * pi / 12) + _random.nextInt(20)).round().clamp(20, 200);

    return {
      'nextHour': nextHourAqi,
      'nextDay': nextDayAqi,
      'trend': nextHourAqi > 100 ? 'worsening' : (nextHourAqi < 50 ? 'improving' : 'stable'),
      'confidence': 75 + _random.nextInt(20),
      'factors': [
        'Traffic patterns in nearby roads',
        'Industrial activity levels',
        'Weather conditions (wind speed, humidity)',
        'Historical data correlation',
      ],
    };
  }

  /// Mock chatbot responses
  static String getChatResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('air') && lowerMessage.contains('bad')) {
      return 'Based on the current sensor readings, the air quality degradation is likely due to increased vehicular emissions during peak hours and low wind speed reducing natural dispersal of pollutants. The neutralizer is working to improve indoor conditions.';
    }
    if (lowerMessage.contains('neutralizer') || lowerMessage.contains('how') && lowerMessage.contains('work')) {
      return 'The Air Neutralizer uses a multi-stage filtration system including HEPA filters for particulate matter, activated carbon for VOCs and gases, and UV-C light for biological contaminants. When activated, it circulates room air through these filters, reducing PM2.5, CO2, and VOC levels significantly within 15-30 minutes.';
    }
    if (lowerMessage.contains('pm2.5') || lowerMessage.contains('pm 2.5')) {
      return 'PM2.5 refers to fine particulate matter with a diameter of 2.5 micrometers or less. These particles are dangerous because they can penetrate deep into the lungs and even enter the bloodstream. Current WHO guidelines recommend PM2.5 levels below 15 µg/m³ for annual averages. Our sensors measure PM2.5 in real-time to keep you informed.';
    }
    if (lowerMessage.contains('safe') || lowerMessage.contains('health')) {
      return 'Based on current AQI readings, I recommend: 1) Keep indoor ventilation active, 2) The neutralizer is maintaining safe indoor levels, 3) If going outdoors, check the real-time map for the best air quality zones. People with respiratory conditions should take extra precautions when AQI exceeds 100.';
    }
    if (lowerMessage.contains('predict') || lowerMessage.contains('forecast')) {
      return 'Our AI prediction model analyzes historical patterns, weather data, and traffic trends to forecast air quality. Currently, the model predicts a slight improvement in air quality over the next few hours as wind speeds are expected to increase, helping disperse pollutants.';
    }
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! 👋 I\'m your Air Quality AI Assistant. I can help you understand air quality data, explain how the neutralizer works, provide health recommendations, and answer questions about pollutants. What would you like to know?';
    }

    return 'That\'s a great question! Based on the current environmental data from our sensors, the air quality is being monitored in real-time. I can help you with information about air quality parameters (PM2.5, CO2, VOCs), the neutralizer system, health recommendations, or predictions. Could you be more specific about what you\'d like to know?';
  }
}
