import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_chatbot/services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(user.uid)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    final loadedMessages = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'sender': (data['sender'] ?? '').toString(),
        'text': (data['text'] ?? '').toString(),
      };
    }).toList();

    setState(() {
      messages = loadedMessages.isEmpty
          ? [
        {
          'sender': 'Chatbot',
          'text': '👋 Hello! I\'m Your Ai chatbot. How can I assist you today?',
        }
      ]
          : loadedMessages;
    });

    _scrollToBottom();
  }

  Future<void> _saveMessageToFirestore(String sender, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(user.uid)
        .collection('messages')
        .add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() async {
    String userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      messages.add({'sender': 'User', 'text': userInput});
      _controller.clear();
      isLoading = true;
    });

    _saveMessageToFirestore('User', userInput);
    _scrollToBottom();

    try {
      String reply = await _geminiService.getGeminiResponse(userInput);

      setState(() {
        messages.add({'sender': 'Gemini', 'text': reply});
      });

      _saveMessageToFirestore('Gemini', reply);
    } catch (e) {
      String errorText = '⚠️ Failed to get response: \${e.toString()}';

      setState(() {
        messages.add({'sender': 'Gemini', 'text': errorText});
      });

      _saveMessageToFirestore('Gemini', errorText);
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message['sender'] == 'User';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurpleAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
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
      appBar: AppBar(
        title: const Text('ChatBot Buddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("ChatBot is typing...", style: TextStyle(color: Colors.grey)),
            ),
          const Divider(height: 1),
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
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
