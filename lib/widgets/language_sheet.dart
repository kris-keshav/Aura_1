import 'package:aura/controller/translator_controller.dart';
import 'package:aura/helper/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSheet extends StatefulWidget {
  final TranslateController c;
  final RxString s;

  const LanguageSheet({super.key, required this.c, required this.s});

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  final _search = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04).copyWith(top: mq.height * 0.02),
      height: mq.height * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: Obx(() {
              final filteredList = _filterLanguages(widget.c.lang);
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredList.length,
                padding: EdgeInsets.only(top: mq.height * 0.02, left: 6),
                itemBuilder: (ctx, i) {
                  return _buildLanguageTile(filteredList[i]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      onChanged: (s) => _search.value = s.toLowerCase(),
      onTapOutside: (e) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.translate_rounded, color: Colors.blue),
        hintText: 'Search Language...',
        hintStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  List<String> _filterLanguages(List<String> languages) {
    if (_search.isEmpty) return languages;
    return languages.where((e) => e.toLowerCase().contains(_search.value)).toList();
  }

  Widget _buildLanguageTile(String language) {
    return InkWell(
      onTap: () {
        widget.s.value = language;
        // Instead of Get.back(), trigger a custom callback or simply use Navigator.pop()
        Navigator.pop(context, language);  // This pops the LanguageSheet, passing back the selected language
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.height * 0.02),
        child: Text(language),
      ),
    );
  }

}
