import 'package:http/http.dart' as http;

class WebAppServices {
  static const ROOT =
      'http://bluetrace.000webhostapp.com'; //site does not exist
  // This function sends uuid of infected patient to the nodeserver
  static Future<String> sendCovidSignal(String uuid) async {
    try {
      var map = Map<String, dynamic>();
      map['action'] = 'CovidAlert';
      map['uuid'] = uuid;
      print(map);
      final response = await http.post(ROOT, body: map);
      print('Response: ${response.body}');
      print(response.statusCode);
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return "error: ${response.statusCode}";
      }
    } catch (e) {
      print(e);
      return "Failure";
    }
  }
}
