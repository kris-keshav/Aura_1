import 'package:aura/screens/saved_conversations_screen.dart';
import 'package:aura/screens/saved_images_screen.dart';
import 'package:aura/screens/saved_videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:aura/helper/global.dart';
import 'package:aura/helper/pref.dart';
import 'package:aura/widgets/home_card.dart';
import 'package:aura/models/home_type.dart';
import 'package:aura/screens/profile_screen.dart';
import 'package:aura/api/apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _isDarkMode = Pref.isDarkMode.obs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Pref.showOnboarding = false;
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.withOpacity(0.4),
        title: const Text(
          appName,
          style: TextStyle(
            color: Color(0xffE0FFFF),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: () {
              Get.changeThemeMode(_isDarkMode.value ? ThemeMode.light : ThemeMode.dark);
              _isDarkMode.value = !_isDarkMode.value;
              Pref.isDarkMode = _isDarkMode.value;
            },
            icon: Obx(
                  () => Icon(
                _isDarkMode.value ? Icons.brightness_2_rounded : Icons.brightness_4_rounded,
                size: 26,
              ),
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
      drawer: Container(
        width: mq.width * 0.4, // Adjusted width for a narrower drawer
        child: Drawer(
          child: Obx(() {
            final isDarkMode = _isDarkMode.value;
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: mq.height * 0.2,
                  color: isDarkMode ? Colors.black : Colors.teal.withOpacity(0.5),
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.teal.withOpacity(0.5),
                    ),
                    child: Center(
                      child: Text(
                        'Menu',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Get.to(() => ProfileScreen(user: APIs.me)); // Pass the user object
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Saved Images'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Get.to(() => SavedImagesScreen()); // Navigate to Saved Images screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Saved Conversations'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Get.to(() => SavedConversationsScreen()); // Navigate to Saved Conversations screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Saved Videos'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Get.to(() => SavedVideosScreen()); // Navigate to Saved Conversations screen
                  },
                ),
              ],
            );
          }),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.04,
          vertical: mq.height * 0.015,
        ),
        children: HomeType.values.map((e) => HomeCard(homeType: e)).toList(),
      ),
    );
  }
}
