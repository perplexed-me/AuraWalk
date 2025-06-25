// Abstract repository for sound classification

abstract class SoundClassifierRepository {
  Future<String> classifySound(String audioFilePath);
  Future<bool> startRecording();
  Future<String?> stopRecording();
  Future<List<String>> getAvailableSoundTypes();
  Future<Map<String, double>> getConfidenceScores(String audioFilePath);
}
