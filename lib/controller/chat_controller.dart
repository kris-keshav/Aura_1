import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aura/api/apis.dart';
import 'package:aura/models/message.dart';
import 'package:aura/helper/dialogs.dart';

class ChatController extends GetxController {
  final textC = TextEditingController();
  final scrollC = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Ensure this is declared

  // Method to get the stream of chat sessions
  Stream<QuerySnapshot> getChatSessionsStream() {
    return _firestore.collection('chat_sessions').orderBy('timestamp', descending: true).snapshots();
  }

  final list = <Message>[
    Message(msg: 'Hello, How can I help you?', msgType: MessageType.bot)
  ].obs;

  String _currentSessionId = '';

  Future<void> askQuestion() async {
    if (textC.text.trim().isNotEmpty) {
      // Add user's message
      list.add(Message(msg: textC.text, msgType: MessageType.user));

      // Add "Please wait" message
      list.add(Message(msg: '', msgType: MessageType.bot));
      _scrollDown();

      // Get response from API
      final res = await APIs.getAnswer(textC.text);

      // Clear the text field
      textC.text = '';

      // Update the last message with the bot's response
      list[list.length - 1] = Message(msg: res, msgType: MessageType.bot);
      _scrollDown();

      // Save the chat session
      await saveChatSession();
    } else {
      Dialogs.info('Ask Something');
    }
  }

  Future<void> saveChatSession() async {
    if (_currentSessionId.isEmpty) {
      // Create a new chat session
      final docRef = await _firestore.collection('chat_sessions').add({
        'messages': list.map((e) => e.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _currentSessionId = docRef.id;
    } else {
      // Update the existing chat session
      await _firestore.collection('chat_sessions').doc(_currentSessionId).update({
        'messages': list.map((e) => e.toMap()).toList(),
      });
    }
  }

  Future<void> loadChatHistory(String sessionId) async {
    _currentSessionId = sessionId;
    final docSnapshot = await _firestore.collection('chat_sessions').doc(sessionId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        final messages = List<Map<String, dynamic>>.from(data['messages']);
        list.value = messages.map((msg) => Message.fromMap(msg)).toList();
        _scrollDown();
      }
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollC.animateTo(
        scrollC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }
}
