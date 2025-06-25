import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'Your Gemini Api Key';
  static const String _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';
   // Api call
  Future<String> getGeminiResponse(String userPrompt) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userPrompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final candidates = data['candidates'];
        if (candidates != null &&
            candidates.isNotEmpty &&
            candidates[0]['content'] != null &&
            candidates[0]['content']['parts'] != null &&
            candidates[0]['content']['parts'].isNotEmpty) {
          return candidates[0]['content']['parts'][0]['text'];
        } else {
          return "No valid response from Gemini API";
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Body: ${response.body}");
        return "Gemini API error: ${response.statusCode}";
      }
    } catch (e) {
      print("Exception: $e");
      return "Something went wrong!";
    }
  }
}
