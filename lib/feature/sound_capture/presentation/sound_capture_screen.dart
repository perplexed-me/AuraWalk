import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sound_capture_provider.dart';
import '../../../core/constants/app_constants.dart';

class SoundCaptureScreen extends ConsumerWidget {
  const SoundCaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundState = ref.watch(soundRecordingStateProvider);
    final soundNotifier = ref.read(soundRecordingStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Capture'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording Status
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    soundState.isRecording
                        ? Icons.mic
                        : soundState.isProcessing
                        ? Icons.hourglass_empty
                        : Icons.mic_none,
                    size: 64,
                    color: soundState.isRecording
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    soundState.isRecording
                        ? 'Recording...'
                        : soundState.isProcessing
                        ? 'Processing...'
                        : 'Ready to Record',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Recording Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: soundState.isRecording || soundState.isProcessing
                      ? null
                      : () => soundNotifier.startRecording(),
                  icon: const Icon(Icons.fiber_manual_record),
                  label: const Text('Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: soundState.isRecording
                      ? () => soundNotifier.stopRecordingAndClassify()
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop & Classify'),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.largePadding),

            // Results
            if (soundState.classifiedSound != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Sound:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        soundState.classifiedSound!.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (soundState.confidenceScores != null) ...[
                        const SizedBox(height: AppConstants.defaultPadding),
                        Text(
                          'Confidence Scores:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        ...soundState.confidenceScores!.entries
                            .take(3)
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppConstants.smallPadding / 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Text(
                                      '${(entry.value * 100).toStringAsFixed(1)}%',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: () => soundNotifier.clearResults(),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Results'),
              ),
            ],

            // Error Display
            if (soundState.error != null)
              Container(
                margin: const EdgeInsets.only(top: AppConstants.defaultPadding),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Text(
                        soundState.error!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
