import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../feature/sound_capture/presentation/sound_capture_screen.dart';
import '../feature/weather/presentation/weather_screen.dart';
import '../feature/aura_palette/presentation/aura_palette_screen.dart';
import '../feature/ar_overlay/presentation/ar_overlay_screen.dart';
import '../core/constants/app_constants.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTabScreen(),
    SoundCaptureScreen(),
    WeatherScreen(),
    AuraPaletteScreen(),
    AROverlayScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.mic_outlined),
      selectedIcon: Icon(Icons.mic),
      label: 'Sound',
    ),
    NavigationDestination(
      icon: Icon(Icons.wb_sunny_outlined),
      selectedIcon: Icon(Icons.wb_sunny),
      label: 'Weather',
    ),
    NavigationDestination(
      icon: Icon(Icons.palette_outlined),
      selectedIcon: Icon(Icons.palette),
      label: 'Aura',
    ),
    NavigationDestination(
      icon: Icon(Icons.view_in_ar_outlined),
      selectedIcon: Icon(Icons.view_in_ar),
      label: 'AR',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}

class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.largePadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Welcome to ${AppConstants.appName}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    const Text(
                      'Discover the aura of your environment through sound, weather, and AR visualization.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            Text('Features', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppConstants.defaultPadding),

            // Feature Cards
            _buildFeatureCard(
              context,
              icon: Icons.mic,
              title: 'Sound Capture',
              description:
                  'Record and classify environmental sounds to generate aura palettes.',
              color: Colors.red,
              onTap: () => _navigateToTab(context, 1),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            _buildFeatureCard(
              context,
              icon: Icons.wb_sunny,
              title: 'Weather Analysis',
              description:
                  'Get weather information and generate aura palettes based on conditions.',
              color: Colors.orange,
              onTap: () => _navigateToTab(context, 2),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            _buildFeatureCard(
              context,
              icon: Icons.palette,
              title: 'Aura Palette',
              description:
                  'Generate, view, and save beautiful color palettes based on your environment.',
              color: Colors.purple,
              onTap: () => _navigateToTab(context, 3),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            _buildFeatureCard(
              context,
              icon: Icons.view_in_ar,
              title: 'AR Overlay',
              description:
                  'Visualize aura colors in augmented reality in your physical space.',
              color: Colors.blue,
              onTap: () => _navigateToTab(context, 4),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Quick Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToTab(context, 1),
                            icon: const Icon(Icons.mic),
                            label: const Text('Record Sound'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToTab(context, 4),
                            icon: const Icon(Icons.view_in_ar),
                            label: const Text('Start AR'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(
                          'About AuraWalk',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    const Text(
                      'AuraWalk combines environmental sound analysis, weather data, and augmented reality to create unique visual experiences. Discover the hidden colors of your surroundings and visualize them in AR.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // This would need to be implemented with a navigation callback
    // For now, we'll show a snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Navigate to tab $index')));
  }
}
