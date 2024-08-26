import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String msg;
  final MessageType msgType;

  Message({required this.msg, required this.msgType});

  // Convert a Message to a Map
  Map<String, dynamic> toMap() {
    return {
      'msg': msg,
      'msgType': msgType.toString(),
    };
  }

  // Create a Message from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      msg: map['msg'] ?? '',
      msgType: MessageType.values.firstWhere(
            (e) => e.toString() == map['msgType'],
        orElse: () => MessageType.user,
      ),
    );
  }
}

enum MessageType { user, bot }
