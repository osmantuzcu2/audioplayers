import 'package:http/http.dart' as http;

class RemoteServices {
  static var client = http.Client();

  static Future<String?> getSongs(String urlString) async {
    var url = Uri.parse(urlString);

    var response = await client.get(
      url,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }
}
