import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/weather_model.dart';
import 'glass_panel.dart';

class WeeklyList extends StatelessWidget {
  final List<DailyForecast> daily;
  final Color textColor;

  const WeeklyList({super.key, required this.daily, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: daily.take(7).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final d = entry.value;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 58,
                      child: Text(
                        d.dayLabel,
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        d.dateLabel,
                        style: GoogleFonts.poppins(
                          color: textColor.withValues(alpha: 0.62),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        d.condition,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      WeatherData.emojiFromIcon(d.iconCode),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 34,
                      child: Text(
                        '${d.minTemp.toStringAsFixed(0)}°',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.poppins(
                          color: textColor.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TempRangeBar(textColor: textColor),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 34,
                      child: Text(
                        '${d.maxTemp.toStringAsFixed(0)}°',
                        style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index != daily.length - 1)
                Divider(
                  height: 1,
                  color: textColor.withValues(alpha: 0.12),
                  indent: 18,
                  endIndent: 18,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TempRangeBar extends StatelessWidget {
  final Color textColor;

  const _TempRangeBar({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          colors: [
            textColor.withValues(alpha: 0.25),
            textColor.withValues(alpha: 0.85),
          ],
        ),
      ),
    );
  }
}
