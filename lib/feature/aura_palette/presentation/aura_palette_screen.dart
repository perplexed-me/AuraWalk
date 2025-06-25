import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'aura_palette_provider.dart';
import '../domain/aura_palette_generator.dart';
import '../../../core/constants/app_constants.dart';

class AuraPaletteScreen extends ConsumerStatefulWidget {
  const AuraPaletteScreen({super.key});

  @override
  ConsumerState<AuraPaletteScreen> createState() => _AuraPaletteScreenState();
}

class _AuraPaletteScreenState extends ConsumerState<AuraPaletteScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _moods = [
    'calm',
    'energetic',
    'peaceful',
    'mysterious',
    'vibrant',
    'serene',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura Palette'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Generate'),
            Tab(icon: Icon(Icons.save_alt), text: 'Saved'),
            Tab(icon: Icon(Icons.view_carousel), text: 'Current'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGenerateTab(), _buildSavedTab(), _buildCurrentTab()],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate Aura Palette',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Generate from Mood
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Mood',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Wrap(
                    spacing: AppConstants.smallPadding,
                    children: _moods
                        .map(
                          (mood) => ActionChip(
                            label: Text(mood.toUpperCase()),
                            onPressed: () => _generateFromMood(mood),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Generate from Sound
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Sound',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Use the Sound Capture feature to generate palettes from environmental sounds.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  ElevatedButton.icon(
                    onPressed: () => _showSoundOptions(),
                    icon: const Icon(Icons.mic),
                    label: const Text('Demo Sound Palette'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Generate from Weather
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Weather',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Generate palettes based on current weather conditions.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  ElevatedButton.icon(
                    onPressed: () => _showWeatherOptions(),
                    icon: const Icon(Icons.wb_sunny),
                    label: const Text('Demo Weather Palette'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTab() {
    final savedPalettesAsync = ref.watch(savedPalettesProvider);

    return savedPalettesAsync.when(
      data: (palettes) => palettes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.palette_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: AppConstants.defaultPadding),
                  Text('No saved palettes yet'),
                  Text('Generate some palettes to save them here'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: palettes.length,
              itemBuilder: (context, index) {
                final palette = palettes[index];
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: AppConstants.smallPadding,
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: _buildColorPreview(palette.colors),
                    ),
                    title: Text(palette.name),
                    subtitle: Text(palette.description),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'view',
                          child: const Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('View'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'view') {
                          ref.read(currentPaletteProvider.notifier).state =
                              palette;
                          _tabController.animateTo(2);
                        } else if (value == 'delete') {
                          _deletePalette(palette);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Failed to load saved palettes: $error')),
    );
  }

  Widget _buildCurrentTab() {
    final currentPalette = ref.watch(currentPaletteProvider);

    if (currentPalette == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette, size: 64, color: Colors.grey),
            SizedBox(height: AppConstants.defaultPadding),
            Text('No palette selected'),
            Text('Generate or select a palette to view it here'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPalette.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    currentPalette.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Mood: ${currentPalette.mood}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Color palette display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Colors',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: currentPalette.colors
                          .map(
                            (color) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Color values
                  ...currentPalette.colors.asMap().entries.map((entry) {
                    final index = entry.key;
                    final color = entry.value;
                    final hex =
                        '#${color.value.toRadixString(16).substring(2).toUpperCase()}'; // ignore: deprecated_member_use

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppConstants.smallPadding),
                          Text('Color ${index + 1}: $hex'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _savePalette(currentPalette),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Palette'),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sharePalette(currentPalette),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPreview(List<Color> colors) {
    return Row(
      children: colors
          .take(5)
          .map((color) => Expanded(child: Container(height: 50, color: color)))
          .toList(),
    );
  }

  void _generateFromMood(String mood) async {
    final paletteAsync = ref.read(moodPaletteProvider(mood));
    paletteAsync.whenData((palette) {
      ref.read(currentPaletteProvider.notifier).state = palette;
      _tabController.animateTo(2);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Generated $mood palette!')));
    });
  }

  void _showSoundOptions() {
    final sounds = AppConstants.soundCategories;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Sound Type'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sounds.length,
            itemBuilder: (context, index) {
              final sound = sounds[index];
              return ListTile(
                title: Text(sound.toUpperCase()),
                onTap: () {
                  Navigator.of(context).pop();
                  _generateFromSound(sound);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _generateFromSound(String soundType) async {
    final request = SoundPaletteRequest(soundType, null);
    final paletteAsync = ref.read(soundPaletteProvider(request));
    paletteAsync.whenData((palette) {
      ref.read(currentPaletteProvider.notifier).state = palette;
      _tabController.animateTo(2);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated palette from $soundType sounds!')),
      );
    });
  }

  void _showWeatherOptions() {
    final weathers = ['clear', 'clouds', 'rain', 'snow', 'thunderstorm'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Weather'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: weathers.length,
            itemBuilder: (context, index) {
              final weather = weathers[index];
              return ListTile(
                title: Text(weather.toUpperCase()),
                onTap: () {
                  Navigator.of(context).pop();
                  _generateFromWeather(weather, 20.0);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _generateFromWeather(String weather, double temperature) async {
    final request = WeatherPaletteRequest(weather, temperature);
    final paletteAsync = ref.read(weatherPaletteProvider(request));
    paletteAsync.whenData((palette) {
      ref.read(currentPaletteProvider.notifier).state = palette;
      _tabController.animateTo(2);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated palette from $weather weather!')),
      );
    });
  }

  void _savePalette(AuraPalette palette) async {
    final generator = ref.read(auraPaletteGeneratorProvider);
    await generator.savePalette(palette);
    ref.invalidate(savedPalettesProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Palette saved!')));
  }

  void _deletePalette(AuraPalette palette) async {
    final generator = ref.read(auraPaletteGeneratorProvider);
    await generator.deletePalette(palette.name);
    ref.invalidate(savedPalettesProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Palette deleted!')));
  }

  void _sharePalette(AuraPalette palette) {
    final colors = palette.colors
        .map((c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}') // ignore: deprecated_member_use
        .join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Palette colors: $colors'),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
