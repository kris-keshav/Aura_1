import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:aura/screens/feature/chatbot_feature.dart';
import 'package:aura/screens/feature/image_feature.dart';
import 'package:aura/screens/feature/translator_feature.dart';
import 'package:aura/screens/feature/video_feature.dart'; // Import the new feature screen

enum HomeType { aiChatBot, aiImage, aiTranslator, aiVideo } // Added aiVideo

extension MyHomeType on HomeType {
  String get title => switch (this) {
    HomeType.aiChatBot => "AI ChatBot",
    HomeType.aiImage => "AI Image Creator",
    HomeType.aiTranslator => "Language Translator",
    HomeType.aiVideo => "Text to Video Generator", // Added title for aiVideo
  };

  String get lottie => switch (this) {
    HomeType.aiChatBot => "ai_hand_waving.json",
    HomeType.aiImage => "ai_play.json",
    HomeType.aiTranslator => "ai_ask_me.json",
    HomeType.aiVideo => "ai_video.json", // Added Lottie animation for aiVideo
  };

  bool get leftAlign => switch (this) {
    HomeType.aiChatBot => true,
    HomeType.aiImage => false,
    HomeType.aiTranslator => true,
    HomeType.aiVideo => false, // Set alignment for aiVideo
  };

  EdgeInsets get padding => switch (this) {
    HomeType.aiChatBot => EdgeInsets.zero,
    HomeType.aiImage => const EdgeInsets.all(20),
    HomeType.aiTranslator => EdgeInsets.zero,
    HomeType.aiVideo => const EdgeInsets.all(20), // Set padding for aiVideo
  };

  VoidCallback get onTap => switch (this) {
    HomeType.aiChatBot => () => Get.to(() => const ChatBotFeature()),
    HomeType.aiImage => () => Get.to(() => const ImageFeature()),
    HomeType.aiTranslator => () => Get.to(() => const TranslatorFeature()),
    HomeType.aiVideo => () => Get.to(() => const VideoFeature()), // Navigate to the Video Feature
  };
}
