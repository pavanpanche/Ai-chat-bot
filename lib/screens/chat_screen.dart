import 'package:flutter/material.dart';
import 'package:gemini_chatbot/services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    String userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      messages.add({'sender': 'User', 'text': userInput});
      _controller.clear();
      isLoading = true;
    });

    try {
      String reply = await _geminiService.getGeminiResponse(userInput);
      setState(() {
        messages.add({'sender': 'Gemini', 'text': reply});
      });
    } catch (e) {
      setState(() {
        messages.add({'sender': 'Gemini', 'text': '⚠️ Failed to get response'});
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message['sender'] == 'User';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurpleAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(12),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ChatBot 🤖')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("Gemini is typing...", style: TextStyle(color: Colors.grey)),
            ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
