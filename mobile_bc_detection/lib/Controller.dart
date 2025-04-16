
import 'dart:typed_data';
import 'package:http/http.dart';

class Controller {
  static Future<Uint8List?> uploadImage(Uint8List imageBytes) async {
    final uri = Uri.parse('http://localhost:8000/predict');

    var request = MultipartRequest('POST', uri)
      ..files.add(
        MultipartFile.fromBytes(
          'file', // field name expected by the API
          imageBytes as List<int>,
          filename: 'mammogram.png',
        ),
      );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // If the server responds with an image, return the bytes
        var responseBytes = await response.stream.toBytes();
        return responseBytes;
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 Error during upload: $e');
      return null;
    }
  }
}