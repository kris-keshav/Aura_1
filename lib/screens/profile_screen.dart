import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aura/api/apis.dart';
import 'package:aura/helper/dialogs.dart';
import 'package:aura/helper/global.dart';
import 'package:aura/models/aura_user.dart';
import 'package:aura/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aura/widgets/aura_user_card.dart';


class ProfileScreen extends StatefulWidget {
  final AuraUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      await APIs.getSelfInfo();
      if (APIs.me != null) {
        setState(() {});
      }
    } catch (e) {
      // Handle any errors that occur during initialization
      print('Error initializing user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if `APIs.me` is initialized before using it
    if (APIs.me == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.withOpacity(0.7),
          title: const Text('Profile Screen'),
          titleTextStyle: TextStyle(
            color: Color(0xffE0FFFF),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context); // Close the progress bar
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (Route<dynamic> route) => false, // This clears the navigation stack
                  );
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.width * 0.03),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: mq.height * 0.2,
                        height: mq.height * 0.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child: _image != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.3),
                          child: Image.file(
                            File(_image!),
                            width: mq.height * 0.2,
                            height: mq.height * 0.2,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(Icons.person, size: mq.height * 0.1, color: Colors.grey),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: _showBottomSheet,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.width * 0.03),
                  Text(APIs.me.email, style: const TextStyle(color: Colors.black54, fontSize: 16)),
                  SizedBox(height: mq.width * 0.05),
                  TextFormField(
                    initialValue: APIs.me.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Demo User',
                      label: const Text('Name'),
                    ),
                  ),
                  SizedBox(height: mq.width * 0.05),
                  TextFormField(
                    initialValue: APIs.me.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Feeling Happy',
                      label: const Text('About'),
                    ),
                  ),
                  SizedBox(height: mq.width * 0.05),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * 0.5, mq.height * 0.06),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackBar(context, 'Profile Updated Successfully');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, size: 26),
                    label: const Text('UPDATE', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (_) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: mq.height * 0.3,
          ),
          child: ListView(
            padding: EdgeInsets.only(top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              Center(
                child: const Text(
                  'Pick Profile Picture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: mq.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/add_image.png'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/camera.png'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


