import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_provider.dart';
import '../../../core/constants/app_constants.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  // Default location (can be replaced with GPS location)
  static const LatLng defaultLocation = LatLng(
    37.7749,
    -122.4194,
  ); // San Francisco

  @override
  Widget build(BuildContext context) {
    final currentWeatherAsync = ref.watch(
      currentWeatherProvider(defaultLocation),
    );
    final forecastAsync = ref.watch(
      weatherForecastProvider(
        ForecastRequest(defaultLocation.latitude, defaultLocation.longitude, 5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentWeatherProvider);
              ref.invalidate(weatherForecastProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentWeatherProvider);
          ref.invalidate(weatherForecastProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weather Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: currentWeatherAsync.when(
                    data: (weather) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Weather',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Icon(
                              _getWeatherIcon(weather.condition),
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          weather.description,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeatherDetail(
                              context,
                              Icons.water_drop,
                              'Humidity',
                              '${weather.humidity.toStringAsFixed(0)}%',
                            ),
                            _buildWeatherDetail(
                              context,
                              Icons.air,
                              'Wind',
                              '${weather.windSpeed.toStringAsFixed(1)} m/s',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Location: ${weather.location}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.largePadding),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stackTrace) => Column(
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Failed to load weather data',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Forecast Section
              Text(
                '5-Day Forecast',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppConstants.smallPadding),

              forecastAsync.when(
                data: (forecast) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: forecast.length,
                  itemBuilder: (context, index) {
                    final weather = forecast[index];
                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.smallPadding,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getWeatherIcon(weather.condition),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          _formatDate(weather.timestamp),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(weather.description),
                        trailing: Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.defaultPadding),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Text(
                      'Failed to load forecast data',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: AppConstants.smallPadding / 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    }
  }
}
