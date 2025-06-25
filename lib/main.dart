import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemini_chatbot/screens/login_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "Your web api key",
        authDomain: "Your auth domain",
        projectId: "Your project id",
        storageBucket: "Your storage bucket",
        messagingSenderId: "your message sender id",
        appId: "your app id",
        measurementId: "your m easurement id"
    ),
  );

  runApp(const Chat5BotApp());
}

class Chat5BotApp extends StatelessWidget {
  const Chat5BotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chatbot 5',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const ChatScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
