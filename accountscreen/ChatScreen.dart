import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;
  String? _userId;
  bool _isSending = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeChat();

    // Invisible auto-refresh timer (runs every 3 seconds)
    // This keeps the chat updated live while you are on this screen
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_userId != null && !_isSending) {
        _loadMessages(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      setState(() => _userId = userId);

      await _loadMessages(silent: false);

      // Subscribe to real-time updates for the list view
      supabase
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('client_id', userId)
          .listen((List<Map<String, dynamic>> data) {
            if (mounted) {
              setState(() {
                messages = data
                  ..sort(
                    (a, b) => DateTime.parse(
                      b['sent_at'],
                    ).compareTo(DateTime.parse(a['sent_at'])),
                  );
              });
            }
          });
    } catch (e) {
      debugPrint('Error initializing chat: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    try {
      if (_userId == null) return;

      final data = await supabase
          .from('chat_messages')
          .select()
          .eq('client_id', _userId!)
          .order('sent_at', ascending: false);

      if (mounted) {
        setState(() {
          messages = data;
          if (!silent) _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (mounted && !silent) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    try {
      setState(() => _isSending = true);
      _messageController.clear();

      await supabase.from('chat_messages').insert({
        'client_id': _userId,
        'message': messageText.trim(),
        'sent_at': DateTime.now().toIso8601String(),
      });

      // Reload messages immediately
      await _loadMessages(silent: true);
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFAF7),
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1a472a),
            size: 20,
          ),
        ),
        title: const Text(
          'Chat with Admin',
          style: TextStyle(
            color: Color(0xFF1a472a),
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1a472a)),
            )
          : Column(
              children: [
                // Messages List
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a conversation with our admin',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final hasReply =
                                message['reply'] != null &&
                                message['reply'].toString().isNotEmpty;

                            // Each list item now contains the user message (left)
                            // and the admin reply (right, if it exists).
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // User Message (Aligned Left)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.75,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1a472a),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message['message'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatTime(message['sent_at']),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Admin Reply (if exists, Aligned Right)
                                if (hasReply)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        top: 4,
                                        bottom: 12,
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.75,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9F8F5),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Admin',
                                            style: TextStyle(
                                              color: const Color(0xFF1a472a),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            message['reply'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
                Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isSending,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (text) {
                            if (text.isNotEmpty && !_isSending) {
                              _sendMessage(text);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFF1a472a),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            color: Color(0xFF2C2C2C),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isSending
                            ? null
                            : () {
                                final text = _messageController.text;
                                if (text.isNotEmpty) {
                                  _sendMessage(text);
                                }
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isSending
                                ? const Color(0xFF1a472a).withOpacity(0.6)
                                : const Color(0xFF1a472a),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: _isSending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
