class Credentials {
  final String accessToken;
  final String email;
  final String producerId;
  final String password;
  final int expiredTime;

  Credentials(this.accessToken, this.email, this.producerId, this.password, this.expiredTime);
}