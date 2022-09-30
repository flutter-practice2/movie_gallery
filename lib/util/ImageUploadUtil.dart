import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class ImageUploadUtil {
  static Future<bool> uploadImage(String imagePath, String putUrl) async {
    var uri = Uri.parse(putUrl);
    var request = http.Request('PUT', uri);
    request.bodyBytes = await XFile(imagePath).readAsBytes();

    var response = await request.send();
    if (response.statusCode == 200) {
      print('uploadImage success');
      return true;
    } else {
      print('uploadImage fail, ${response}');
      return false;
    }
  }
}
