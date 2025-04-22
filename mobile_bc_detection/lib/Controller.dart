import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart';

class Controller {
  static Future<Map<String, dynamic>?> uploadImage(Uint8List imageBytes) async {
    final uri = Uri.parse('http://localhost:8000/predict');

    var request = MultipartRequest('POST', uri)
      ..files.add(
        MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'mammogram.png',
        ),
      );

    try {
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseString);
        
        // Handle case where no detections were found
        if (jsonResponse is Map && jsonResponse['detections'] == false) {

          return null;
        }

        // Process the full response
        return {
          'detections': true,
          'full_image': base64Decode(jsonResponse['full_image']),
          'individual_predictions': (jsonResponse['individual_predictions'] as List)
              .map((pred) => {
                    'image': base64Decode(pred['image']),
                    'features': pred['features'],
                  })
              .toList()
        };
        
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