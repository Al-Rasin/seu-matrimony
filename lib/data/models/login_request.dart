/// Login request model
class LoginRequest {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'remember_me': rememberMe,
    };
  }

  @override
  String toString() => 'LoginRequest(username: $username, rememberMe: $rememberMe)';
}
