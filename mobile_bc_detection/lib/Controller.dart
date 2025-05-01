import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'dart:io' show Platform;
class Controller {

  static Future<Map<String, dynamic>?> uploadImage(Uint8List imageBytes, double pixelSpacing) async {
    final uri = Uri.parse('${dotenv.env['BACKEND_URL']!}/predict');

    var request = MultipartRequest('POST', uri)
      ..files.add(
        MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'mammogram.png',
        ),
      )
      // Add pixel spacing as a form field
      ..fields['pixel_spacing'] = pixelSpacing.toString();

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
            'label': pred['label'],           // New field
            'classification': pred['classification'], // New field
            'score': pred['score'],
            'crop':base64Decode(pred['crop']),
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
  static Future<Map<String, dynamic>?> sendEmail(Map<String, dynamic> formData) async {
    final uri = Uri.parse('${dotenv.env['BACKEND_URL']!}/send-email');

    try {
      final response = await post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Email sending failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 Error during email sending: $e');
      return null;
    }
  }
}