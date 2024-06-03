import 'dart:convert';
import 'dart:io';
import 'package:coworker/UI/show_picure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import 'app_style.dart';

class PictureWidget extends StatefulWidget {
  const PictureWidget({Key? key, required this.titleText, required this.image, required this.function }) : super(key: key);

  final String titleText;
  final String image;
  final Function function;

  @override
  State<PictureWidget> createState() => _PictureWidgetState();
}

class _PictureWidgetState extends State<PictureWidget> {
  String imagePath = '';

  void initState() {
    super.initState();
    imagePath = widget.image;
  }

  void getPicture(String image) {
    imagePath = image;
    widget.function(imagePath);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.titleText;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: AppStyle.headingOne,
          ),
          Gap(6),
          Material(
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => PictureSelect(image: imagePath, function: getPicture),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 150,
                          height: 80,
                          child: imagePath == '' ?
                          Row(
                            children: [
                              Gap(10),
                              Icon(Icons.photo),
                              Gap(12),
                              Text('카메라 / 앨범'),
                            ],
                          ) :
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(File(imagePath), width:150, height: 80),
                              //Text(File(imagePath).lengthSync().toString()),
                              Positioned(
                                top: -10,
                                right: -25,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(5,5),
                                      backgroundColor: Colors.grey.shade200,
                                      foregroundColor: Colors.grey.shade800,
                                      elevation: 0,
                                      shape: CircleBorder(),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('하자 사진을 삭제하시겠습니까?', style: TextStyle(fontSize: 15)),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("취소", style: TextStyle(fontSize: 15))
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      imagePath = '';
                                                      Navigator.pop(context);
                                                      widget.function(imagePath);
                                                    },
                                                    child: Text("삭제", style: TextStyle(fontSize: 15))
                                                ),
                                              ],
                                            );
                                          }
                                      );
                                    },
                                    child: Icon(CupertinoIcons.delete),
                                  ),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}