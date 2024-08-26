import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:aura/helper/global.dart';
import 'package:aura/helper/dialogs.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:aura/api/apis.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

enum Status { none, loading, complete, error }

class VideoController extends GetxController {
  final textC = TextEditingController();
  final status = Status.none.obs;
  final url = ''.obs;
  final videoList = <String>[].obs;

  Uint8List? videoData;
  String errorMessage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadVideoHistory();
  }

  Future<void> downloadVideo() async {
    if (videoData != null) {
      try {
        Dialogs.showLoadingDialog();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/temp_video.mp4';
        final file = File(filePath);
        await file.writeAsBytes(videoData!);
        await GallerySaver.saveVideo(file.path, albumName: appName).then((success) {
          Get.back();
          if (success == true) {
            Dialogs.success('Video downloaded to Gallery');
          } else {
            Dialogs.error('Failed to save video');
          }
        });
      } catch (e) {
        Get.back();
        log('downloadVideo Error: $e');
        Dialogs.error('Failed to save video: $e');
      }
    } else {
      Dialogs.error('No video to save');
    }
  }

  Future<void> shareVideo() async {
    if (videoData != null) {
      try {
        Dialogs.showLoadingDialog();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/temp_image.png';
        final file = File(filePath);
        await file.writeAsBytes(videoData!);
        Get.back();
        await Share.shareXFiles([XFile(filePath)], text: 'Great video');
      } catch (e) {
        Get.back();
        log('downloadVideoeE: $e');
        Dialogs.error('Failed to save video: $e');
      }
    } else {
      Dialogs.error('No video to save');
    }
  }

  Future<void> searchAiVideo(BuildContext context) async {
    if (textC.text.trim().isNotEmpty) {
      status.value = Status.loading;
      try {
        final response = await http.post(
          Uri.parse('https://modelslab.com/api/v6/video/text2video'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'key': TextToVideoApiKey,
            'model_id': 'zeroscope',
            'prompt': textC.text,
            'negative_prompt': 'low quality',
            'width': 512,
            'height': 512,
            'num_frames': 16,
            'num_inference_steps': 20,
            'guidance_scale': 7,
            'output_type': 'gif', // or 'mp4'
          }),
        );

        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          videoList.value = jsonResponse['output'].cast<String>();
          if (videoList.isNotEmpty) {
            url.value = videoList.first;
            videoData = await fetchVideoData(url.value);
            status.value = Status.complete;
            await _saveVideoToFirestore(url.value); // Save video URL to Firestore
          } else {
            status.value = Status.error;
            Dialogs.error('No videos found');
          }
        } else {
          status.value = Status.error;
          Dialogs.error('API Error: ${jsonResponse['message']}');
        }
      } catch (e) {
        status.value = Status.error;
        Dialogs.error('Failed to generate video: $e');
      }
    } else {
      Dialogs.info('Provide some creative video description!');
    }
  }


  Future<Uint8List?> fetchVideoData(String videoUrl) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        log('Failed to load video data from URL: $videoUrl');
        return null;
      }
    } catch (e) {
      log('Error fetching video data: $e');
      return null;
    }
  }

  Future<void> _saveVideoToFirestore(String videoUrl) async {
    try {
      final docRef = _firestore.collection('videos').doc();
      await docRef.set({
        'url': videoUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error saving video to Firestore: $e');
    }
  }

  Future<void> _loadVideoHistory() async {
    try {
      final querySnapshot = await _firestore.collection('videos').orderBy('timestamp', descending: true).get();
      videoList.value = querySnapshot.docs.map((doc) => doc['url'] as String).toList();
    } catch (e) {
      log('Error loading video history from Firestore: $e');
    }
  }
}
