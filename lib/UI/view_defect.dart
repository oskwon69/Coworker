import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:coworker/UI/app_style.dart';
import 'package:coworker/UI/picture_widget.dart';
import 'package:coworker/UI/textfield_widget.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';


class ViewDefectModel extends StatefulWidget {
  const ViewDefectModel({Key? key, required this.defect}) : super(key: key);

  final Defect defect;

  @override
  State<ViewDefectModel> createState() => _ViewDefectState();
}

class _ViewDefectState extends State<ViewDefectModel> {
  late Defect _defect;
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

  bool isImageChanged = false;
  final supabase = Supabase.instance.client;

  FocusNode focusNode = FocusNode();
  var claimController = TextEditingController();
  final DefectDatabase _databaseService = DefectDatabase();
  static final storage = FlutterSecureStorage();

  void getSpaceName(String str)  {
    setState(() {
      _space = str;
    });
  }

  void getAreaName(String str)  {
    setState(() {
      _area = str;
    });
  }

  void getWorkName(String str)  {
    setState(() {
      _work = str;
    });
  }

  void getSortName(String str)  {
    setState(() {
      _sort = str;
    });
  }

  void getPic1(String str)  {
    setState(() {
      _pic1 = str;
      isImageChanged = true;
    });
  }

  void getPic2(String str)  {
    setState(() {
      _pic2 = str;
      isImageChanged = true;
    });
  }

  void initState() {
    super.initState();

    _defect = widget.defect;
    _did = _defect.did;
    _site = _defect.site;
    _building = _defect.building;
    _house = _defect.house;
    _space = _defect.space;
    _area = _defect.area;
    _work = _defect.work;
    _sort = _defect.sort;
    _claim = _defect.claim;
    _pic1 = _defect.pic1;
    _pic2 = _defect.pic2;
    claimController.text = _claim;
  }

  @override
  void dispose() {
    claimController.dispose();
    focusNode.dispose();

    super.dispose();
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

                                            onPressed: () {
                                            },
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

                                            onPressed: () {
                                            },
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

                                            onPressed: () {
                                            },
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

                                            onPressed: () {
                                            },
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
                      TextFieldWidget(titleText: '내용', maxLines: 3, hintText: '신속한 A/S접수를 위해 선택하신 위치의 하자내용을 정확하게 입력해 주세요.', controller: claimController, focusNode: focusNode, readOnly: _defect.synced==1 ? true:false),
                      Gap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PictureWidget(titleText: '하자사진', image: _pic1, function: getPic1, readOnly: _defect.synced==1 ? true:false,),
/*
                        Gap(22),
                        PictureWidget(titleText: '원경사진', image: _pic2, function: getPic2),
*/
                        ],
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
                        ],
                      )
                    ]
                ),
              )
          ),
        ),
      ),
    );
  }
}