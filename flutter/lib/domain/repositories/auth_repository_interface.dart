abstract class IAuthRepository {
  void setSecretKey(String secretKey);

  Future<String?> getSecretKey();
}