import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';

// A glassmorphism card listing the 7-day weather forecast
class WeeklyList extends StatelessWidget {
  final List<DailyForecast> daily;
  final Color textColor;

  const WeeklyList({super.key, required this.daily, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: daily.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              final isLast = i == daily.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Day name (Today / Mon / Tue…)
                        SizedBox(
                          width: 56,
                          child: Text(
                            d.day,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Date (Apr 3)
                        Expanded(
                          child: Text(
                            d.date,
                            style: GoogleFonts.poppins(
                              color: textColor.withValues(alpha: 0.55),
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // Weather emoji
                        Text(
                          WeatherModel.emojiFromCode(d.weatherCode),
                          style: const TextStyle(fontSize: 22),
                        ),

                        const SizedBox(width: 14),

                        // Min temp
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${d.minTemp.toStringAsFixed(0)}°',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(
                              color: textColor.withValues(alpha: 0.55),
                              fontSize: 13,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Temperature range bar
                        _TempBar(
                          min: d.minTemp,
                          max: d.maxTemp,
                          textColor: textColor,
                        ),

                        const SizedBox(width: 8),

                        // Max temp
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${d.maxTemp.toStringAsFixed(0)}°',
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider between rows (not after the last one)
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: textColor.withValues(alpha: 0.1),
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// A small gradient bar showing the min → max temperature range
class _TempBar extends StatelessWidget {
  final double min;
  final double max;
  final Color textColor;

  const _TempBar({
    required this.min,
    required this.max,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: [textColor.withValues(alpha: 0.25), textColor],
        ),
      ),
    );
  }
}
