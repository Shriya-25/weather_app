import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HourlyForecast {
  final DateTime time;
  final double temp;
  final String iconCode;
  final String condition;

  const HourlyForecast({
    required this.time,
    required this.temp,
    required this.iconCode,
    required this.condition,
  });
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String iconCode;
  final String condition;

  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.iconCode,
    required this.condition,
  });

  String get dayLabel {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    return isToday ? 'Today' : DateFormat('EEE').format(date);
  }

  String get dateLabel => DateFormat('MMM d').format(date);
}

class WeatherData {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconCode;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final bool isDay;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherData({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.isDay,
    required this.hourly,
    required this.daily,
  });

  static String emojiFromIcon(String iconCode) {
    if (iconCode.startsWith('01')) return iconCode.endsWith('d') ? '☀️' : '🌙';
    if (iconCode.startsWith('02')) return '🌤️';
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) return '☁️';
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return '🌧️';
    if (iconCode.startsWith('11')) return '⛈️';
    if (iconCode.startsWith('13')) return '❄️';
    if (iconCode.startsWith('50')) return '🌫️';
    return '🌡️';
  }

  List<Color> get gradientColors {
    if (!isDay) {
      return const [Color(0xFF0A1026), Color(0xFF1B2A5B), Color(0xFF3B2F66)];
    }

    if (iconCode.startsWith('01')) {
      return const [Color(0xFFFFA85B), Color(0xFFFF6B95), Color(0xFFFF8E53)];
    }

    if (iconCode.startsWith('02') ||
        iconCode.startsWith('03') ||
        iconCode.startsWith('04')) {
      return const [Color(0xFF8EA7C2), Color(0xFFB7C8D9), Color(0xFF8CA0B5)];
    }

    if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return const [Color(0xFF4A607A), Color(0xFF6D8AA9), Color(0xFF445D7A)];
    }

    return const [Color(0xFF6D7A91), Color(0xFF8FA0B4), Color(0xFF5A6B80)];
  }

  Color get textColor {
    if (isDay &&
        (iconCode.startsWith('03') ||
            iconCode.startsWith('04') ||
            iconCode.startsWith('50'))) {
      return const Color(0xFF1E2C3D);
    }
    return Colors.white;
  }
}
