# AuraWalk

An innovative Flutter application that combines environmental sound analysis, weather data, and augmented reality to create unique visual aura experiences.

## Features

### 🎵 Sound Capture

- Record environmental sounds using your device's microphone
- AI-powered sound classification (birds, traffic, nature, etc.)
- Generate aura color palettes based on sound analysis
- Real-time confidence scoring for sound types

### 🌤️ Weather Analysis

- Current weather conditions and 5-day forecast
- Location-based weather data
- Generate aura palettes influenced by weather conditions
- Temperature-based color adjustments

### 🎨 Aura Palette Generator

- Create beautiful color palettes from sound and weather
- Generate palettes from mood selections
- Save and manage your favorite palettes
- Share palette color codes

### 🥽 AR Overlay

- Visualize aura colors in augmented reality
- Place 3D objects with palette colors in real space
- Multiple object types (spheres, cubes, pyramids, cylinders)
- Save and replay AR sessions

## Architecture

The app follows Clean Architecture principles with:

- **Domain Layer**: Business logic and entities
- **Data Layer**: Repository implementations and data sources
- **Presentation Layer**: UI components and state management
- **Core Layer**: Shared utilities, constants, and services

### Tech Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Cloud Storage**: Supabase (optional)
- **Sound Processing**: flutter_sound
- **AR**: ar_flutter_plugin
- **HTTP**: http package
- **Environment**: flutter_dotenv

## Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- iOS 12.0+ / Android API 21+
- Device with ARCore (Android) or ARKit (iOS) support for AR features

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd AuraWalk
```

2. Install dependencies:

```bash
flutter pub get
```

3. Set up environment variables:

```bash
cp .env.example .env
```

Edit `.env` with your configuration (optional for basic functionality).

4. Run the app:

```bash
flutter run
```

### Configuration (Optional)

#### Supabase Setup

1. Create a Supabase project
2. Add your URL and anon key to `.env`:

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

#### OpenWeather API (Future Enhancement)

1. Get an API key from OpenWeatherMap
2. Add to `.env`:

```
OPENWEATHER_API_KEY=your_api_key
```

## Permissions

The app requires the following permissions:

### Android

- `RECORD_AUDIO`: For sound capture functionality
- `CAMERA`: For AR functionality
- `INTERNET`: For weather data and cloud sync

### iOS

- `NSMicrophoneUsageDescription`: Audio recording
- `NSCameraUsageDescription`: AR camera access
- `NSLocationWhenInUseUsageDescription`: Weather location

## Project Structure

```
lib/
├── core/                    # Core utilities and services
│   ├── cloud/              # Cloud storage services
│   ├── constants/          # App constants
│   ├── local/              # Local storage services
│   ├── theme/              # App theming
│   └── utils/              # Utility functions
├── feature/                # Feature modules
│   ├── ar_overlay/         # AR functionality
│   ├── aura_palette/       # Color palette generation
│   ├── sound_capture/      # Sound recording and analysis
│   └── weather/            # Weather data
├── presentation/           # Main navigation
└── main.dart              # App entry point
```

## Features in Detail

### Sound Classification

The app uses mock AI classification to categorize environmental sounds into:

- Birds, Traffic, Nature sounds, Urban noise, Water sounds
- Wind, Silence, Music, Voices, Industrial sounds

### Aura Color Mapping

Each sound type maps to specific aura colors:

- **Calm**: Blue tones
- **Energetic**: Orange/yellow tones
- **Peaceful**: Green tones
- **Mysterious**: Purple tones
- **Vibrant**: Red/pink tones
- **Serene**: Teal tones

### AR Visualization

- Place colored 3D objects in real space
- Objects respond to generated color palettes
- Session recording and playback
- Multiple object types and sizes

## Development

### Testing

Run tests with:

```bash
flutter test
```

### Building

Build for release:

```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Known Limitations

- Sound classification uses mock data (real ML model not implemented)
- Weather data uses mock data (real API integration pending)
- AR functionality is simulated (actual ARCore/ARKit integration pending)

## Future Enhancements

- [ ] Real machine learning model for sound classification
- [ ] OpenWeather API integration
- [ ] Full ARCore/ARKit implementation
- [ ] GPS-based AR polylines
- [ ] Social sharing features
- [ ] User authentication

## License

This project is licensed under the MIT License.
