import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/weather_model.dart';

class WeatherIconView extends StatelessWidget {
  final String iconCode;
  final bool useLottie;

  const WeatherIconView({
    super.key,
    required this.iconCode,
    this.useLottie = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!useLottie) {
      return Text(
        WeatherData.emojiFromIcon(iconCode),
        style: const TextStyle(fontSize: 96),
      );
    }

    return SizedBox(
      width: 130,
      height: 130,
      child: Lottie.network(
        _lottieUrl(iconCode),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              WeatherData.emojiFromIcon(iconCode),
              style: const TextStyle(fontSize: 90),
            ),
          );
        },
      ),
    );
  }

  String _lottieUrl(String code) {
    if (code.startsWith('01')) {
      return 'https://lottie.host/d57dd490-f169-44e8-b488-a8e589f7df4c/U0rdT3K4Q6.json';
    }
    if (code.startsWith('02') || code.startsWith('03') || code.startsWith('04')) {
      return 'https://lottie.host/8aa1dceb-08f0-4297-a3f8-57cc50f9c132/Jx7M69x4xN.json';
    }
    if (code.startsWith('09') || code.startsWith('10')) {
      return 'https://lottie.host/da595f42-497b-4460-81d4-a2e476988588/9Q7tn7MVeS.json';
    }
    return 'https://lottie.host/8aa1dceb-08f0-4297-a3f8-57cc50f9c132/Jx7M69x4xN.json';
  }
}
