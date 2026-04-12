import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import 'glass_panel.dart';

class HourlyList extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final Color textColor;

  const HourlyList({super.key, required this.hourly, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        itemBuilder: (context, index) {
          final item = hourly[index];
          final label = index == 0 ? 'Now' : DateFormat('ha').format(item.time);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 78,
              child: GlassPanel(
                borderRadius: BorderRadius.circular(22),
                opacity: index == 0 ? 0.2 : 0.12,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: textColor.withValues(alpha: 0.88),
                        fontSize: 11,
                        fontWeight: index == 0
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    Text(
                      WeatherData.emojiFromIcon(item.iconCode),
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      '${item.temp.toStringAsFixed(0)}°',
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
          );
        },
      ),
    );
  }
}
