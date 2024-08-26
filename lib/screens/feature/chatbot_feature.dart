import 'package:aura/helper/global.dart';
import 'package:aura/main.dart';
import 'package:aura/widgets/message_card.dart';
import 'package:flutter/material.dart';
import 'package:aura/controller/chat_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBotFeature extends StatefulWidget {
  const ChatBotFeature({super.key});

  @override
  State<ChatBotFeature> createState() => _ChatBotFeatureState();
}

class _ChatBotFeatureState extends State<ChatBotFeature> {
  final _c = ChatController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<Map<String, dynamic>>> _chatHistoryStream;

  @override
  void initState() {
    super.initState();
    _chatHistoryStream = _firestore.collection('chat_sessions').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.withOpacity(0.4),
        title: const Text("Chat with AI Assistant"),
        titleTextStyle: TextStyle(
          color: Color(0xffE0FFFF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            color: Colors.grey,
          ),
        ),
      ),
      endDrawer: Drawer(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _chatHistoryStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final sessions = snapshot.data ?? [];
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Chat History',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ...sessions.map((session) {
                  final sessionId = session['id'];
                  final sessionTitle = 'Chat on ${session['timestamp'].toDate()}'; // Format as needed
                  return ListTile(
                    title: Text(sessionTitle),
                    onTap: () async {
                      Navigator.pop(context); // Close the drawer
                      await _c.loadChatHistory(sessionId); // Load selected chat session
                      setState(() {}); // Refresh the screen
                    },
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _c.textC,
                textAlign: TextAlign.center,
                onTapOutside: (e) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  filled: true,
                  isDense: true,
                  hintText: 'Ask me anything you want...',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8,),
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).buttonColor,
              child: IconButton(
                onPressed: _c.askQuestion,
                icon: const Icon(Icons.rocket_launch_rounded),
              ),
            ),
          ],
        ),
      ),
      body: Obx(
            () => ListView(
          physics: const BouncingScrollPhysics(),
          controller: _c.scrollC,
          padding: EdgeInsets.only(top: mq.height * 0.02, bottom: mq.height * 0.1),
          children: _c.list.map((e) => MessageCard(message: e)).toList(),
        ),
      ),
    );
  }
}
