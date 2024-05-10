import 'dart:convert';
import 'dart:io';

import 'package:coworker/UI/update_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';

class CardDefectListWidget extends StatefulWidget {
  const CardDefectListWidget({Key? key, required this.defect, required this.function}) : super(key: key);

  final Defect defect;
  final Function function;

  @override
  State<CardDefectListWidget> createState() => _CardDefectListWidgetState();
}

class _CardDefectListWidgetState extends State<CardDefectListWidget> {
  late Defect _defect;
  String _imageString = '';
  Uint8List? imageBytes;

  final DefectDatabase _databaseService = DefectDatabase();

  returnUpdate() {
    setState(() {
      widget.function();
    });
  }

  @override
  void initState() {
    super.initState();

    if( widget.defect.pic1 != '' )  {
      _imageString = widget.defect.pic1;
    } else if( widget.defect.pic2 != '' ) {
      _imageString = widget.defect.pic2;
    }

    imageBytes = Base64Decoder().convert(_imageString);
  }

  @override
  Widget build(BuildContext context) {
    _defect = widget.defect;
    String _title = '${widget.defect.space} ${widget.defect.area} ${widget.defect.work} ${widget.defect.sort}';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: _defect.synced != 1 ? Colors.red : Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                )
            ),
            width: 10,
          ),
          Gap(10),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => UpdateDefectModel(defect: _defect, function: returnUpdate),
              );
            },
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width/2*0.40,
                  height: MediaQuery.of(context).size.width/2*0.40*3/4,
                  decoration: BoxDecoration( borderRadius: BorderRadius.circular(8.0), color: Colors.grey.shade200),
                  child: _imageString != '' ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(imageBytes!)
                    ) :
                    Center(child: Icon(CupertinoIcons.photo_fill_on_rectangle_fill)),
                ),
                Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                      width: MediaQuery.of(context).size.width*0.6,
                      color: Colors.white,
                      child:      Text(_title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis,),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                      width: MediaQuery.of(context).size.width*0.6,
                      color: Colors.white,
                      child:  Text(widget.defect.claim, style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,),

                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      width: MediaQuery.of(context).size.width*0.6,
                      child: Divider(thickness: 1.5, color: Colors.grey.shade300,),
                    ),
//                    Divider(thickness: 1.5, color: Colors.black, indent: 15, endIndent: 15,),
                    Text('  전송 날짜 : ${widget.defect.sent!}', style: TextStyle(fontSize: 13)),
                  ]
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
