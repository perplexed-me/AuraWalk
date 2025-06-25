import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ar_overlay_provider.dart';
import '../domain/ar_overlay_repository.dart';
import '../data/ar_overlay_repository_impl.dart';
import '../../aura_palette/presentation/aura_palette_provider.dart';
import '../../../core/constants/app_constants.dart';

class AROverlayScreen extends ConsumerStatefulWidget {
  const AROverlayScreen({super.key});

  @override
  ConsumerState<AROverlayScreen> createState() => _AROverlayScreenState();
}

class _AROverlayScreenState extends ConsumerState<AROverlayScreen> {
  @override
  Widget build(BuildContext context) {
    final arAvailabilityAsync = ref.watch(arAvailabilityProvider);
    final arSessionState = ref.watch(arSessionStateProvider);
    final arSessionNotifier = ref.read(arSessionStateProvider.notifier);
    final currentPalette = ref.watch(currentPaletteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Overlay'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (arSessionState.isSessionActive)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => arSessionNotifier.endSession(),
              tooltip: 'End AR Session',
            ),
        ],
      ),
      body: arAvailabilityAsync.when(
        data: (isAvailable) {
          if (!isAvailable) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: AppConstants.defaultPadding),
                  Text('AR is not available on this device'),
                  Text('Please try on a device with AR support'),
                ],
              ),
            );
          }

          return _buildARInterface(
            arSessionState,
            arSessionNotifier,
            currentPalette,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: AppConstants.defaultPadding),
              Text('Error checking AR availability: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildARInterface(
    ARSessionState arState,
    ARSessionNotifier notifier,
    dynamic currentPalette,
  ) {
    if (arState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              arState.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: () => notifier.clearError(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (!arState.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.view_in_ar, size: 64),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'AR Experience',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'Visualize aura colors in augmented reality',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            arState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: () => notifier.initializeAR(),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Initialize AR'),
                  ),
          ],
        ),
      );
    }

    if (!arState.isSessionActive) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    const Icon(Icons.view_in_ar, size: 64),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Ready for AR Session',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    const Text(
                      'Start an AR session to place aura objects in your environment',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    arState.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: () => notifier.startSession(),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start AR Session'),
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Saved sessions
            _buildSavedSessions(),
          ],
        ),
      );
    }

    // Active AR session UI - Simplified mock interface
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.view_in_ar, size: 100, color: Colors.white),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              'AR Camera View\n(Simulated)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              '${arState.currentObjects.length} objects placed',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: AppConstants.largePadding),

            // Controls
            Wrap(
              spacing: AppConstants.smallPadding,
              children: [
                if (currentPalette != null)
                  ElevatedButton.icon(
                    onPressed: () =>
                        _placeAuraObjects(notifier, currentPalette),
                    icon: const Icon(Icons.palette),
                    label: const Text('Place Aura'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                ElevatedButton.icon(
                  onPressed: () => _showObjectPlacer(notifier),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Object'),
                ),

                ElevatedButton.icon(
                  onPressed: () => _clearObjects(notifier),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedSessions() {
    final savedSessionsAsync = ref.watch(savedARSessionsProvider);

    return savedSessionsAsync.when(
      data: (sessions) => sessions.isEmpty
          ? const SizedBox.shrink()
          : Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent AR Sessions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    ...sessions
                        .take(3)
                        .map(
                          (session) => ListTile(
                            leading: const Icon(Icons.view_in_ar),
                            title: Text(
                              'Session ${session.id.substring(0, 8)}',
                            ),
                            subtitle: Text('${session.objects.length} objects'),
                            trailing: Text(
                              session.endTime != null
                                  ? '${session.endTime!.day}/${session.endTime!.month}'
                                  : 'Active',
                            ),
                            onTap: () => _showSessionDetails(session),
                          ),
                        ),
                  ],
                ),
              ),
            ),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  void _placeAuraObjects(ARSessionNotifier notifier, dynamic palette) {
    if (palette?.colors == null) return;

    final repositoryImpl =
        ref.read(arOverlayRepositoryProvider) as AROverlayRepositoryImpl;
    final auraObjects = repositoryImpl.generateAuraObjectsFromPalette(
      palette.colors,
    );

    notifier.placeAuraObjects(auraObjects);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Placed ${auraObjects.length} aura objects'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showObjectPlacer(ARSessionNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place AR Object'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select object type to place:'),
            const SizedBox(height: AppConstants.defaultPadding),
            Wrap(
              spacing: AppConstants.smallPadding,
              children: ['sphere', 'cube', 'pyramid', 'cylinder']
                  .map(
                    (type) => ActionChip(
                      label: Text(type.toUpperCase()),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _placeRandomObject(notifier, type);
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _placeRandomObject(ARSessionNotifier notifier, String type) {
    final repositoryImpl =
        ref.read(arOverlayRepositoryProvider) as AROverlayRepositoryImpl;
    final object = repositoryImpl.generateAuraObject(Colors.blue, type);

    notifier.placeObject(object);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Placed $type object')));
  }

  void _clearObjects(ARSessionNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Objects'),
        content: const Text('Remove all placed objects from the AR scene?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear all objects by ending and starting a new session
              notifier.endSession().then((_) => notifier.startSession());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(ARSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AR Session ${session.id.substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Objects: ${session.objects.length}'),
            Text('Location: ${session.location}'),
            Text(
              'Duration: ${session.endTime?.difference(session.startTime).inMinutes ?? 0} minutes',
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (session.objects.isNotEmpty) ...[
              const Text(
                'Objects:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...session.objects
                  .take(3)
                  .map(
                    (obj) => Text(
                      '• ${obj.type} (${obj.color.value.toRadixString(16).substring(2)})', // ignore: deprecated_member_use
                    ),
                  ),
              if (session.objects.length > 3)
                Text('... and ${session.objects.length - 3} more'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
