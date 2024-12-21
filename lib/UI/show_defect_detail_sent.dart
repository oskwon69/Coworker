import 'package:coworker/UI/show_defect_picture_sent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:coworker/UI/app_style.dart';
import 'package:coworker/UI/textfield_widget.dart';
import 'package:coworker/database/defect_database.dart';
import 'package:coworker/API/globals.dart' as globals;
import '../model/defect_server.dart';

class ShowServerDefect extends StatefulWidget {
  const ShowServerDefect({Key? key, required this.defect}) : super(key: key);

  final DefectEx defect;

  @override
  State<ShowServerDefect> createState() => _ShowServerDefectState();
}

class _ShowServerDefectState extends State<ShowServerDefect> {
  late DefectEx _defect;
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
  String _pic2 = '';

  bool isEditValid = false;
  bool isImageChanged = false;
  final supabase = Supabase.instance.client;

  FocusNode focusNode = FocusNode();
  var claimController = TextEditingController();
  final DefectDatabase _databaseService = DefectDatabase();
  static final storage = FlutterSecureStorage();

  void initState() {
    super.initState();

    _defect = widget.defect;
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
  }

  @override
  void dispose() {
    claimController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  void getPic1(String str)  {
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
        body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                height: MediaQuery.of(context).size.height*1.0,
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
                      Gap(20),
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
                      TextFieldWidget(titleText: '내용', maxLines: 3, hintText: '', controller: claimController, focusNode: focusNode, readOnly: true),
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
                                                Image.network("https://drmfczqtnhslrpejkqst.supabase.co/storage/v1/object/public/photos/"+_pic1, width:150, height: 80),
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
                      Gap(20),
                      Text('현재상태 : ${(widget.defect.completed==0 || globals.viewResult==0) ? '접수':'완료' }',
                        style: AppStyle.headingOne,),
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
                        ],
                      ),
                    ]
                ),
              )
          ),
        ),
      ),
    );
  }
}