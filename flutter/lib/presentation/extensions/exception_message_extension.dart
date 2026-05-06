class SessionExpiredException implements Exception {
  final String message;
  final int errorCode;
  
  SessionExpiredException({
    this.message = 'Session expired',
    this.errorCode = 401
  });

  @override
  String toString() => message;
}