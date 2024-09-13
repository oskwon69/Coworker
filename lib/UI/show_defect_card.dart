import 'dart:convert';
import 'dart:io';

import 'package:coworker/UI/update_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';

import '../model/defect_server.dart';

class DefectCardWidget extends StatefulWidget {
  const DefectCardWidget({Key? key, required this.index, required this.defect}) : super(key: key);

  final int index;
  final DefectEx defect;

  @override
  State<DefectCardWidget> createState() => _DefectCardWidgetState();
}

class _DefectCardWidgetState extends State<DefectCardWidget> {
  late DefectEx _defect;
  String _imagePath = '';

  final DefectDatabase _databaseService = DefectDatabase();

  @override
  void initState() {
    super.initState();

    if( widget.defect.pic1 != '' )  {
      _imagePath = widget.defect.pic1!;
    } else if( widget.defect.pic2 != '' ) {
      _imagePath = widget.defect.pic2!;
    }
  }

  @override
  Widget build(BuildContext context) {
    _defect = widget.defect;
    String _title = '${widget.index+1}. ${widget.defect.space_name} ${widget.defect.area_name} ${widget.defect.work_name} ${widget.defect.sort_name}';

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
                color: Colors.green,
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
            },
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width/2*0.40,
                  height: MediaQuery.of(context).size.width/2*0.40*3/4,
                  decoration: BoxDecoration( borderRadius: BorderRadius.circular(8.0), color: Colors.grey.shade200),
                  child: _imagePath != '' ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network("https://drmfczqtnhslrpejkqst.supabase.co/storage/v1/object/public/photos/"+_imagePath),
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
                      Text('  전송 날짜 : ${widget.defect.sent_date!}', style: TextStyle(fontSize: 13)),
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
