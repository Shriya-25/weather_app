import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/weather_model.dart';

class ApiService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherData> fetchByCity(String city) async {
    AppConfig.validate();

    final currentUrl = Uri.parse(
      '$_baseUrl/weather?q=${Uri.encodeComponent(city)}&appid=${AppConfig.openWeatherApiKey}&units=metric',
    );
    final forecastUrl = Uri.parse(
      '$_baseUrl/forecast?q=${Uri.encodeComponent(city)}&appid=${AppConfig.openWeatherApiKey}&units=metric',
    );

    return _fetchAndBuild(currentUrl, forecastUrl);
  }

  Future<WeatherData> fetchByCoordinates(double lat, double lon) async {
    AppConfig.validate();

    final currentUrl = Uri.parse(
      '$_baseUrl/weather?lat=$lat&lon=$lon&appid=${AppConfig.openWeatherApiKey}&units=metric',
    );
    final forecastUrl = Uri.parse(
      '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=${AppConfig.openWeatherApiKey}&units=metric',
    );

    return _fetchAndBuild(currentUrl, forecastUrl);
  }

  Future<WeatherData> _fetchAndBuild(Uri currentUrl, Uri forecastUrl) async {
    try {
      final responses = await Future.wait([
        http.get(currentUrl).timeout(const Duration(seconds: 12)),
        http.get(forecastUrl).timeout(const Duration(seconds: 12)),
      ]);

      final currentRes = responses[0];
      final forecastRes = responses[1];

      if (currentRes.statusCode == 404 || forecastRes.statusCode == 404) {
        throw Exception('City not found. Please search for a valid city name.');
      }

      if (currentRes.statusCode != 200 || forecastRes.statusCode != 200) {
        throw Exception('Unable to fetch weather right now. Please try again.');
      }

      final current = jsonDecode(currentRes.body) as Map<String, dynamic>;
      final forecast = jsonDecode(forecastRes.body) as Map<String, dynamic>;

      return _mapToWeather(current, forecast);
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet and retry.');
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    }
  }

  WeatherData _mapToWeather(
    Map<String, dynamic> current,
    Map<String, dynamic> forecast,
  ) {
    final city = current['name'] as String? ?? 'Unknown';
    final country = (current['sys'] as Map<String, dynamic>?)?['country'] as String?;
    final cityName = country == null ? city : '$city, $country';

    final currentMain = current['main'] as Map<String, dynamic>;
    final currentWeather =
        (current['weather'] as List).first as Map<String, dynamic>;
    final wind = current['wind'] as Map<String, dynamic>?;

    final isDay = ((currentWeather['icon'] as String?) ?? '').endsWith('d');

    final forecastList = (forecast['list'] as List)
        .cast<Map<String, dynamic>>();

    final hourly = _buildHourly(forecastList);
    final daily = _buildDaily(forecastList);

    return WeatherData(
      cityName: cityName,
      temperature: (currentMain['temp'] as num).toDouble(),
      condition: _toTitleCase(currentWeather['description'] as String? ?? 'Clear'),
      iconCode: currentWeather['icon'] as String? ?? '01d',
      feelsLike: (currentMain['feels_like'] as num).toDouble(),
      humidity: (currentMain['humidity'] as num).toInt(),
      windSpeed: ((wind?['speed'] as num?) ?? 0).toDouble(),
      isDay: isDay,
      hourly: hourly,
      daily: daily,
    );
  }

  List<HourlyForecast> _buildHourly(List<Map<String, dynamic>> list) {
    return list.take(8).map((item) {
      final weather = (item['weather'] as List).first as Map<String, dynamic>;
      return HourlyForecast(
        time: DateTime.parse(item['dt_txt'] as String),
        temp: ((item['main'] as Map<String, dynamic>)['temp'] as num).toDouble(),
        iconCode: weather['icon'] as String? ?? '01d',
        condition: weather['main'] as String? ?? 'Clear',
      );
    }).toList();
  }

  List<DailyForecast> _buildDaily(List<Map<String, dynamic>> list) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in list) {
      final dt = DateTime.parse(item['dt_txt'] as String);
      final key = '${dt.year}-${dt.month}-${dt.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final result = <DailyForecast>[];
    for (final items in grouped.values.take(7)) {
      double minTemp = double.infinity;
      double maxTemp = -double.infinity;
      Map<String, dynamic>? iconSource;

      for (final item in items) {
        final main = item['main'] as Map<String, dynamic>;
        final min = (main['temp_min'] as num).toDouble();
        final max = (main['temp_max'] as num).toDouble();
        if (min < minTemp) minTemp = min;
        if (max > maxTemp) maxTemp = max;

        final dt = DateTime.parse(item['dt_txt'] as String);
        if (iconSource == null || dt.hour == 12) {
          iconSource = item;
        }
      }

      final source = iconSource ?? items.first;
      final weather = (source['weather'] as List).first as Map<String, dynamic>;
      result.add(
        DailyForecast(
          date: DateTime.parse(source['dt_txt'] as String),
          minTemp: minTemp,
          maxTemp: maxTemp,
          iconCode: weather['icon'] as String? ?? '01d',
          condition: weather['main'] as String? ?? 'Clear',
        ),
      );
    }

    return result;
  }

  String _toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}
