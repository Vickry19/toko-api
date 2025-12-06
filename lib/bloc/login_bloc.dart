import '/helpers/api.dart';
import '/helpers/api_url.dart';
import '/model/login.dart';

class LoginBloc {
  static Future<Login> login({String? email, String? password}) async {
    String apiUrl = ApiUrl.login;
    var body = {"email": email, "password": password};

    // Api().post() di modul SUDAH return Map<String, dynamic>
    var response = await Api().post(apiUrl, body);
    return Login.fromJson(response);
  }
}
