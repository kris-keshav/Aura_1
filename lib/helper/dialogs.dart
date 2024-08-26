import 'package:aura/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs{
//   info
  static void info(String msg){
    Get.snackbar('Info', msg, backgroundColor: Colors.blue.withOpacity(0.7), colorText: Colors.white);
  }

//   success
  static void success(String msg){
    Get.snackbar('Info', msg, backgroundColor: Colors.blue.withOpacity(0.7), colorText: Colors.white);
  }

//   error
  static void error(String msg){
    Get.snackbar('Info', msg, backgroundColor: Colors.blue.withOpacity(0.7), colorText: Colors.white);
  }

//   loading
  static void showLoadingDialog() {
    Get.dialog(const Center(child: CustomLoading(),));
  }

  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(0.8),
      behavior: SnackBarBehavior.floating,
    ));
  }
  static void showProgressBar(BuildContext context){
    showDialog(context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
