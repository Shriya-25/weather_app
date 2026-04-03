import 'package:flutter/material.dart';

// ── Hourly Forecast ────────────────────────────────────────────────────────
class HourlyForecast {
  final String time; // e.g. "14:00"
  final double temp; // celsius
  final int weatherCode; // WMO code

  const HourlyForecast({
    required this.time,
    required this.temp,
    required this.weatherCode,
  });
}

// ── Daily Forecast ─────────────────────────────────────────────────────────
class DailyForecast {
  final String day; // "Today", "Mon", "Tue" etc.
  final String date; // "Apr 3"
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  const DailyForecast({
    required this.day,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}

// ── Main Weather Model ─────────────────────────────────────────────────────
class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  const WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  // WMO weather code → human-readable description
  static String descriptionFromCode(int code) {
    const map = {
      0: 'Clear Sky',
      1: 'Mainly Clear',
      2: 'Partly Cloudy',
      3: 'Overcast',
      45: 'Foggy',
      48: 'Icy Fog',
      51: 'Light Drizzle',
      53: 'Drizzle',
      55: 'Dense Drizzle',
      61: 'Slight Rain',
      63: 'Moderate Rain',
      65: 'Heavy Rain',
      71: 'Slight Snow',
      73: 'Moderate Snow',
      75: 'Heavy Snow',
      80: 'Rain Showers',
      81: 'Heavy Showers',
      82: 'Violent Showers',
      95: 'Thunderstorm',
      99: 'Thunderstorm & Hail',
    };
    return map[code] ?? 'Unknown';
  }

  // WMO code → emoji
  static String emojiFromCode(int code, {bool isDay = true}) {
    if (code == 0) return isDay ? '☀️' : '🌙';
    if (code == 1) return isDay ? '🌤️' : '🌙';
    if (code == 2) return '⛅';
    if (code == 3) return '☁️';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 55) return '🌦️';
    if (code >= 61 && code <= 65) return '🌧️';
    if (code >= 71 && code <= 75) return '❄️';
    if (code >= 80 && code <= 82) return '⛈️';
    if (code >= 95) return '🌩️';
    return '🌡️';
  }

  // Dynamic background gradient based on weather + time of day
  List<Color> get gradientColors {
    if (!isDay) {
      return [
        const Color(0xFF0F2027),
        const Color(0xFF203A43),
        const Color(0xFF2C5364),
      ];
    }
    if (weatherCode == 0 || weatherCode == 1) {
      return [const Color(0xFFFF8C42), const Color(0xFFFF5E62)]; // Sunny
    }
    if (weatherCode == 2 || weatherCode == 3) {
      return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)]; // Cloudy
    }
    if (weatherCode >= 71 && weatherCode <= 75) {
      return [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)]; // Snow
    }
    if (weatherCode >= 51 && weatherCode <= 82) {
      return [const Color(0xFF373B44), const Color(0xFF4286f4)]; // Rain
    }
    if (weatherCode >= 95) {
      return [const Color(0xFF1c1c1c), const Color(0xFF4B4B4B)]; // Storm
    }
    return [const Color(0xFF1a237e), const Color(0xFF42a5f5)];
  }

  // Text colour that contrasts well against the gradient
  Color get textColor {
    if ((weatherCode == 2 || weatherCode == 3) && isDay)
      return const Color(0xFF2d3436);
    if (weatherCode >= 71 && weatherCode <= 75 && isDay)
      return const Color(0xFF2d3436);
    return Colors.white;
  }
}
