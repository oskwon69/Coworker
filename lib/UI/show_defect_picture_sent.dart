import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class PictureView extends StatefulWidget {
  const PictureView({Key? key, required this.image}) : super(key: key);

  final String image;

  @override
  State<PictureView> createState() => _PictureViewState();
}

class _PictureViewState extends State<PictureView> {
  String imagePath = '';

  void initState() {
    super.initState();
    imagePath = widget.image;
  }

  @override
  Widget build(BuildContext context)  {
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
                    '사진 보기',
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
                child: InteractiveViewer(
                  panEnabled: true, // Set it to false
                  boundaryMargin: EdgeInsets.all(100),
                  minScale: 1,
                  maxScale: 5,
                  child: imagePath == '' ?
                  Row(
                    children: [
                      Icon(Icons.photo),
                      Gap(12),
                      Text('사진이 선택되지 않았습니다.'),
                    ],
                  ) :
                  Image.network("https://drmfczqtnhslrpejkqst.supabase.co/storage/v1/object/public/photos/"+imagePath, width: 400, height: 300,),
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
                      Navigator.pop(context);
                    },
                    child: Text('닫기'),
                  ),
                ),
              ],
            ),
          ]
      ),
    );
  }
}