# Atmos Weather App

Premium Flutter weather app with gradient atmospheres, glassmorphism UI, location-based weather, city search, and smooth motion.

## Highlights

- Auto-detect current location using GPS permission
- Search any city from the top search bar
- Real-time weather from OpenWeather API
- Center hero section with weather icon and large temperature
- Glass cards for feels like, humidity, and wind
- Horizontal hourly forecast and weekly forecast sections
- Animated gradients based on weather and day/night
- Fade and slide transitions for polished interactions
- Shimmer loading skeleton and robust error handling

## Tech Stack

- Flutter (Material 3)
- http
- geolocator
- intl
- google_fonts
- shimmer
- lottie (optional weather icon mode)

## Project Structure

- lib/models: data models and weather presentation helpers
- lib/services: API and location services
- lib/screens: main UI screen
- lib/widgets: reusable premium components

## Setup

1. Create an OpenWeather API key: https://openweathermap.org/api
2. Install dependencies:

```bash
flutter pub get
```

3. Run with API key:

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=YOUR_API_KEY
```

## Notes

- If location permission is denied, the app falls back to London and search remains fully available.
- On city not found or network issues, a user-friendly retry panel is shown.
