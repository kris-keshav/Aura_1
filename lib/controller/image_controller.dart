import 'dart:typed_data';
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

class ImageController extends GetxController {
  final textC = TextEditingController();
  final status = Status.none.obs;
  final url = ''.obs;
  final imageList = <String>[].obs;

  Uint8List? imageData;
  String errorMessage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadImageHistory();
  }

  Future<void> downloadImage() async {
    if (imageData != null) {
      try {
        Dialogs.showLoadingDialog();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/temp_image.png';
        final file = File(filePath);
        await file.writeAsBytes(imageData!);
        await GallerySaver.saveImage(file.path, albumName: appName).then((success) {
          Get.back();
          if (success == true) {
            Dialogs.success('Image downloaded to Gallery');
          } else {
            Dialogs.error('Failed to save image');
          }
        });
      } catch (e) {
        Get.back();
        log('downloadImageE: $e');
        Dialogs.error('Failed to save image: $e');
      }
    } else {
      Dialogs.error('No image to save');
    }
  }

  Future<void> shareImage() async {
    if (imageData != null) {
      try {
        Dialogs.showLoadingDialog();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/temp_image.png';
        final file = File(filePath);
        await file.writeAsBytes(imageData!);
        Get.back();
        await Share.shareXFiles([XFile(filePath)], text: 'Great picture');
      } catch (e) {
        Get.back();
        log('downloadImageE: $e');
        Dialogs.error('Failed to save image: $e');
      }
    } else {
      Dialogs.error('No image to save');
    }
  }

  Future<void> searchAiImage() async {
    if (textC.text.trim().isNotEmpty) {
      status.value = Status.loading;
      try {
        log('Searching for AI images with prompt: ${textC.text}');
        imageList.value = await APIs.searchAiImages(textC.text);
        log('Image list: ${imageList.toString()}');

        if (imageList.isEmpty) {
          Dialogs.error('Something went wrong (Try again in sometime)');
          status.value = Status.error;
          return;
        }
        url.value = imageList.first;
        log('Image URL: ${url.value}');

        // Fetch and set image data
        imageData = await fetchImageData(url.value);
        status.value = Status.complete;

        // Save image data to Firestore
        await _saveImageToFirestore(url.value);

      } catch (e) {
        log('Error in searchAiImage: $e');
        Dialogs.error('Failed to fetch image: $e');
        status.value = Status.error;
      }
    } else {
      Dialogs.info('Provide some beautiful image description!');
    }
  }

  Future<Uint8List?> fetchImageData(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        log('Failed to load image data from URL: $imageUrl');
        return null;
      }
    } catch (e) {
      log('Error fetching image data: $e');
      return null;
    }
  }

  Future<void> _saveImageToFirestore(String imageUrl) async {
    try {
      final docRef = _firestore.collection('images').doc();
      await docRef.set({
        'url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error saving image to Firestore: $e');
    }
  }

  Future<void> _loadImageHistory() async {
    try {
      final querySnapshot = await _firestore.collection('images').orderBy('timestamp', descending: true).get();
      imageList.value = querySnapshot.docs.map((doc) => doc['url'] as String).toList();
    } catch (e) {
      log('Error loading image history from Firestore: $e');
    }
  }

  void deleteSelectedImages(List<String> selectedImages) async {
    // Remove images from Firestore
    // Example:
    await FirebaseFirestore.instance.collection('saved_images').where('url', whereIn: selectedImages).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
