import 'dart:typed_data';
import 'package:http/http.dart';
import 'dart:convert'; // For JSON decoding

class Controller {
  static Future<Uint8List?> uploadImage(Uint8List imageBytes) async {
    final uri = Uri.parse('http://localhost:8000/predict');

    var request = MultipartRequest('POST', uri)
      ..files.add(
        MultipartFile.fromBytes(
          'file', // field name expected by the API
          imageBytes,
          filename: 'mammogram.png',
        ),
      );

    try {
      var response = await request.send();
      var responseBytes = await response.stream.toBytes();

      if (response.statusCode == 200) {
        // Check if the response is JSON (no detections case)
        try {
          var jsonResponse = json.decode(utf8.decode(responseBytes));
          if (jsonResponse is Map && jsonResponse['detections'] == false) {
            // No detections - return null to indicate we should use original image
            return null;
          }
        } catch (e) {
          // If JSON parsing fails, it's probably an image - return the bytes
          return responseBytes;
        }
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