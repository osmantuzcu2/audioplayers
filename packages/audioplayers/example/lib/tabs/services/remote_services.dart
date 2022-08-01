import 'package:http/http.dart' as http;

class RemoteServices {
  static var client = http.Client();

  static Future<String?> getSongs() async {
    var url = Uri.parse('https://novemyazilim.com/music-app.php');
    /*  var map = <String, dynamic>{};
    map['gunluk_isler_id'] = gunluk_isler_id;
    map['konum'] = konum; */
    var response = await client.get(
      url,
      //body: map,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }
}
