import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ChatScreen.dart';

class ChatNotificationWrapper extends StatefulWidget {
  final Widget child;

  const ChatNotificationWrapper({super.key, required this.child});

  @override
  State<ChatNotificationWrapper> createState() =>
      _ChatNotificationWrapperState();
}

class _ChatNotificationWrapperState extends State<ChatNotificationWrapper> {
  final supabase = Supabase.instance.client;
  bool _initialized = false;
  String? _lastRepliedMessageId;

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('client_id', userId)
        .listen((List<Map<String, dynamic>> data) {
          if (!mounted) return;

          // Filter for messages that have a reply
          final repliedMessages = data
              .where(
                (m) => m['reply'] != null && m['reply'].toString().isNotEmpty,
              )
              .toList();

          // Sort by time (newest first)
          repliedMessages.sort(
            (a, b) => DateTime.parse(
              b['sent_at'],
            ).compareTo(DateTime.parse(a['sent_at'])),
          );

          if (repliedMessages.isEmpty) {
            _initialized = true;
            return;
          }

          final latestReply = repliedMessages.first;
          final latestId = latestReply['id'];

          // If this is our first load, just store the ID and don't notify
          if (!_initialized) {
            _lastRepliedMessageId = latestId;
            _initialized = true;
            return;
          }

          // If the latest reply ID is different from what we last saw, it's a new reply
          if (latestId != _lastRepliedMessageId) {
            _lastRepliedMessageId = latestId;

            // Show Notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'New reply from Admin: "${latestReply['reply']}"',
                ),
                backgroundColor: const Color(0xFF1a472a),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'VIEW',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
