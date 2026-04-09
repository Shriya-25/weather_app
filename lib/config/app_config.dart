class AppConfig {
  const AppConfig._();

  // Provide this via:
  // flutter run --dart-define=OPENWEATHER_API_KEY=your_key_here
  static const openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );

  static void validate() {
    if (openWeatherApiKey.isEmpty) {
      throw Exception(
        'Missing OpenWeather API key. Run with --dart-define=OPENWEATHER_API_KEY=YOUR_KEY',
      );
    }
  }
}
