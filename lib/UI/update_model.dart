import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coworker/UI/show_sort.dart';
import 'package:coworker/UI/show_work.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:coworker/UI/app_style.dart';
import 'package:coworker/UI/picture_widget.dart';
import 'package:coworker/UI/show_space.dart';
import 'package:coworker/UI/show_area.dart';
import 'package:coworker/UI/textfield_widget.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';
import 'package:coworker/API/globals.dart' as globals;

class UpdateDefectModel extends StatefulWidget {
  const UpdateDefectModel({Key? key, required this.defect, required this.function}) : super(key: key);

  final Defect defect;
  final Function function;

  @override
  State<UpdateDefectModel> createState() => _UpdateDefectState();
}

class _UpdateDefectState extends State<UpdateDefectModel> {
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

  bool isEditValid = false;
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

  Future<void> checkEditValid() async {
    String? localInfo = '';

    localInfo = await storage.read(key:'isEditValid');
    if (localInfo != null) {
      String value = localInfo;
      if( value == 'valid' )  {
        isEditValid = true;
      } else {
        isEditValid = true;
      }
    }
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

    print(_defect);

    checkEditValid();
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
                        '하자 수정',
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
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) => SpaceSelect(site_code: _site, function: getSpaceName),
                                            );
                                            focusNode.unfocus();
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
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) => AreaSelect(site_code: _site, function: getAreaName),
                                            );
                                            focusNode.unfocus();
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
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) => WorkSelect(site_code: _site, function: getWorkName),
                                            );
                                            focusNode.unfocus();
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
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) => SortSelect(site_code: _site, function: getSortName),
                                            );
                                            focusNode.unfocus();
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
                    TextFieldWidget(titleText: '내용', maxLines: 3, hintText: '신속한 A/S접수를 위해 선택하신 위치의 하자내용을 정확하게 입력해 주세요.', controller: claimController, focusNode: focusNode),
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PictureWidget(titleText: '하자사진', image: _pic1, function: getPic1),
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
                        Gap(20),
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
                              if( isEditValid == false )  {
                                Fluttertoast.showToast(msg: '사전점검 기간이 아닙니다.');
                                return;
                              }

                              if( _space == '' )  {
                                Fluttertoast.showToast(msg: '실명을 입력해 주세요.');
                                return;
                              }
                              if( _area == '' )  {
                                Fluttertoast.showToast(msg: '위치를 입력해 주세요.');
                                return;
                              }

                              if( _work == '' )  {
                                Fluttertoast.showToast(msg: '부위(공종)를 선택해 주세요.', gravity: ToastGravity.CENTER);
                                return;
                              }

                              if( _sort == '' )  {
                                Fluttertoast.showToast(msg: '하자유형을 선택해 주세요.', gravity: ToastGravity.CENTER);
                                return;
                              }

                              _claim = claimController.text.trim();
                              if( _claim == '' )  {
                                Fluttertoast.showToast(msg: '하자내용을 입력해 주세요.');
                                return;
                              }

                              if( _space == _defect.space && _area == _defect.area && _work == _defect.work && _sort == _defect.sort && _claim == _defect.claim && isImageChanged == false )  {
                                Fluttertoast.showToast(msg: '수정사항이 없습니다.');
                                return;
                              }

                              try {
                                if( isImageChanged )  {
                                  if( _pic1 != '' ) {
                                    String fileName = "${_building}_${_house}_${DateTime.now()}_pic1.jpg";
                                    String filePath = "${globals.appDirectory}/$fileName";
                                    File file = File(filePath);
                                    Uint8List imageBytes = await File(_pic1).readAsBytesSync();
                                    file.writeAsBytes(imageBytes);
                                    ImageGallerySaver.saveImage(imageBytes, name: fileName);
                                    _pic1 = fileName;
                                  }
                                }

                                _defect.space = _space;
                                _defect.area = _area;
                                _defect.work = _work;
                                _defect.sort = _sort;
                                _defect.claim = _claim;
                                _defect.pic1 = _pic1;
                                _defect.pic2 = _pic2;
                                _defect.sent = '미전송';
                                _defect.synced = 0;

                                var result = await _databaseService.updateDefect(_defect);
                              } catch(e) {
                                print(e.toString());
                              }
                              Navigator.pop(context);
                              widget.function();
                            },
                            child: Text('수정'),
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