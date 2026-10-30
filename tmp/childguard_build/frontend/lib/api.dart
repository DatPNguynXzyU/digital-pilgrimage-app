import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Api {
  static const base = String.fromEnvironment('API_BASE_URL');
  static const storage = FlutterSecureStorage();
  String? token;
  bool get configured {
    final uri = Uri.tryParse(base);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty &&
      uri.host != 'localhost' && uri.host != '127.0.0.1' && !uri.host.startsWith('192.168.');
  }
  Future<dynamic> call(String method, String path, [Map<String,dynamic>? data]) async {
    if (!configured) throw Exception('Cần cấu hình API_BASE_URL bằng URL HTTPS của Render.');
    final request = http.Request(method, Uri.parse('$base$path'));
    request.headers.addAll({'Content-Type':'application/json',if(token!=null)'Authorization':'Bearer $token'});
    if(data!=null) request.body=jsonEncode(data);
    final response=await http.Response.fromStream(await request.send().timeout(const Duration(seconds:60)));
    final dynamic body=response.body.isEmpty?null:jsonDecode(response.body);
    if(response.statusCode>=400) throw Exception(body?['message']??'Không kết nối được máy chủ');
    return body;
  }
  Future<void> logout() async {token=null;await storage.deleteAll();}
}
