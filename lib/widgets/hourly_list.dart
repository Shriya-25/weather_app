import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';

// Horizontal scrollable list of hourly forecasts
class HourlyList extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final Color textColor;

  const HourlyList({super.key, required this.hourly, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: hourly.length,
        itemBuilder: (context, i) {
          final h = hourly[i];
          final isNow = i == 0; // first item is "Now"

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    // Current hour gets slightly more opaque background
                    color: Colors.white.withValues(alpha: isNow ? 0.28 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isNow ? 0.5 : 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        isNow ? 'Now' : h.time,
                        style: GoogleFonts.poppins(
                          color: textColor.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: isNow ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      Text(
                        WeatherModel.emojiFromCode(h.weatherCode),
                        style: const TextStyle(fontSize: 22),
                      ),
                      Text(
                        '${h.temp.toStringAsFixed(0)}°',
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
