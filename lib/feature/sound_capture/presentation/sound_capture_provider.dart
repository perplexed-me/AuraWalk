import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sound_classifier_repository_impl.dart';
import '../domain/sound_classifier_repository.dart';

// Provider for sound classifier repository
final soundClassifierRepositoryProvider = Provider<SoundClassifierRepository>((
  ref,
) {
  return SoundClassifierRepositoryImpl();
});

// Provider for sound recording state
final soundRecordingStateProvider =
    StateNotifierProvider<SoundRecordingNotifier, SoundRecordingState>((ref) {
      final repository = ref.watch(soundClassifierRepositoryProvider);
      return SoundRecordingNotifier(repository);
    });

// Sound recording state
class SoundRecordingState {
  final bool isRecording;
  final bool isProcessing;
  final String? classifiedSound;
  final Map<String, double>? confidenceScores;
  final String? error;

  const SoundRecordingState({
    this.isRecording = false,
    this.isProcessing = false,
    this.classifiedSound,
    this.confidenceScores,
    this.error,
  });

  SoundRecordingState copyWith({
    bool? isRecording,
    bool? isProcessing,
    String? classifiedSound,
    Map<String, double>? confidenceScores,
    String? error,
  }) {
    return SoundRecordingState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      classifiedSound: classifiedSound ?? this.classifiedSound,
      confidenceScores: confidenceScores ?? this.confidenceScores,
      error: error ?? this.error,
    );
  }
}

// Sound recording notifier
class SoundRecordingNotifier extends StateNotifier<SoundRecordingState> {
  final SoundClassifierRepository _repository;

  SoundRecordingNotifier(this._repository) : super(const SoundRecordingState());

  Future<void> startRecording() async {
    try {
      state = state.copyWith(
        isRecording: false,
        isProcessing: true,
        error: null,
      );

      final success = await _repository.startRecording();
      if (success) {
        state = state.copyWith(isRecording: true, isProcessing: false);
      } else {
        state = state.copyWith(
          isRecording: false,
          isProcessing: false,
          error:
              'Failed to start recording. Please check microphone permissions.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        isProcessing: false,
        error: 'An error occurred while starting recording: $e',
      );
    }
  }

  Future<void> stopRecordingAndClassify() async {
    if (!state.isRecording) return;

    try {
      state = state.copyWith(
        isRecording: false,
        isProcessing: true,
        error: null,
      );

      final audioFilePath = await _repository.stopRecording();
      if (audioFilePath != null) {
        // Classify the recorded sound
        final classifiedSound = await _repository.classifySound(audioFilePath);
        final confidenceScores = await _repository.getConfidenceScores(
          audioFilePath,
        );

        state = state.copyWith(
          isProcessing: false,
          classifiedSound: classifiedSound,
          confidenceScores: confidenceScores,
        );
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: 'Failed to stop recording.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'An error occurred while processing audio: $e',
      );
    }
  }

  void clearResults() {
    state = state.copyWith(
      classifiedSound: null,
      confidenceScores: null,
      error: null,
    );
  }
}
