import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

// ApiService talks to two completely FREE APIs — no account or key needed:
//
//  1. Open-Meteo Geocoding  → city name → latitude + longitude
//     https://geocoding-api.open-meteo.com
//
//  2. Open-Meteo Forecast   → lat/lon → current + hourly + daily weather
//     https://api.open-meteo.com
class ApiService {
  // ── Step 1: Geocode ────────────────────────────────────────────────────────
  // Converts a city name (e.g. "Mumbai") into its GPS coordinates.
  Future<Map<String, dynamic>> _geocode(String city) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Network error. Check your internet connection.');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['results'] == null || (data['results'] as List).isEmpty) {
      throw Exception(
        'City "$city" not found. Check the spelling and try again.',
      );
    }

    final r = data['results'][0] as Map<String, dynamic>;
    return {
      'name': r['name'],
      'country': r['country'] ?? '',
      'latitude': r['latitude'],
      'longitude': r['longitude'],
    };
  }

  // ── Step 2: Fetch Full Weather ─────────────────────────────────────────────
  // Uses the coordinates to get current + 24h hourly + 7-day daily weather.
  Future<WeatherModel> fetchWeather(String city) async {
    final geo = await _geocode(city);
    final lat = geo['latitude'];
    final lon = geo['longitude'];
    final cityName = '${geo['name']}, ${geo['country']}';

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,apparent_temperature,'
      'relative_humidity_2m,wind_speed_10m,weather_code,is_day'
      '&hourly=temperature_2m,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto'
      '&wind_speed_unit=ms'
      '&forecast_days=7',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load weather data. Please try again.');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final hourlyData = data['hourly'] as Map<String, dynamic>;
    final dailyData = data['daily'] as Map<String, dynamic>;

    final int code = (current['weather_code'] as num).toInt();
    final bool isDay = (current['is_day'] as num) == 1;

    // ── Parse Hourly ──────────────────────────────────────────────────────
    // Open-Meteo returns 168 hourly values (7 days × 24 hours).
    // We find the current hour and show the next 24.
    final List<String> hourlyTimes = List<String>.from(hourlyData['time']);
    final List<double> hourlyTemps = (hourlyData['temperature_2m'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final List<int> hourlyCodes = (hourlyData['weather_code'] as List)
        .map((e) => (e as num).toInt())
        .toList();

    // Find the first hourly slot that is >= now
    final now = DateTime.now();
    int startIdx = 0;
    for (int i = 0; i < hourlyTimes.length; i++) {
      if (!DateTime.parse(hourlyTimes[i]).isBefore(now)) {
        startIdx = i;
        break;
      }
    }

    final List<HourlyForecast> hourlyForecast = [];
    for (int i = startIdx; i < startIdx + 24 && i < hourlyTimes.length; i++) {
      final t = DateTime.parse(hourlyTimes[i]);
      hourlyForecast.add(
        HourlyForecast(
          time: '${t.hour.toString().padLeft(2, '0')}:00',
          temp: hourlyTemps[i],
          weatherCode: hourlyCodes[i],
        ),
      );
    }

    // ── Parse Daily ───────────────────────────────────────────────────────
    final List<String> dailyTimes = List<String>.from(dailyData['time']);
    final List<double> maxTemps = (dailyData['temperature_2m_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final List<double> minTemps = (dailyData['temperature_2m_min'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final List<int> dailyCodes = (dailyData['weather_code'] as List)
        .map((e) => (e as num).toInt())
        .toList();

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final List<DailyForecast> dailyForecast = [];
    for (int i = 0; i < dailyTimes.length; i++) {
      final d = DateTime.parse(dailyTimes[i]);
      dailyForecast.add(
        DailyForecast(
          day: i == 0 ? 'Today' : dayNames[d.weekday - 1], // 1=Mon … 7=Sun
          date: '${monthNames[d.month - 1]} ${d.day}',
          maxTemp: maxTemps[i],
          minTemp: minTemps[i],
          weatherCode: dailyCodes[i],
        ),
      );
    }

    return WeatherModel(
      cityName: cityName,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      condition: WeatherModel.descriptionFromCode(code),
      weatherCode: code,
      isDay: isDay,
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
    );
  }
}
