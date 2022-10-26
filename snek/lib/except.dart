class UserException implements Exception {
  late final String message;
  UserException(var message) {
    this.message = message.toString();
  }

  @override
  String toString() {
    return message;
  }
}
