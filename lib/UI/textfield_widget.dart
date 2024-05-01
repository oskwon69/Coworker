import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'app_style.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget(
      {Key? key, required this.titleText, required this.hintText, required this.maxLines, required this.controller, required this.focusNode})
      : super(key: key);

  final String titleText;
  final String hintText;
  final int maxLines;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: AppStyle.headingOne,
          ),
          Gap(6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
              ),
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }
}