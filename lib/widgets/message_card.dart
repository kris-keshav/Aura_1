import 'package:aura/helper/global.dart';
import 'package:aura/main.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:aura/models/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(15);
    final isBotMessage = message.msgType == MessageType.bot;

    return Row(
      mainAxisAlignment: isBotMessage ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isBotMessage) ...[
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Image.asset(
              'assets/images/aura_icon.png',
              width: 24,
            ),
          ),
        ],
        Expanded(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.02,
              left: isBotMessage ? MediaQuery.of(context).size.width * 0.02 : 0,
              right: isBotMessage ? 0 : MediaQuery.of(context).size.width * 0.02,
            ),
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.01,
              horizontal: MediaQuery.of(context).size.width * 0.02,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: isBotMessage ? Colors.black54 : Theme.of(context).lightTextColor),
              borderRadius: isBotMessage
                  ? const BorderRadius.only(topLeft: r, topRight: r, bottomRight: r)
                  : const BorderRadius.only(topLeft: r, topRight: r, bottomLeft: r),
            ),
            child: message.msg.isEmpty
                ? AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Please wait...',
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              repeatForever: true,
            )
                : Text(
              message.msg,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        if (!isBotMessage) ...[
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}
