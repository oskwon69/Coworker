import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class LayoutWidget extends StatefulWidget {
  const LayoutWidget({Key? key}) : super(key: key);

  @override
  State<LayoutWidget> createState() => _LayoutWidgetState();
}

class _LayoutWidgetState extends State<LayoutWidget> {
  static final storage = FlutterSecureStorage();
  String _imagePath ='';

  Future<int> getTypeImage() async {
    String? localInfo = '';

    localInfo = await storage.read(key:'typeImage');
    if (localInfo != null)
      _imagePath = localInfo.split(' ')[1];

    return 1;
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTypeImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true, // Set it to false
                    boundaryMargin: EdgeInsets.all(100),
                    minScale: 1,
                    maxScale: 5,
                    child: Image.file(File(_imagePath))
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 3),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('평면도 닫기'),
                  ),
                )
              ],
            ) 
          );
        }  else {
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }
}
