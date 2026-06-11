import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io'; // To detect platform for localhost
import 'package:flutter/foundation.dart'; // To detect web
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For LogicalKeyboardKey
import 'package:http/http.dart' as http; // HTTP requests
import 'package:uuid/uuid.dart'; // For Session ID generation
import 'l10n/app_localizations.dart';

// --- Custom Colors ---
const Color kGreenAccent = Colors.teal;
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kBotBubbleColor = Color(0xFFE0E0E0);
const Color kUserBubbleColor = Colors.teal;

const String kBaseUrl = 'http://localhost:5678/webhook/282b07f6-e889-432e-8b1b-f31979563281/chat';
const String kRoute = 'general';

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatbotScreen();
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = const Uuid().v4();
  }

  void _handleSubmitted(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return; 

    _textController.clear();

    setState(() {
      _messages.add({'text': trimmedText, 'isUser': true});
      _isTyping = true;
    });
    
    _scrollToBottom();
    _sendMessageToBackend(trimmedText);
  }

  Future<void> _sendMessageToBackend(String userQuery) async {
    String urlString = kBaseUrl;
    if (!kIsWeb && Platform.isAndroid && kBaseUrl.contains('localhost')) {
      urlString = kBaseUrl.replaceFirst('localhost', '10.0.2.2');
    }

    final Uri url = Uri.parse(urlString);

    final Map<String, dynamic> payload = {
      "action": "sendMessage",
      "sessionId": _sessionId,
      "route": kRoute,
      "chatInput": userQuery,
      "metadata": {
        "userId": "" 
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
        String botOutput = "No response text found.";
        
        if (data is List && data.isNotEmpty) {
          botOutput = data[0]['output'] ?? "Empty response";
        } else if (data is Map<String, dynamic>) {
          botOutput = data['output'] ?? "Empty response";
        }

        if (mounted) {
          setState(() {
            _isTyping = false;
            final cleanOutput = botOutput.contains('</think>') 
                ? botOutput.split('</think>').last.trim() 
                : botOutput;
                
            _messages.add({
              'text': cleanOutput,
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
        _isTyping = false;
        _messages.add({
          'text': "Error: Could not connect to assistant.",
          'isUser': false,
          'isError': true,
        });
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String greetingText = l10n?.chatbot_greeting ?? "How can I help you?";
    final String placeholderText = l10n?.chatbot_placeholder ?? "Ask about destinations, itineraries, or travel tips.";
    final String labelAsk = l10n?.chatbot_btn_ask ?? "Ask Guide";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_outlined, color: kGreenAccent),
            const SizedBox(width: 8),
            Text(labelAsk),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: _messages.isEmpty 
                  ? _buildWelcomeView(greetingText, placeholderText) 
                  : _buildChatListView(),
            ),
            if (_isTyping)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent, 
                valueColor: AlwaysStoppedAnimation<Color>(kGreenAccent)
              ),
            BottomInputArea(
              controller: _textController,
              onSubmitted: _handleSubmitted,
            ),
          ],
        ),
      ),
    );
  }

  // Pass localized strings arguments safely down into the welcome layout tree
  Widget _buildWelcomeView(String greeting, String placeholder) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kGreenAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: kGreenAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              placeholder,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatListView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['isUser'] as bool;
        final isError = msg['isError'] ?? false;
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser 
                  ? kUserBubbleColor 
                  : (isError ? Colors.red[50] : kBotBubbleColor),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(2),
                bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
              ),
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            child: Text(
              msg['text'],
              style: TextStyle(
                color: isUser ? Colors.white : (isError ? Colors.red[900] : Colors.black87),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BottomInputArea extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const BottomInputArea({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  State<BottomInputArea> createState() => _BottomInputAreaState();
}

class _BottomInputAreaState extends State<BottomInputArea> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
              color: kLightGrey.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter, includeRepeats: false): () {
                          widget.onSubmitted(widget.controller.text);
                        },
                      },
                      child: TextField(
                        focusNode: _focusNode,
                        controller: widget.controller,
                        maxLines: 5, 
                        minLines: 1,
                        maxLength: 300,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: 'Aa',
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 14.0), 
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 4.0),
                        decoration: const BoxDecoration(
                          color: kGreenAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: () => widget.onSubmitted(widget.controller.text),
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