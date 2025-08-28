import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../API/globals.dart' as globals;


class PictureSelect extends StatefulWidget {
  const PictureSelect({Key? key, required this.image, required this.function, required this.readOnly}) : super(key: key);

  final Function function;
  final String image;
  final bool readOnly;

  @override
  State<PictureSelect> createState() => _PictureSelectState();
}

class _PictureSelectState extends State<PictureSelect> {
  String imagePath = '';

  Future getGalleryImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxHeight: 800, maxWidth: 800);
    if( image != null ) {
      imagePath = image.path;
    }

    print('getGallery:$imagePath');

    setState(() {});
  }

  Future getCameraImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70, maxHeight: 800, maxWidth: 800);
    if( image != null ) {
      imagePath = image.path;

      String fileName = imagePath.split('/').last;
      Uint8List imageBytes = await File(imagePath).readAsBytesSync();
      await ImageGallerySaverPlus.saveImage(imageBytes, name: fileName);
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
      height: imagePath == '' ? MediaQuery.of(context).size.height*0.40 : MediaQuery.of(context).size.height*0.80,
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
                    widget.readOnly == true ? '사진 보기':'사진 선택',
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
            Text(imagePath.contains('Site') ? "작업을 완료한 사진을 촬영해 주세요.":
                 widget.readOnly == true ? '하자가 발생한 부위의 사진을 확인해 주세요.':'하자가 발생한 부위의 사진을 선택해 주세요.'),
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
                    imagePath.contains('Site') ? Image.network(globals.serverImagePath+'/'+imagePath):Image.file(File(imagePath))
                  //CircleAvatar(backgroundImage: FileImage(File(_image!.path)),radius: 100)
                ),
              ),
            ),
            Gap(10),
            widget.readOnly == true ?
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
                      Navigator.pop(context);
                    },
                    child: Text('닫기'),
                  ),
                ),
              ],
            ):
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