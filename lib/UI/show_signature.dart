import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../API/globals.dart' as globals;


class SignatureDraw extends StatefulWidget {
  const SignatureDraw({Key? key, required this.image, required this.function, required this.readOnly}) : super(key: key);

  final String image;
  final Function function;
  final bool readOnly;

  @override
  State<SignatureDraw> createState() => _SignatureDrawState();
}

class _SignatureDrawState extends State<SignatureDraw> {
  String imagePath = '';
  late bool _readOnly;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  void initState() {
    super.initState();

    imagePath = widget.image;
    _readOnly = widget.readOnly;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    double _width = MediaQuery.of(context).size.width*0.80;
    double _height = MediaQuery.of(context).size.width*0.50;

    return Container(
      padding: const EdgeInsets.all(30),
      height: MediaQuery.of(context).size.height*0.50,
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
                    _readOnly == true ? '서명 보기':'서명 입력',
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
            Text(_readOnly == true ? '입주자 확인 서명을 확인하세요.':'입주자 확인 서명을 입력해 주세요.'),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Signature(controller: _controller,width: _width, height: _height,backgroundColor: Colors.white,),
                      ],
                    ) :
                    imagePath.contains('sign') ? Image.network(globals.serverImagePath+'/'+imagePath):Image.file(File(imagePath))
                ),
              ),
            ),
            Gap(10),
            _readOnly == true ?
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.blue.shade800),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text('닫기'),
                  ),
                ),
                Gap(10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      setState(() {
                        imagePath = '';
                        _controller.clear();
                        _readOnly = false;
                      });
                    },
                    child: Text('다시서명하기'),
                  ),
                ),
              ],
            ):
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.blue.shade800),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      _controller.clear();
                      imagePath = '';
                      widget.function(imagePath);
                    },
                    child: Text('지우기'),
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
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      try {
                        final directory = await getApplicationCacheDirectory();
                        imagePath = '${directory.path}/sg-'+DateFormat("yyyy-MM-dd-HH:mm:ss").format(DateTime.now())+'.png';

                        final Uint8List? imageBytes = await _controller.toPngBytes(width: _width.round(), height: _height.round());
                        final file = File(imagePath);
                        await file.writeAsBytes(imageBytes!);
                      }catch (e)  {
                        print(e.toString());
                        imagePath = '';
                      }

                      Navigator.pop(context);
                      widget.function(imagePath);
                    },
                    child: Text('저장하기'),
                  ),
                )
              ],
            ),
          ]
      ),
    );
  }
}