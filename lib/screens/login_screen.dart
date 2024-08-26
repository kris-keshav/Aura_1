import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aura/api/apis.dart';
import 'package:aura/helper/dialogs.dart';
import 'package:aura/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  void _handleGoogleBtnClick() async {
    setState(() {
      _isLoading = true;
    });
    Dialogs.showProgressBar(context);

    try {
      final user = await _signInWithGoogle();

      // Hide progress bar
      Navigator.pop(context);

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUser Additional Information: ${user.additionalUserInfo}');

        if (await APIs.userExists()) {
          Get.offAll(() => const HomeScreen());
        } else {
          await APIs.createUser();
          Get.offAll(() => const HomeScreen());
        }
      } else {
        Dialogs.showSnackBar(context, 'Sign-in failed. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error during sign-in process: $e');
      Dialogs.showSnackBar(context, 'Something went wrong. Please check your internet connection.');
    }
  }


  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Check for internet connectivity
      await InternetAddress.lookup('google.com');

      // Trigger Google sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('Error signing in with Google: $e');
      // Display error message to the user
      Dialogs.showSnackBar(context, 'Something went wrong. Please check your internet connection.');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.tealAccent.withOpacity(0.4),
        title: const Text('Welcome to Aura - Your new AI Companion'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.15,
            right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
            width: mq.width * 0.5,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/images/aura_icon.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.06,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.withOpacity(0.7),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: _isLoading ? null : _handleGoogleBtnClick,
              icon: Image.asset(
                'assets/images/google.png',
                height: mq.height * 0.03,
              ),
              label: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(text: 'Sign In with '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
