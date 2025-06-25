import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ar_overlay_repository_impl.dart';
import '../domain/ar_overlay_repository.dart';

// Provider for AR overlay repository
final arOverlayRepositoryProvider = Provider<AROverlayRepository>((ref) {
  return AROverlayRepositoryImpl();
});

// Provider for AR availability
final arAvailabilityProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(arOverlayRepositoryProvider);
  return repository.isARAvailable();
});

// Provider for AR session state
final arSessionStateProvider =
    StateNotifierProvider<ARSessionNotifier, ARSessionState>((ref) {
      final repository = ref.watch(arOverlayRepositoryProvider);
      return ARSessionNotifier(repository);
    });

// Provider for saved AR sessions
final savedARSessionsProvider = FutureProvider<List<ARSession>>((ref) async {
  final repository = ref.watch(arOverlayRepositoryProvider);
  return repository.getSavedSessions();
});

// AR session state
class ARSessionState {
  final bool isInitialized;
  final bool isSessionActive;
  final String? currentSessionId;
  final List<ARObject> currentObjects;
  final bool isLoading;
  final String? error;

  const ARSessionState({
    this.isInitialized = false,
    this.isSessionActive = false,
    this.currentSessionId,
    this.currentObjects = const [],
    this.isLoading = false,
    this.error,
  });

  ARSessionState copyWith({
    bool? isInitialized,
    bool? isSessionActive,
    String? currentSessionId,
    List<ARObject>? currentObjects,
    bool? isLoading,
    String? error,
  }) {
    return ARSessionState(
      isInitialized: isInitialized ?? this.isInitialized,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      currentObjects: currentObjects ?? this.currentObjects,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// AR session notifier
class ARSessionNotifier extends StateNotifier<ARSessionState> {
  final AROverlayRepository _repository;

  ARSessionNotifier(this._repository) : super(const ARSessionState());

  Future<void> initializeAR() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await _repository.initializeAR();
      if (success) {
        state = state.copyWith(isInitialized: true, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to initialize AR',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error initializing AR: $e',
      );
    }
  }

  Future<void> startSession() async {
    if (!state.isInitialized) {
      await initializeAR();
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final sessionId = await _repository.startARSession();
      state = state.copyWith(
        isSessionActive: true,
        currentSessionId: sessionId,
        currentObjects: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start AR session: $e',
      );
    }
  }

  Future<void> endSession() async {
    if (!state.isSessionActive || state.currentSessionId == null) return;

    try {
      await _repository.endARSession(state.currentSessionId!);
      state = state.copyWith(
        isSessionActive: false,
        currentSessionId: null,
        currentObjects: [],
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to end AR session: $e');
    }
  }

  Future<void> placeObject(ARObject object) async {
    if (!state.isSessionActive || state.currentSessionId == null) return;

    try {
      await _repository.placeObject(state.currentSessionId!, object);
      final updatedObjects = [...state.currentObjects, object];
      state = state.copyWith(currentObjects: updatedObjects);
    } catch (e) {
      state = state.copyWith(error: 'Failed to place object: $e');
    }
  }

  Future<void> removeObject(String objectId) async {
    if (!state.isSessionActive || state.currentSessionId == null) return;

    try {
      await _repository.removeObject(state.currentSessionId!, objectId);
      final updatedObjects = state.currentObjects
          .where((obj) => obj.id != objectId)
          .toList();
      state = state.copyWith(currentObjects: updatedObjects);
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove object: $e');
    }
  }

  Future<void> placeAuraObjects(List<ARObject> objects) async {
    if (!state.isSessionActive || state.currentSessionId == null) return;

    try {
      for (final object in objects) {
        await _repository.placeObject(state.currentSessionId!, object);
      }

      final updatedObjects = [...state.currentObjects, ...objects];
      state = state.copyWith(currentObjects: updatedObjects);
    } catch (e) {
      state = state.copyWith(error: 'Failed to place aura objects: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _repository.disposeAR();
    super.dispose();
  }

  Future<void> disposeAR() async {
    if (state.isSessionActive) {
      await endSession();
    }
    await _repository.disposeAR();
    state = const ARSessionState();
  }
}
