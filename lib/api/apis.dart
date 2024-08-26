import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:aura/models/aura_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:aura/helper/global.dart';

class APIs {
  // Constants
  static const String _gapiUrlChat = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  static const String _lexicaApiUrl = 'https://lexica.art/api/v1/search';
  static const String _text_to_video_apiUrl = 'https://modelslab.com/api/v6/video/text2video';
  static final String _gapiToken = GapiKey;
  static final String _textToVideoapiToken = TextToVideoApiKey;

  // Firebase Auth instance
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseAuth get auth => _auth;

  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static FirebaseFirestore get firestore => _firestore;

  // Current user information
  static late AuraUser me;
  static User get user => auth.currentUser!;

  // API Call: Get Answer
  static Future<String> getAnswer(String question) async {
    try {
      final String url = '$_gapiUrlChat?key=$_gapiToken';
      final body = jsonEncode({
        "contents": [
          {"parts": [{"text": question}]}
        ]
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] ?? 'No generated text found';
          }
        }
        return 'Invalid response structure';
      } else {
        return 'API call failed with status code ${response.statusCode}';
      }
    } catch (e) {
      return 'Something went wrong. Please try again later.';
    }
  }

  // API Call: Search AI Images
  static Future<List<String>> searchAiImages(String prompt) async {
    try {
      final response = await http.get(Uri.parse('$_lexicaApiUrl?q=$prompt'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final images = data['images'] as List?;
        return images?.map((e) => e['src'].toString()).toList() ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // API Call: Generate AI Video
  // API Call: Generate AI Video
  static Future<List<String>> generateAiVideo(String prompt) async {
    try {
      // Define request payload
      final body = jsonEncode({
        "key": _textToVideoapiToken,
        "model_id": "zeroscope",
        "prompt": prompt,
        "negative_prompt": "low quality",
        "height": 320,
        "width": 576,
        "num_frames": 16,
        "num_inference_steps": 20,
        "guidance_scale": 7,
        "upscale_height": 640,
        "upscale_width": 1024,
        "upscale_strength": 0.6,
        "upscale_guidance_scale": 12,
        "upscale_num_inference_steps": 20,
        "output_type": "mp4",
        "webhook": null,
        "track_id": null,
      });

      // Make POST request
      final response = await http.post(
        Uri.parse(_text_to_video_apiUrl),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      );

      // Parse response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final videos = data['output'] as List?;
        return videos?.map((e) => e.toString()).toList() ?? [];
      } else {
        log('API call failed with status code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error in generateAiVideo: $e');
      return [];
    }
  }


  // Check if user exists
  static Future<bool> userExists() async {
    final doc = await firestore.collection('users').doc(user.uid).get();
    return doc.exists;
  }

  // Get current user info
  static Future<void> getSelfInfo() async {
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      me = AuraUser.fromJson(doc.data()!);
    } else {
      await createUser();
      await getSelfInfo();
    }
  }

  // Create a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = AuraUser(
      about: "Hey there, I'm using Aura - My new AI Companion!",
      email: user.email.toString(),
      id: user.uid,
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
    );
    await firestore.collection('users').doc(user.uid).set(newUser.toJson());
  }

  // Get all users except the current user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore.collection('users').where('id', isNotEqualTo: user.uid).snapshots();
  }

  // Update user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // Check if the user is signed in
  static Future<bool> isUserSignedIn() async {
    try {
      // Check if the user is authenticated by Firebase
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Check if the user document exists in Firestore
        final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
        return userDoc.exists;
      }
      return false;
    } catch (e) {
      log('Error checking if user is signed in: $e');
      return false;
    }
  }

}
