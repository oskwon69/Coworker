import 'dart:io';
import 'package:coworker/model/worker.dart';
import 'package:coworker/UI/picture_widget.dart';
import 'package:coworker/UI/show_defect_picture_sent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:coworker/UI/app_style.dart';
import 'package:coworker/UI/textfield_widget.dart';
import 'package:coworker/database/defect_database.dart';
import 'package:coworker/API/globals.dart' as globals;
import '../model/defect_server.dart';

class ShowWorkerDefect extends StatefulWidget {
  const ShowWorkerDefect({Key? key, required this.defect, required this.worker, required this.function }) : super(key: key);

  final DefectEx defect;
  final WorkerInfo worker;
  final Function function;

  @override
  State<ShowWorkerDefect> createState() => _ShowWorkerDefectState();
}

class _ShowWorkerDefectState extends State<ShowWorkerDefect> {
  late DefectEx _defect;
  late WorkerInfo _worker;

  String _did = '';
  int _site = 0;
  String _building = '';
  String _house = '';
  String _space = '';
  String _area = '';
  String _work = '';
  String _sort = '';
  String _claim = '';
  String _pic1 = '';

  int _work_status = 0;
  String _work_pic = '';
  String _server_work_pic = '';
  String _work_date = '';
  String _worker_name = '';
  String _worker_comment = '';
  String _owner_sign = '';

  bool isEditValid = false;
  bool isImageChanged = false;
  final supabase = Supabase.instance.client;

  FocusNode focusNode = FocusNode();
  var claimController = TextEditingController();
  var commentController = TextEditingController();
  final DefectDatabase _databaseService = DefectDatabase();
  static final storage = FlutterSecureStorage();

  void initState() {
    super.initState();

    _defect = widget.defect;
    _worker = widget.worker;

    _site = _defect.site_code;
    _building = _defect.building_no;
    _house = _defect.house_no;
    _space = _defect.space_name;
    _area = _defect.area_name;
    _work = _defect.work_name;
    _sort = _defect.sort_name;
    _claim = _defect.claim;
    _pic1 = _defect.pic1!;
    claimController.text = _claim;

    _work_status = _defect.work_status;
    _work_pic = _defect.work_pic!;
    _server_work_pic = _defect.server_work_pic!;
    _work_date = _defect.work_date!;
    _worker_name = _worker.worker_name!;
    _worker_comment = _defect.worker_comment!;
    _owner_sign = _defect.owner_sign!;
    commentController.text = _worker_comment;
  }

  @override
  void dispose() {
    claimController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  void getWorkPic(String str)  {
    setState(() {
      _work_pic = str;
    });
  }

  @override
  Widget build(BuildContext context)  {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(20),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '하자 내용',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Divider(thickness: 1.2, color: Colors.grey.shade200,),
                  Gap(10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '실명',
                                  style: AppStyle.headingOne,
                                ),
                                Gap(6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: EdgeInsets.symmetric(vertical: 13),
                                        ),
                                        onPressed: () {},
                                        child: _space == '' ? Text('실명 선택') : Text(_space),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                        ),
                        Gap(10),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '위치',
                                  style: AppStyle.headingOne,
                                ),
                                Gap(6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: EdgeInsets.symmetric(vertical: 13),
                                        ),

                                        onPressed: () {    },
                                        child: _area == '' ? Text('위치 선택') : Text(_area),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                        ),
                      ]
                  ),
                  Gap(20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '부위(공종)',
                                  style: AppStyle.headingOne,
                                ),
                                Gap(6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: EdgeInsets.symmetric(vertical: 13),
                                        ),

                                        onPressed: () { },
                                        child: _work == '' ? Text('부위 선택') : Text(_work),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                        ),
                        Gap(10),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '하자유형',
                                  style: AppStyle.headingOne,
                                ),
                                Gap(6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: EdgeInsets.symmetric(vertical: 13),
                                        ),

                                        onPressed: () { },
                                        child: _sort == '' ? Text('유형 선택') : Text(_sort),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                        ),
                      ]
                  ),
                  Gap(20),
                  TextFieldWidget(titleText: '하자내용', maxLines: 3, hintText: '', controller: claimController, focusNode: focusNode, readOnly: true),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '하자사진',
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
                                  if( _pic1 == '' ) return;

                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) => PictureView(image: _pic1),
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
                                        child: _pic1 == '' ? Icon(CupertinoIcons.photo_fill_on_rectangle_fill):
                                        Image.network(globals.serverImagePath+'/'+_pic1, width:150, height: 80),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      ),
                    ],
                  ),
                  Gap(10),
                  Divider(thickness: 1.2, color: Colors.grey.shade200,),
                  Gap(10),
                  TextFieldWidget(titleText: '작업내용', maxLines: 3, hintText: '작업내용을 입력해 주세요.', controller: commentController, focusNode: focusNode, readOnly: false),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PictureWidget(titleText: '작업완료사진', image: _work_pic, function: getWorkPic, readOnly: false,),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: RadioListTile(
                                title: Text('미처리', style: TextStyle(fontSize: 16, color: Colors.black)),
                                value: 0,
                                groupValue: _work_status,
                                onChanged: (value) {
                                  setState(() {
                                    _work_status = value!;
                                  });
                                }
                            )
                        ),
                        Expanded(
                            child: RadioListTile(
                                title: Text('완료', style: TextStyle(fontSize: 16, color: Colors.black)),
                                value: 1,
                                groupValue: _work_status,
                                onChanged: (value) {
                                  setState(() {
                                    _work_status = value!;
                                  });
                                }
                            )
                        ),
                      ]
                  ),
                  Gap(20),
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
                          onPressed: () {
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
                            side: BorderSide(color: Colors.blue.shade800),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            if( _work_pic == '' )  {
                              Fluttertoast.showToast(msg: '하자 사진을 찍어 주세요.', gravity: ToastGravity.CENTER);
                              return;
                            }

                            String filepath='';
                            String serverStorage = globals.serverImagePath.split('/').last;

                            _work_date = _work_status == 1 ? '${DateFormat("yyyy/MM/dd-HH:mm:ss").format(DateTime.now())}':'';
                            _worker_comment = commentController.text.trim();

                            try {
                              print('*********work_pic:'+_work_pic);
                              if (_work_pic != '' && _work_pic.contains('cache') ) {
                                String fileName = "work_${_site}_${_building}_${_house}_${widget.defect.id}_${DateTime.now()}.jpg";
                                String filePath = "${globals.appDirectory}/$fileName";
                                File file = File(filePath);
                                Uint8List imageBytes = await File(_work_pic).readAsBytesSync();
                                file.writeAsBytes(imageBytes);
                                _work_pic = filePath;
                                print('++++++++if work_pic:'+_work_pic);

                                filepath = 'Site${_site}/${_building}_${_house}/${_building}_${_house}_${widget.worker.worker_id}_${widget.defect.id}_w.jpg';
                                await supabase.storage.from(serverStorage).uploadBinary(filepath, imageBytes,fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
                                _server_work_pic = filepath;
                              }

                              final data = await supabase.from('defects').update({
                                'work_status': _work_status,
                                'work_pic': _work_pic,
                                'server_work_pic': _server_work_pic,
                                'work_date': _work_date,
                                'worker_name': _worker_name,
                                'worker_comment': _worker_comment,
                                'owner_sign': _owner_sign,
                              }).
                              match({
                                'uid': _defect.uid,
                                'did': _defect.did,
                                'site_code': _defect.site_code,
                                'building_no': _defect.building_no,
                                'house_no': _defect.house_no,
                                'local_id': _defect.local_id!,
                                'gentime': _defect.gentime});
                            } catch(e) {
                              Fluttertoast.showToast(msg: e.toString());
                              print(e.toString());
                            }

                            Navigator.pop(context);
                            widget.function();                          },
                          child: Text('저장하기'),
                        ),
                      ),
                    ],
                  ),
                ]
            ),
          )
        ),
      ),
    );
  }
}