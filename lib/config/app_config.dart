class AppConfig {
  const AppConfig._();

  static const openWeatherApiKeyEnv = 'OPENWEATHER_API_KEY';
  static const fallbackCity = 'London';

  // Provide this via:
  // flutter run --dart-define=OPENWEATHER_API_KEY=your_key_here
  static const openWeatherApiKey = String.fromEnvironment(
    openWeatherApiKeyEnv,
    defaultValue: '',
  );

  static void validate() {
    if (openWeatherApiKey.isEmpty) {
      throw Exception(
        'Missing OpenWeather API key. Run with --dart-define=$openWeatherApiKeyEnv=YOUR_KEY',
      );
    }
  }
}
