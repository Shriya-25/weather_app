import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../widgets/weather_card.dart';
import '../widgets/hourly_list.dart';
import '../widgets/weekly_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _error;

  // ── Animation controllers ─────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Load a default city on startup
    _fetchWeather('London');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Fetch weather ─────────────────────────────────────────────────────────
  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _fadeController.reset();
    _slideController.reset();

    try {
      final weather = await _api.fetchWeather(city);
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Root build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final gradientColors =
        _weather?.gradientColors ??
        [const Color(0xFF1a237e), const Color(0xFF42a5f5)];
    final textColor = _weather?.textColor ?? Colors.white;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(textColor),
              Expanded(child: _buildBody(textColor)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(color: textColor),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: GoogleFonts.poppins(
                      color: textColor.withValues(alpha: 0.55),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (v) {
                    final city = v.trim();
                    if (city.isNotEmpty) _fetchWeather(city);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _glassIconButton(
            icon: Icons.refresh_rounded,
            textColor: textColor,
            onTap: () {
              final city = _searchController.text.trim();
              if (city.isNotEmpty) _fetchWeather(city);
            },
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton({
    required IconData icon,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: textColor, size: 22),
          ),
        ),
      ),
    );
  }

  // ── Body: loading / error / content ──────────────────────────────────────
  Widget _buildBody(Color textColor) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: textColor, strokeWidth: 2.5),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: textColor.withValues(alpha: 0.6),
                size: 70,
              ),
              const SizedBox(height: 18),
              Text(
                _error!,
                style: GoogleFonts.poppins(color: textColor, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => _fetchWeather('London'),
                icon: Icon(Icons.refresh, color: textColor),
                label: Text(
                  'Try London',
                  style: GoogleFonts.poppins(color: textColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_weather == null) return const SizedBox.shrink();
    return _buildWeatherContent(_weather!, textColor);
  }

  // ── Premium weather content ───────────────────────────────────────────────
  Widget _buildWeatherContent(WeatherModel w, Color textColor) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // City name
              Text(
                w.cityName,
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Condition
              Text(
                w.condition,
                style: GoogleFonts.poppins(
                  color: textColor.withValues(alpha: 0.75),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 18),

              // Weather emoji
              Text(
                WeatherModel.emojiFromCode(w.weatherCode, isDay: w.isDay),
                style: const TextStyle(fontSize: 90),
              ),

              // Huge temperature
              Text(
                '${w.temperature.toStringAsFixed(0)}°',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 100,
                  fontWeight: FontWeight.w200,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 8),

              // Day / Night pill badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  w.isDay ? '☀️  Day' : '🌙  Night',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Glass info cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: WeatherCard(
                        icon: Icons.thermostat_rounded,
                        label: 'Feels Like',
                        value: '${w.feelsLike.toStringAsFixed(0)}°C',
                        textColor: textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WeatherCard(
                        icon: Icons.water_drop_outlined,
                        label: 'Humidity',
                        value: '${w.humidity}%',
                        textColor: textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WeatherCard(
                        icon: Icons.air_rounded,
                        label: 'Wind',
                        value: '${w.windSpeed.toStringAsFixed(1)} m/s',
                        textColor: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Hourly forecast
              _sectionTitle('Hourly Forecast', textColor),
              const SizedBox(height: 12),
              HourlyList(hourly: w.hourlyForecast, textColor: textColor),

              const SizedBox(height: 28),

              // 7-day forecast
              _sectionTitle('7-Day Forecast', textColor),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: WeeklyList(daily: w.dailyForecast, textColor: textColor),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: textColor.withValues(alpha: 0.88),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
