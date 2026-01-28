import 'stable_hash.dart';

/// Computes a deterministic daily index based on the base key and list length.
int selectDailyIndex({
  required String baseKey,
  required int length,
}) {
  if (length <= 0) {
    throw ArgumentError('List length must be greater than zero.');
  }
  final hash = stableHashFnv1a32(baseKey);
  return (hash % length).abs();
}
