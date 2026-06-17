import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/air_quality_data.dart';
import 'mock_data_service.dart';

class FirebaseService {
  static const String databaseUrl = 'https://smartairaqi-default-rtdb.firebaseio.com';

  // ── Corrected paths based on Firebase Console ──
  static const String _livePath    = 'AirQuality/Live';
  static const String _historyPath = 'AirQuality/History';

  static bool get _ready => Firebase.apps.isNotEmpty;

  static FirebaseDatabase? get _db {
    if (!_ready) return null;
    try {
      return FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: databaseUrl);
    } catch (e) {
      debugPrint('[Firebase] DB instance error: $e');
      return null;
    }
  }

  // ── LIVE READINGS ──────────────────────────────────────────────────
  static Stream<AirQualityData> getLiveReadings() {
    final db = _db;
    if (db == null) {
      debugPrint('[Firebase] Not initialized – using mock live data');
      return MockDataService.getLiveReadings();
    }

    debugPrint('[Firebase] Listening to live path: $_livePath');
    return db.ref(_livePath).onValue.map((event) {
      final raw = event.snapshot.value;
      debugPrint('[Firebase] Live snapshot: $raw');
      if (raw == null) return MockDataService.generateReading();
      return _map(raw as Map<dynamic, dynamic>);
    }).handleError((e) {
      debugPrint('[Firebase] Live stream error: $e');
      return MockDataService.generateReading();
    });
  }

  // ── HISTORY (last N records) ───────────────────────────────────────
  static Future<List<AirQualityData>> getHistory({int limit = 100}) async {
    final db = _db;
    if (db == null) return MockDataService.generateHistory();

    try {
      // Since data is nested under dates (e.g. AirQuality/History/04-02-2026)
      // we fetch the whole History node and flatten it.
      final snapshot = await db.ref(_historyPath).get();
      final raw = snapshot.value;
      
      if (raw == null) return [];

      List<AirQualityData> allResults = [];

      if (raw is Map) {
        // raw is { "04-02-2026": { "record1": {...}, "record2": {...} }, "05-02-2026": {...} }
        raw.forEach((dateKey, dateData) {
          if (dateData is Map) {
            dateData.forEach((recordKey, recordValue) {
              if (recordValue is Map) {
                allResults.add(_map(recordValue));
              }
            });
          }
        });
      }

      // Sort by timestamp descending
      allResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return allResults.take(limit).toList();
    } catch (e) {
      debugPrint('[Firebase] History fetch error: $e');
      return [];
    }
  }

  // ── DATA MAPPER ────────────────────────────────────────────────────
  static AirQualityData _map(Map<dynamic, dynamic> d) {
    num? n(dynamic v) => v is num ? v : null;
    
    return AirQualityData(
      aqi:         n(d['aqi'] ?? d['AQI'])?.toInt() ?? 0,
      pm25:        n(d['pm25'] ?? d['PM25'] ?? d['pm2.5'])?.toDouble() ?? 0.0,
      pm10:        n(d['pm10'] ?? d['PM10'])?.toDouble() ?? 0.0,
      co2:         n(d['co2'] ?? d['CO2'])?.toDouble() ?? 0.0,
      voc:         n(d['voc'] ?? d['VOC'])?.toDouble() ?? 0.0,
      temperature: n(d['temp'] ?? d['temperature'] ?? d['Temp'])?.toDouble() ?? 0.0,
      humidity:    n(d['humidity'] ?? d['Humidity'])?.toDouble() ?? 0.0,
      timestamp:   d['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(d['timestamp'] as int)
          : DateTime.now(),
      location:    d['location'] as String? ?? 'Main Sensor',
    );
  }
}
