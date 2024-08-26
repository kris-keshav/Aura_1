import 'package:aura/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aura/helper/global.dart';
import 'package:aura/screens/login_screen.dart';
import 'package:aura/screens/onboarding_screen.dart';
import 'package:aura/widgets/custom_loading.dart';
import 'package:aura/helper/pref.dart';
import 'package:aura/api/apis.dart'; // Import your authentication API

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      // Check if the user is already signed in
      final isSignedIn = await APIs.isUserSignedIn(); // Replace this with your method to check auth status

      if (isSignedIn) {
        // Navigate to the main screen if the user is signed in
        Get.off(() => const HomeScreen()); // Replace with your main screen
      } else {
        // If the user is not signed in, navigate to onboarding or login
        if (Pref.showOnboarding) {
          Get.off(() => const OnBoardingScreen());
        } else {
          Get.off(() => const LoginScreen());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(flex: 2),
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(mq.width * 0.05),
                child: Image.asset('assets/images/aura_icon.png', width: mq.width * 0.4),
              ),
            ),
            const Spacer(),
            const CustomLoading(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
