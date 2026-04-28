import 'package:flutter/material.dart';

// --- Custom Colors ---
const Color kGreenAccent = Color(0xFF1CB954);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kBotBubbleColor = Color(0xFFE0E0E0);
const Color kUserBubbleColor = Color(0xFF1CB954);

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

  // Handle sending a message
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return; // Don't send empty messages

    _textController.clear(); // Clear input field

    setState(() {
      _messages.add({'text': text.trim(), 'isUser': true});
    });
    
    _scrollToBottom();

    // Simulate Bot Response
    _simulateBotResponse(text);
  }

  // Simulate a delay and a response from the bot
  void _simulateBotResponse(String userQuery) {
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': "I am a simulated bot. I received your message:\n\"$userQuery\"",
            'isUser': false
          });
        });
        _scrollToBottom();
      }
    });
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
                    color: kGreenAccent.withValues(alpha: 0.5),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    kGreenAccent.withValues(alpha: 0.8),
                    kGreenAccent.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0),
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
            'Note: The conversation is not saved. Each session starts fresh.',
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
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'How can we help you today?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: kLightGrey.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom for multiline growth
              children: [
                // "Formal" Dropdown Look
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(10),
                //       border: Border.all(color: Colors.grey.shade300),
                //     ),
                //     child: const Row(
                //       children: [
                //         Text('Formal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                //         Icon(Icons.keyboard_arrow_down, size: 20),
                //       ],
                //     ),
                //   ),
                // ),
                
                // Text Input
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: controller,
                      // Changed: Set maxLines to null for unlimited lines (scrolling)
                      // or set a specific number like 5
                      maxLines: null, 
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      // Changed: Use newline action so "Enter" creates a new line
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Aa',
                        border: InputBorder.none,
                        // Removed isDense/contentPadding strictness to allow better multiline layout
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
                      // Attachment Icons
                      // IconButton(
                      //   icon: const Icon(Icons.attach_file, color: Colors.grey),
                      //   onPressed: () {},
                      //   constraints: const BoxConstraints(),
                      //   padding: const EdgeInsets.symmetric(horizontal: 4),
                      // ),
                      
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