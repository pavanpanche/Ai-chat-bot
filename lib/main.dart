import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(Chat5BotApp());
}

class Chat5BotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat5Bot with Gemini',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
