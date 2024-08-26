import 'package:aura/controller/chat_controller.dart';
import 'package:aura/screens/chat_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedConversationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatController _c = Get.find<ChatController>(); // Ensure ChatController is initialized and accessible

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Conversations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _c.getChatSessionsStream(), // Use a method to get the stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final sessions = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final sessionId = session.id;
              final sessionTitle = 'Chat on ${session['timestamp'].toDate()}';
              return ListTile(
                title: Text(sessionTitle),
                onTap: () async {
                  Get.to(() => ChatDetailsScreen(sessionId: sessionId)); // Load selected chat session
                  // Navigate to chat details or another screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
