import 'package:aura/controller/image_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aura/widgets/custom_btn.dart';
import 'package:aura/widgets/custom_loading.dart';
import 'package:aura/widgets/language_sheet.dart';
import 'package:aura/controller/translator_controller.dart';

class TranslatorFeature extends StatefulWidget {
  const TranslatorFeature({super.key});

  @override
  State<TranslatorFeature> createState() => _TranslatorFeatureState();
}

class _TranslatorFeatureState extends State<TranslatorFeature> {
  final _c = Get.put(TranslateController());

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.withOpacity(0.4),
        title: const Text("Multi Language Translator"),
        titleTextStyle: TextStyle(
          color: Color(0xffE0FFFF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: Colors.grey),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: mq.height * 0.02, bottom: mq.height * 0.1),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // From language
              _buildLanguageButton(_c.from, 'Auto', () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.from))),
              IconButton(
                onPressed: _c.swapLanguages,
                icon: Obx(() => Icon(CupertinoIcons.repeat, color: _c.to.isNotEmpty && _c.from.isNotEmpty ? Colors.blue : Colors.grey)),
              ),
              // To language
              _buildLanguageButton(_c.to, 'To', () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.to))),
            ],
          ),
          // Text field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: mq.height * 0.035),
            child: TextFormField(
              controller: _c.textC,
              textAlign: TextAlign.center,
              minLines: 5,
              maxLines: null,
              onTapOutside: (e) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                hintText: 'Translate anything you want...',
                hintStyle: TextStyle(fontSize: 13.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
          ),
          // Result field
          Obx(() => translateResult()),
          // For adding some space
          SizedBox(height: mq.height * 0.04),
          CustomBtn(onTap: _c.translate, text: 'Translate'),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(RxString language, String defaultText, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Obx(() => Text(language.isEmpty ? defaultText : language.value)),
      ),
    );
  }

  Widget translateResult() {
    switch (_c.status.value) {
      case Status.none:
        return const SizedBox();
      case Status.complete:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
          child: TextFormField(
            controller: _c.resultC,
            textAlign: TextAlign.center,
            maxLines: null,
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
        );
      case Status.loading:
        return const Align(child: CustomLoading());
      case Status.error:
        return const Text('Error occurred during translation.', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 16));
      default:
        return const SizedBox();
    }
  }
}
