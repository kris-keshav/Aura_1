import 'package:aura/api/apis.dart';
import 'package:aura/controller/chat_controller.dart';
import 'package:aura/controller/image_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'helper/global.dart';
import 'helper/pref.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences, Firebase, etc.
  await _initializeFirebase();
  await _initializePreferences();

  // Fetch user information early if the user is signed in
  if (FirebaseAuth.instance.currentUser != null) {
    await APIs.getSelfInfo();
  }

  // Hide system UI elements
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize controllers
  Get.put(ImageController());
  Get.put(ChatController());

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> _initializePreferences() async {
  await Pref.initialize();

  // Instead of using window, use View.of(context) to obtain mq size
  // We'll initialize mq in the SplashScreen's build method using MediaQuery.of(context).size
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      themeMode: Pref.defaultTheme(),

      // dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // light theme
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue),
          titleTextStyle: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      home: FutureBuilder<Widget>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); // Show splash screen while checking
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data ?? const LoginScreen(); // Navigate based on login status
          }
        },
      ),
    );
  }

  Future<Widget> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Ensure the user information is fetched before showing the home screen
      if (FirebaseAuth.instance.currentUser != null) {
        await APIs.getSelfInfo();
      }
      return HomeScreen(); // Navigate to the home screen if logged in
    } else if (Pref.showOnboarding) {
      return OnBoardingScreen(); // Show onboarding if needed
    } else {
      return LoginScreen(); // Otherwise, show the login screen
    }
  }
}

extension AppTheme on ThemeData {
  Color get lightTextColor => brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color get buttonColor => brightness == Brightness.dark ? Colors.cyan.withOpacity(0.5) : Colors.blue;
}
