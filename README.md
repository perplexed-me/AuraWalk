# AuraWalk

A production-ready Flutter starter for the AuraWalk app.

## Features
- Clean architecture (feature → data → domain → presentation) using Riverpod
- Audio capture & sound classification (flutter_sound + TensorFlow Lite)
- OpenWeather API integration with caching
- Minimal AR overlay (ar_flutter_plugin) with colored polylines
- Local persistence (Hive) & cloud sync (Supabase)
- Unit tests for each layer

## Setup
1. Clone this repo
2. Run `flutter pub get`
3. Copy `.env.example` to `.env` and fill in your keys
4. Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
5. Run the app: `flutter run`

## Environment Variables
See `.env.example` for required keys.

## First Run Checklist
- [ ] Add your OpenWeather and Supabase keys to `.env`
- [ ] Run code generation
- [ ] Run all tests: `flutter test`
- [ ] Try the app on a real device for AR & audio

## TODO
- Polish UI
- Add onboarding
- Improve AR visuals
