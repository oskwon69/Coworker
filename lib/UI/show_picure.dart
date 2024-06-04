import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../API/globals.dart' as globals;


class PictureSelect extends StatefulWidget {
  const PictureSelect({Key? key, required this.image, required this.function}) : super(key: key);

  final Function function;
  final String image;

  @override
  State<PictureSelect> createState() => _PictureSelectState();
}

class _PictureSelectState extends State<PictureSelect> {
  String imagePath = '';

  Future getGalleryImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 600, maxWidth: 900);
    if( image != null ) {
      imagePath = image.path;
    }

    print('getGallery:$imagePath');

    setState(() {});
  }

  Future getCameraImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50, maxHeight: 600, maxWidth: 900);
    if( image != null ) {
      imagePath = image.path;
    }
    setState(() {});
  }

  void initState() {
    super.initState();
    imagePath = widget.image;
  }

  @override
  Widget build(BuildContext context)  {
    if( imagePath !='' && imagePath.contains('/') != true )  {
      imagePath = '${globals.appDirectory}/$imagePath';
    }

    return Container(
      padding: const EdgeInsets.all(30),
      height: imagePath == '' ? MediaQuery.of(context).size.height*0.40 : MediaQuery.of(context).size.height*0.60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '사진 선택',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close)
                  ),
                ),
              ],
            ),
            Divider(thickness: 1.2, color: Colors.grey.shade200,),
            Gap(12),
            Text('하자가 발생한 부위의 사진을 선택해 주세요.'),
            Gap(10),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  //width: 160,
                  //height: 90,
                    child: imagePath == '' ?
                    Row(
                      children: [
                        Icon(Icons.photo),
                        Gap(12),
                        Text('사진이 선택되지 않았습니다.'),
                      ],
                    ) :
                    Image.file(File(imagePath))
                  //CircleAvatar(backgroundImage: FileImage(File(_image!.path)),radius: 100)
                ),
              ),
            ),
            Gap(10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 3),
                    ),
                    onPressed: () async {
                      await getCameraImage();
                      Navigator.pop(context);
                      widget.function(imagePath);
                    },
                    child: Text('카메라'),
                  ),
                ),
                Gap(20),
                Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      onPressed: () async {
                        await getGalleryImage();
                        Navigator.pop(context);
                        widget.function(imagePath);
                      },
                      child: Text('앨범'),
                    ),
                )
              ],
            ),
          ]
      ),
    );
  }
}