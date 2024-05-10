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
  String imageString = '';
  Uint8List? imageBytes;

  void initState() {
    super.initState();
    imageString = widget.image;
    imageBytes = Base64Decoder().convert(imageString);
  }

  void getPicture(String image) {
    imageString = image;
    imageBytes = Base64Decoder().convert(image);
    widget.function(imageString);
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
                    builder: (context) => PictureSelect(image: imageString, function: getPicture),
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
                  child: SizedBox(
                      width: 150,
                      height: 80,
                      child: imageString == '' ?
                        Row(
                          children: [
                            Icon(Icons.photo),
                            Gap(12),
                            Text('카메라 / 앨범'),
                          ],
                        ) :
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(imageBytes!),
                            Positioned(
                              right: -20,
                              top: -10,
                              child:  ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                minimumSize: Size(5,5),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.grey.shade600,
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
                                                imageString = '';
                                                Navigator.pop(context);
                                                widget.function(imageString);
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
                            )
                          ],
                        )
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