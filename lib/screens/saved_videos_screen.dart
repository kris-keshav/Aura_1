import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aura/controller/video_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SavedVideosScreen extends StatelessWidget {
  final VideoController _c = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Videos'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            color: Colors.grey,
          ),
        ),
      ),
      body: Obx(() {
        if (_c.videoList.isEmpty) {
          return Center(child: Text('No saved videos'));
        } else {
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: _c.videoList.length,
            itemBuilder: (context, index) {
              final videoUrl = _c.videoList[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                leading: CachedNetworkImage(
                  imageUrl: videoUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text('Video $index'),
                onTap: () {
                  // Optionally open video in full screen or in a video player widget
                },
              );
            },
          );
        }
      }),
    );
  }
}
