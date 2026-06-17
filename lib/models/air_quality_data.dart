class AirQualityData {
  final int aqi;
  final double pm25;
  final double pm10;
  final double co2;
  final double voc;
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final String? location;

  const AirQualityData({
    required this.aqi,
    this.pm25 = 0.0,
    this.pm10 = 0.0,
    this.co2 = 0.0,
    this.voc = 0.0,
    this.temperature = 0.0,
    this.humidity = 0.0,
    required this.timestamp,
    this.location,
  });

  factory AirQualityData.mock() {
    return AirQualityData(
      aqi: 72,
      pm25: 18.5,
      pm10: 34.2,
      co2: 420.0,
      voc: 0.15,
      temperature: 24.5,
      humidity: 58.0,
      timestamp: DateTime.now(),
      location: 'Room A - Lab',
    );
  }

  String get aqiCategory {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  AirQualityData copyWith({
    int? aqi,
    double? pm25,
    double? pm10,
    double? co2,
    double? voc,
    double? temperature,
    double? humidity,
    DateTime? timestamp,
    String? location,
  }) {
    return AirQualityData(
      aqi: aqi ?? this.aqi,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
      co2: co2 ?? this.co2,
      voc: voc ?? this.voc,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
    );
  }
}

class SensorNode {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final AirQualityData currentReading;

  const SensorNode({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.currentReading,
  });
}

class HealthTip {
  final String title;
  final String description;
  final String icon;
  final int minAqi;
  final int maxAqi;

  const HealthTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.minAqi,
    required this.maxAqi,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
