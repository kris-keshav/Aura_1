import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aura/controller/image_controller.dart';
import 'package:aura/controller/image_controller.dart';

class SavedImagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ImageController _c = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Images"),
      ),
      body: Obx(() {
        final imageList = _c.imageList;
        return ListView.builder(
          itemCount: imageList.length,
          itemBuilder: (context, index) {
            final imageUrl = imageList[index];
            return ListTile(
              leading: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              title: Text('Image ${index + 1}'),
              onTap: () {
                // Optionally, add functionality to view image in full-screen
              },
            );
          },
        );
      }),
    );
  }
}
