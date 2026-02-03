class UsernameTakenException implements Exception {
  UsernameTakenException(this.displayName);

  final String displayName;

  @override
  String toString() => 'UsernameTakenException($displayName)';
}
