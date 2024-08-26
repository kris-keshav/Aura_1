import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aura/controller/chat_controller.dart';

class ChatDetailsScreen extends StatelessWidget {
  final String sessionId;

  ChatDetailsScreen({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final ChatController _c = Get.find<ChatController>();

    // Load chat history for the selected session
    _c.loadChatHistory(sessionId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: Obx(() {
        final messages = _c.list;
        if (messages.isEmpty) {
          return Center(child: Text('No messages found.'));
        }
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return ListTile(
              title: Text(message.msg),
              subtitle: Text(message.msgType.toString()), // Customize as needed
            );
          },
        );
      }),
    );
  }
}
