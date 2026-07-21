/// Model yang merepresentasikan response Laravel Sanctum saat login.
///
/// Laravel API Response (`POST /api/v1/auth/token`):
/// ```json
/// {
///   "message": "Autentikasi API Berhasil.",
///   "access_token": "1|xxxxxxxx",
///   "token_type": "Bearer"
/// }
/// ```
class AuthResponseModel {
  String? message;
  String? accessToken;
  String? tokenType;

  AuthResponseModel({
    this.message,
    this.accessToken,
    this.tokenType,
  });

  AuthResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message']?.toString();
    accessToken = json['access_token']?.toString();
    tokenType = json['token_type']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['access_token'] = accessToken;
    data['token_type'] = tokenType;
    return data;
  }

  bool get isValid => accessToken != null && accessToken!.isNotEmpty;
}
