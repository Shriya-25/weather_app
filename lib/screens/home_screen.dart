import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/hourly_list.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_icon_view.dart';
import '../widgets/weather_illustration.dart';
import '../widgets/weekly_list.dart';

enum WeatherUiState { loading, loaded, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  WeatherData? _weather;
  WeatherUiState _state = WeatherUiState.loading;
  String? _error;

  late final AnimationController _fadeController;
  late final AnimationController _cardsController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _cardsSlideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _cardsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(
          CurvedAnimation(parent: _cardsController, curve: Curves.easeOutCubic),
        );

    _loadInitialWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialWeather() async {
    setState(() {
      _state = WeatherUiState.loading;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final weather = await _apiService.fetchByCoordinates(
        position.latitude,
        position.longitude,
      );
      _showWeather(weather, setSearchText: true);
    } catch (_) {
      await _searchCity(AppConfig.fallbackCity, setSearchText: true);
    }
  }

  Future<void> _searchCity(String city, {bool setSearchText = false}) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _state = WeatherUiState.loading;
      _error = null;
    });

    _fadeController.reset();
    _cardsController.reset();

    try {
      final weather = await _apiService.fetchByCity(trimmed);
      _showWeather(weather, setSearchText: setSearchText);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = WeatherUiState.error;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showWeather(WeatherData weather, {bool setSearchText = false}) {
    if (!mounted) return;

    final cityPart = weather.cityName.split(',').first;

    setState(() {
      _weather = weather;
      _state = WeatherUiState.loaded;
      _error = null;
      if (setSearchText) {
        _searchController.text = cityPart;
      }
    });

    _fadeController.forward();
    _cardsController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weather;
    final bgColors =
        weather?.gradientColors ??
        const [Color(0xFF4A607A), Color(0xFF6D8AA9), Color(0xFF445D7A)];
    final textColor = weather?.textColor ?? Colors.white;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 750),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
        child: Stack(
          children: [
            WeatherIllustration(
              isDay: weather?.isDay ?? true,
              isSunny: (weather?.iconCode.startsWith('01') ?? false),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopArea(textColor),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _buildStateBody(textColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopArea(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Atmos',
                style: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadInitialWeather,
                icon: Icon(
                  Icons.my_location_rounded,
                  color: textColor,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(color: textColor),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => _searchCity(value),
            decoration: InputDecoration(
              hintText: 'Search city',
              hintStyle: GoogleFonts.poppins(
                color: textColor.withValues(alpha: 0.62),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: textColor.withValues(alpha: 0.8),
              ),
              suffixIcon: IconButton(
                onPressed: () => _searchCity(_searchController.text),
                icon: Icon(Icons.arrow_circle_right_rounded, color: textColor),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.15),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateBody(Color textColor) {
    switch (_state) {
      case WeatherUiState.loading:
        return const LoadingSkeleton(key: ValueKey('loading'));
      case WeatherUiState.error:
        return _buildError(textColor);
      case WeatherUiState.loaded:
        if (_weather == null) {
          return _buildError(textColor);
        }
        return _buildWeather(textColor, _weather!);
    }
  }

  Widget _buildError(Color textColor) {
    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: textColor, size: 54),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Unable to load weather.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: textColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _loadInitialWeather,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: textColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeather(Color textColor, WeatherData weather) {
    return LayoutBuilder(
      key: const ValueKey('weather'),
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 370;
        final tempSize = isCompact ? 84.0 : 100.0;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _cardsSlideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    weather.cityName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontSize: isCompact ? 24 : 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weather.condition,
                    style: GoogleFonts.poppins(
                      color: textColor.withValues(alpha: 0.78),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  WeatherIconView(iconCode: weather.iconCode, useLottie: false),
                  Transform.translate(
                    offset: const Offset(0, -8),
                    child: Text(
                      '${weather.temperature.toStringAsFixed(0)}°',
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: tempSize,
                        fontWeight: FontWeight.w200,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: WeatherCard(
                            icon: Icons.thermostat_rounded,
                            label: 'Feels Like',
                            value: '${weather.feelsLike.toStringAsFixed(0)}°C',
                            textColor: textColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: WeatherCard(
                            icon: Icons.water_drop_outlined,
                            label: 'Humidity',
                            value: '${weather.humidity}%',
                            textColor: textColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: WeatherCard(
                            icon: Icons.air_rounded,
                            label: 'Wind',
                            value:
                                '${weather.windSpeed.toStringAsFixed(1)} m/s',
                            textColor: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Hourly Forecast', textColor),
                  const SizedBox(height: 12),
                  HourlyList(hourly: weather.hourly, textColor: textColor),
                  const SizedBox(height: 24),
                  _sectionTitle('Weekly Forecast', textColor),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WeeklyList(
                      daily: weather.daily,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          ),
        );
      },
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
            color: textColor.withValues(alpha: 0.92),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
