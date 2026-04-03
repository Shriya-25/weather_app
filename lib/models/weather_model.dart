// WeatherModel holds the data we extract from the API response.
// Think of it as a "box" that stores city name, temperature, and condition.
class WeatherModel {
  final String cityName;    // e.g. "Mumbai"
  final double temperature; // e.g. 31.5 (in Celsius)
  final String condition;   // e.g. "Clear sky"
  final double feelsLike;   // e.g. 34.0
  final int humidity;       // e.g. 70 (percent)
  final double windSpeed;   // e.g. 5.2 (m/s)
  final int weatherCode;    // WMO weather code used to pick icon + description

  // A constructor — like a form you fill in to create an object.
  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });

  // Maps WMO weather codes (used by Open-Meteo) to human-readable descriptions.
  // Full list: https://open-meteo.com/en/docs#weathervariables
  static String descriptionFromCode(int code) {
    const Map<int, String> codes = {
      0: 'Clear Sky',
      1: 'Mainly Clear',
      2: 'Partly Cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Icy Fog',
      51: 'Light Drizzle',
      53: 'Moderate Drizzle',
      55: 'Dense Drizzle',
      61: 'Slight Rain',
      63: 'Moderate Rain',
      65: 'Heavy Rain',
      71: 'Slight Snow',
      73: 'Moderate Snow',
      75: 'Heavy Snow',
      80: 'Slight Showers',
      81: 'Moderate Showers',
      82: 'Violent Showers',
      95: 'Thunderstorm',
      99: 'Thunderstorm with Hail',
    };
    return codes[code] ?? 'Unknown';
  }

  // Maps WMO code to a matching Material icon name (returned as IconData later).
  static String emojiFromCode(int code) {
    if (code == 0 || code == 1) return '☀️';
    if (code == 2 || code == 3) return '⛅';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 55) return '🌦️';
    if (code >= 61 && code <= 65) return '🌧️';
    if (code >= 71 && code <= 75) return '❄️';
    if (code >= 80 && code <= 82) return '🌩️';
    if (code >= 95) return '⛈️';
    return '🌡️';
  }
}
