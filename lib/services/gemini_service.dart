import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'Replace this with your api key here'; //
  static const String _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';

  Future<String> getGeminiResponse(String userPrompt) async {
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": userPrompt}
          ]
        }
      ]
    });

    final response = await http.post(
      Uri.parse(_url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      return text;
    } else {
      print("Error: ${response.statusCode}");
      print("Body: ${response.body}");
      return "Error from Gemini API";
    }
  }
}
