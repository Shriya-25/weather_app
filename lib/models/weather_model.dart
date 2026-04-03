// WeatherModel holds the data we extract from the API response.
// Think of it as a "box" that stores city name, temperature, and condition.
class WeatherModel {
  final String cityName;      // e.g. "Mumbai"
  final double temperature;   // e.g. 31.5 (in Celsius)
  final String condition;     // e.g. "Clear sky"
  final String icon;          // e.g. "01d" — used to build the icon URL
  final double feelsLike;     // e.g. 34.0
  final int humidity;         // e.g. 70 (percent)
  final double windSpeed;     // e.g. 5.2 (m/s)

  // A constructor — like a form you fill in to create an object.
  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
  });

  // A factory constructor that takes raw JSON data (a Map) and
  // converts it into a WeatherModel object.
  // The JSON looks like: { "name": "Mumbai", "main": { "temp": 304.5 }, ... }
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],                                      // city name
      temperature: (json['main']['temp'] as num).toDouble() - 273.15, // Kelvin → Celsius
      condition: json['weather'][0]['description'],                // weather text
      icon: json['weather'][0]['icon'],                            // icon code
      feelsLike: (json['main']['feels_like'] as num).toDouble() - 273.15,
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}
