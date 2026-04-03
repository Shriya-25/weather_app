import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

// HomeScreen is a StatefulWidget because its content changes:
// - First it shows a loading spinner
// - Then it shows weather data (or an error)
// StatefulWidget = a widget that can rebuild itself when data changes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── State Variables ────────────────────────────────────────────────────────
  final WeatherService _weatherService = WeatherService();

  // TextEditingController listens to what the user types in the search box
  final TextEditingController _cityController = TextEditingController();

  WeatherModel? _weather;   // null until data is fetched
  bool _isLoading = false;  // true while waiting for the API response
  String? _errorMessage;    // null unless something went wrong

  // ── Fetch Weather ──────────────────────────────────────────────────────────
  // This method is called when the user taps the Search button.
  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return; // do nothing if the field is empty

    // Tell Flutter to rebuild with _isLoading = true (shows spinner)
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weather = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(city);
      // Data came back — show it
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      // Something went wrong — show friendly error
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Dispose ────────────────────────────────────────────────────────────────
  // Always dispose controllers to free memory when the widget is removed.
  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Background gradient ──
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a237e), Color(0xFF42a5f5)], // dark blue → light blue
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── App Title ──
                const Text(
                  'Weather App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // ── Search Bar ──
                // A row that contains a text field and a search button side by side
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter city name...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.location_city, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        // Allow pressing Enter on keyboard to search
                        onSubmitted: (_) => _fetchWeather(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Search button
                    ElevatedButton(
                      onPressed: _fetchWeather,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1a237e),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Main Content Area ──
                // Shows: loading spinner / error message / weather card
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Body Builder ───────────────────────────────────────────────────────────
  // Returns different widgets depending on current state.
  Widget _buildBody() {
    if (_isLoading) {
      // Show a circular spinner while waiting for API response
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      // Show a friendly error card
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white70, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_weather != null) {
      // Show the weather data card
      return _buildWeatherCard(_weather!);
    }

    // Default: prompt the user to search
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, color: Colors.white54, size: 80),
          SizedBox(height: 16),
          Text(
            'Search for a city\nto see the weather',
            style: TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Weather Card ───────────────────────────────────────────────────────────
  Widget _buildWeatherCard(WeatherModel weather) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // City name
          Text(
            weather.cityName,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          // Weather icon from OpenWeatherMap
          Image.network(
            _weatherService.getIconUrl(weather.icon),
            width: 100,
            height: 100,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.wb_cloudy, size: 100, color: Colors.white),
          ),

          // Temperature (rounded to 1 decimal place)
          Text(
            '${weather.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),

          // Weather condition (e.g. "clear sky")
          Text(
            weather.condition.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 40),

          // ── Extra Details Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoTile(
                icon: Icons.thermostat,
                label: 'Feels Like',
                value: '${weather.feelsLike.toStringAsFixed(1)}°C',
              ),
              _infoTile(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${weather.humidity}%',
              ),
              _infoTile(
                icon: Icons.air,
                label: 'Wind',
                value: '${weather.windSpeed} m/s',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info Tile Helper ───────────────────────────────────────────────────────
  // A small card showing an icon, a label, and a value.
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
