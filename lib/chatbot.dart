import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io'; // To detect platform for localhost
import 'package:flutter/foundation.dart'; // To detect web
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP requests
import 'package:uuid/uuid.dart'; // For Session ID generation

// --- Custom Colors ---
const Color kGreenAccent = Colors.teal;
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kBotBubbleColor = Color(0xFFE0E0E0);
const Color kUserBubbleColor = Colors.teal;

// --- Configuration (Mirrors chat-widget.js Config) ---
// If testing on Android Emulator, use 'http://10.0.2.2:5454/webhook'
// If testing on iOS Simulator or Web, use 'http://localhost:5454/webhook'
const String kBaseUrl = 'http://localhost:5678/webhook/282b07f6-e889-432e-8b1b-f31979563281/chat';
const String kRoute = 'general';

void main() {
  runApp(const ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guidebook Chatbot Input',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const ChatbotInputScreen(),
    );
  }
}

class ChatbotInputScreen extends StatefulWidget {
  const ChatbotInputScreen({super.key});

  @override
  State<ChatbotInputScreen> createState() => _ChatbotInputScreenState();
}

class _ChatbotInputScreenState extends State<ChatbotInputScreen> {
  // Store messages here. Format: {text: String, isUser: bool}
  final List<Map<String, dynamic>> _messages = [];
  
  // Controller to read and clear input
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Session Management
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    // Generate a unique session ID on startup, similar to JS `crypto.randomUUID()`
    _sessionId = const Uuid().v4();
  }

  // Handle sending a message
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return; // Don't send empty messages

    _textController.clear(); // Clear input field

    // 1. Add User Message to UI immediately
    setState(() {
      _messages.add({'text': text.trim(), 'isUser': true});
    });
    
    _scrollToBottom();

    // 2. Send to Backend
    _sendMessageToBackend(text.trim());
  }

  // Implements the specific JSON payload structure from chat-widget.js
  Future<void> _sendMessageToBackend(String userQuery) async {
    // Correct localhost for Android Emulator if needed
    String urlString = kBaseUrl;
    if (!kIsWeb && Platform.isAndroid && kBaseUrl.contains('localhost')) {
      urlString = kBaseUrl.replaceFirst('localhost', '10.0.2.2');
    }

    final Uri url = Uri.parse(urlString);

    // Construct Payload mirroring chat-widget.js `sendMessage` function
    final Map<String, dynamic> payload = {
      "action": "sendMessage",
      "sessionId": _sessionId,
      "route": kRoute,
      "chatInput": userQuery,
      "metadata": {
        "userId": "" // Empty as per JS example
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        
        // Handle response format: JS handles both Array and Object
        // logic: Array.isArray(data) ? data[0].output : data.output;
        String botOutput = "No response text found.";
        
        if (data is List && data.isNotEmpty) {
          botOutput = data[0]['output'] ?? "Empty response";
        } else if (data is Map<String, dynamic>) {
          botOutput = data['output'] ?? "Empty response";
        }

        if (mounted) {
          setState(() {
            _messages.add({
              'text': botOutput.split('</think>').last.trim(),
              'isUser': false
            });
          });
          _scrollToBottom();
        }
      } else {
        _handleError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _handleError("Connection error: $e");
    }
  }

  void _handleError(String errorMsg) {
    if (mounted) {
      setState(() {
        _messages.add({
          'text': "Error: Could not connect to assistant. $errorMsg",
          'isUser': false
        });
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Wait for frame to build so list height is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // --- 1. Dynamic Content Area ---
            Expanded(
              child: _messages.isEmpty 
                  ? _buildWelcomeView() // Show Sphere if no messages
                  : _buildChatListView(), // Show Chat if messages exist
            ),

            // --- 2. Fixed Input Area ---
            BottomInputArea(
              controller: _textController,
              onSubmitted: _handleSubmitted,
            ),
          ],
        ),
      ),
    );
  }

  // The original "Welcome" view with the Green Sphere
  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: kGreenAccent.withOpacity(0.5),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    kGreenAccent.withOpacity(0.8),
                    kGreenAccent.withOpacity(0.3),
                    Colors.white.withOpacity(0),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Send a message to start chat.',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Note: The conversation is not saved locally, but maintains session ID.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // The Chat List View
  Widget _buildChatListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['isUser'] as bool;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? kUserBubbleColor : kLightGrey,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            child: Text(
              msg['text'],
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4, // Better line height for multiline text
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Modified Input Area ---
class BottomInputArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const BottomInputArea({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: kLightGrey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom for multiline growth
              children: [
                // Text Input
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: controller,
                      maxLines: null, 
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Aa',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14.0), 
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Explicit Send Button
                      Container(
                        margin: const EdgeInsets.only(right: 4.0),
                        decoration: const BoxDecoration(
                          color: kGreenAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: () => onSubmitted(controller.text),
                          tooltip: 'Send Message',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Please double-check responses.',
              style: TextStyle(color: Colors.grey, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
}