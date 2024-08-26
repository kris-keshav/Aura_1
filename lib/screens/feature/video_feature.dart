import 'dart:developer';
import 'package:aura/controller/video_controller.dart';
import 'package:aura/helper/global.dart';
import 'package:aura/widgets/custom_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoFeature extends StatefulWidget {
  const VideoFeature({super.key});

  @override
  State<VideoFeature> createState() => _VideoFeatureState();
}

class _VideoFeatureState extends State<VideoFeature> {
  final VideoController _c = Get.put(VideoController());

  @override
  void dispose() {
    _c.textC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.withOpacity(0.4),
        title: const Text("AI Video Creator"),
        titleTextStyle: TextStyle(
          color: Color(0xffE0FFFF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            color: Colors.grey,
          ),
        ),
        actions: [
          Obx(() => _c.status.value == Status.complete
              ? IconButton(
            padding: const EdgeInsets.only(right: 6),
            onPressed: _c.shareVideo,
            icon: const Icon(Icons.share),
          )
              : const SizedBox()),
        ],
      ),
      floatingActionButton: Obx(() => _c.status.value == Status.complete
          ? Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 6),
        child: FloatingActionButton(
          onPressed: _c.downloadVideo,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: const Icon(
            Icons.save_alt_rounded,
            size: 26,
          ),
        ),
      )
          : const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: mq.height * 0.02,
          bottom: mq.height * 0.1,
          left: mq.width * 0.04,
          right: mq.width * 0.04,
        ),
        children: [
          TextFormField(
            controller: _c.textC,
            textAlign: TextAlign.center,
            minLines: 2,
            maxLines: null,
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              hintText:
              'Describe something wonderful and creative, and I will create amazing videos for you',
              hintStyle: TextStyle(fontSize: 13.5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
          SizedBox(height: mq.height * 0.02),
          CustomBtn(
            onTap: () async {
              await _c.searchAiVideo(context);  // Pass the BuildContext here
            },
            text: 'Create',
          ),


          SizedBox(height: mq.height * 0.02),
          Obx(() => _c.status.value == Status.loading
              ? const Center(child: CircularProgressIndicator())
              : _aiVideo()),
        ],
      ),
    );
  }

  Widget _aiVideo() {
    switch (_c.status.value) {
      case Status.none:
        return const Center(
            child: Text(
              'Start by describing your video',
              textAlign: TextAlign.center,
            ));
      case Status.loading:
        return const Center(child: CircularProgressIndicator());
      case Status.complete:
        if (_c.url.value.isNotEmpty) {
          log('Attempting to load video: ${_c.url.value}');
          return _videoPlayer(_c.url.value);
        } else {
          log('URL is empty');
          return const Text('No video provided', textAlign: TextAlign.center);
        }
      case Status.error:
        return Text(
          _c.errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        );
      default:
        return const SizedBox(); // Ensure a widget is always returned
    }
  }

  Widget _videoPlayer(String url) {
    // You can use a widget like `VideoPlayer` from `video_player` package to show video from the URL.
    return Column(
      children: [
        Text(
          'Your video:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ],
    );
  }
}
