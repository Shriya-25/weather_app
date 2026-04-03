import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

// WeatherService fetches weather using two FREE APIs that need NO API key:
//
//  1. Open-Meteo Geocoding API  → converts a city name into latitude & longitude
//     https://geocoding-api.open-meteo.com/v1/search?name=Mumbai&count=1
//
//  2. Open-Meteo Forecast API   → returns current weather for a lat/lon
//     https://api.open-meteo.com/v1/forecast?latitude=19.07&longitude=72.87&current=...
//
// No account. No API key. Completely free forever.
class WeatherService {
  // Step 1 — Geocode: city name → latitude + longitude
  Future<Map<String, dynamic>> _geocodeCity(String city) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Network error. Check your internet connection.');
    }

    final data = jsonDecode(response.body);

    // If "results" is missing or empty, the city wasn't found
    if (data['results'] == null || (data['results'] as List).isEmpty) {
      throw Exception('City "$city" not found. Check the spelling and try again.');
    }

    final result = data['results'][0];
    return {
      'name': result['name'],          // proper city name
      'country': result['country'],    // country name
      'latitude': result['latitude'],
      'longitude': result['longitude'],
    };
  }

  // Step 2 — Fetch weather for given latitude & longitude
  Future<WeatherModel> fetchWeather(String city) async {
    // First get coordinates for the city
    final geo = await _geocodeCity(city);

    final lat = geo['latitude'];
    final lon = geo['longitude'];
    final cityName = '${geo['name']}, ${geo['country']}';

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,apparent_temperature,relative_humidity_2m,'
      'wind_speed_10m,weather_code'
      '&wind_speed_unit=ms', // metres per second
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data. Try again.');
    }

    final data = jsonDecode(response.body);
    final current = data['current'] as Map<String, dynamic>;
    final code = (current['weather_code'] as num).toInt();

    return WeatherModel(
      cityName: cityName,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      condition: WeatherModel.descriptionFromCode(code),
      weatherCode: code,
    );
  }
}
