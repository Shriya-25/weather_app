import 'dart:convert';             // dart:convert lets us decode JSON text into a Dart Map
import 'package:http/http.dart' as http; // http package lets us make network requests
import '../models/weather_model.dart';

// WeatherService is responsible for talking to the OpenWeatherMap API.
// It fetches raw JSON and returns a clean WeatherModel object.
class WeatherService {
  // ── IMPORTANT ─────────────────────────────────────────────────────────────
  // Replace the string below with YOUR OWN API key from openweathermap.org
  // Steps:
  //   1. Go to https://openweathermap.org/api
  //   2. Create a free account
  //   3. Go to API keys tab → copy your key → paste it below
  // ──────────────────────────────────────────────────────────────────────────
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // This method fetches weather for a given city name.
  // "async" means: this function can pause while waiting for the internet.
  // "Future" means: it will return a value *eventually* (not instantly).
  Future<WeatherModel> fetchWeather(String city) async {
    // Build the full API URL
    final url = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey');

    // "await" pauses here until the HTTP response comes back
    final response = await http.get(url);

    // HTTP 200 means success. Anything else means something went wrong.
    if (response.statusCode == 200) {
      // response.body is a raw JSON string like: {"name":"Mumbai","main":{...}}
      // jsonDecode converts that string into a Dart Map
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      // Convert the Map into a WeatherModel using our factory constructor
      return WeatherModel.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('City not found. Please check the city name.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API key. Check your key in weather_service.dart.');
    } else {
      throw Exception('Failed to load weather. Status: ${response.statusCode}');
    }
  }

  // Helper: returns the full URL for an OpenWeatherMap weather icon image.
  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}
