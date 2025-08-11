import 'dart:convert';
import 'dart:io';
import 'package:coworker/UI/show_picure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

import 'app_style.dart';
import '../API/globals.dart' as globals;


class PictureWidget extends StatefulWidget {
  const PictureWidget({Key? key, required this.titleText, required this.image, required this.function, required this.readOnly }) : super(key: key);

  final String titleText;
  final String image;
  final Function function;
  final bool readOnly;

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

    if( imagePath !='' && imagePath.contains('/') != true )  {
      imagePath = '${globals.appDirectory}/$imagePath';
    }

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
                  if( imagePath == '' && widget.readOnly == true ) return;

                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => PictureSelect(image: imagePath, function: getPicture, readOnly: widget.readOnly),
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
                          width: 250,
                          height: 80,
                          child: imagePath == '' ?
                          Row(
                            children: [
                              Gap(10),
                              Icon(Icons.photo),
                              Gap(10),
                              Text(widget.readOnly==true ? '촬영된 사진이 없습니다':'카메라 또는 앨범 에서 사진 선택'),
                            ],
                          ) :
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              imagePath.contains('Site') ? Image.network(globals.serverImagePath+'/'+imagePath) :Image.file(File(imagePath), width:150, height: 80),
                              Positioned(
                                top: -10,
                                right: 10,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(5,5),
                                      backgroundColor: Colors.grey.shade200,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: CircleBorder(),
                                    ),
                                    onPressed: () {
                                      if( widget.readOnly == true )  return;

                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('사진을 삭제하시겠습니까?', style: TextStyle(fontSize: 15)),
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
                                    child: widget.readOnly == true ? null:Icon(CupertinoIcons.delete),
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