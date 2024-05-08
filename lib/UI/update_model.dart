import 'dart:io';

import 'package:coworker/UI/show_sort.dart';
import 'package:coworker/UI/show_work.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gap/gap.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:coworker/UI/app_style.dart';
import 'package:coworker/UI/picture_widget.dart';
import 'package:coworker/UI/show_space.dart';
import 'package:coworker/UI/show_area.dart';
import 'package:coworker/UI/textfield_widget.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateDefectModel extends StatefulWidget {
  const UpdateDefectModel({Key? key, required this.defect, required this.function}) : super(key: key);

  final Defect defect;
  final Function function;

  @override
  State<UpdateDefectModel> createState() => _UpdateDefectState();
}

class _UpdateDefectState extends State<UpdateDefectModel> {
  late Defect _defect;
  int _site = 0;
  String _space = '';
  String _area = '';
  String _work = '';
  String _sort = '';
  String _claim = '';
  String _pic1Path = '';
  String _pic2Path = '';

  bool isEditValid = false;
  final supabase = Supabase.instance.client;

  FocusNode focusNode = FocusNode();
  var claimController = TextEditingController();
  final DefectDatabase _databaseService = DefectDatabase();

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

  void getPic1Path(String str)  {
    setState(() {
      _pic1Path = str;
    });
  }

  void getPic2Path(String str)  {
    setState(() {
      _pic2Path = str;
    });
  }

  Future<void> checkEditValid() async {
    var result = await supabase.from('site').select().eq('site_code',_site);
    if( result.isNotEmpty )  {
      DateTime startDate = DateTime.parse(result[0]['check_startdate'].toString());
      DateTime endDate = DateTime.parse(result[0]['check_enddate'].toString());
      DateTime today = DateTime.now();

      if( today.compareTo(startDate) >= 0 && today.compareTo(endDate) <= 0 )  {
        isEditValid = true;
      }
    }
  }

  void initState() {
    super.initState();

    _defect = widget.defect;
    _site = _defect.site;
    _space = _defect.space;
    _area = _defect.area;
    _work = _defect.work;
    _sort = _defect.sort;
    _claim = _defect.claim;
    _pic1Path = _defect.pic1!;
    _pic2Path = _defect.pic2!;
    claimController.text = _claim;

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
              height: MediaQuery.of(context).size.height*0.90,
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
                        PictureWidget(titleText: '근접사진', imagePath: _pic1Path, function: getPic1Path),
                        Gap(22),
                        PictureWidget(titleText: '원경사진', imagePath: _pic2Path, function: getPic2Path),
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

                              if( _space == _defect.space && _area == _defect.area && _work == _defect.work && _sort == _defect.sort && _claim == _defect.claim && _pic1Path == _defect.pic1 && _pic2Path == _defect.pic2 )  {
                                Fluttertoast.showToast(msg: '수정사항이 없습니다.');
                                return;
                              }

                              if( _pic1Path != _defect.pic1 )  {
                                if( _pic1Path != '' ) {
                                  Directory fileNewDir = await getApplicationDocumentsDirectory();
                                  String fileNewName = _pic1Path.split('/').last;
                                  String fileNewPath = fileNewDir.path+'/'+fileNewName.split('.').first+'1.'+fileNewName.split('.').last;
                                  print(fileNewPath);
                                  var result = await FlutterImageCompress.compressAndGetFile(_pic1Path, fileNewPath, quality: 50);
                                  _pic1Path = fileNewPath;
                                }
                              }

                              if( _pic2Path != _defect.pic2 )  {
                                if( _pic2Path != '' ) {
                                  Directory fileNewDir = await getApplicationDocumentsDirectory();
                                  String fileNewName = _pic2Path.split('/').last;
                                  String fileNewPath = fileNewDir.path+'/'+fileNewName.split('.').first+'2.'+fileNewName.split('.').last;
                                  var result = await FlutterImageCompress.compressAndGetFile(_pic2Path, fileNewPath, quality: 50);
                                  _pic2Path = fileNewPath;
                                }
                              }

                              _defect.space = _space;
                              _defect.area = _area;
                              _defect.work = _work;
                              _defect.sort = _sort;
                              _defect.claim = _claim;
                              _defect.pic1 = _pic1Path;
                              _defect.pic2 = _pic2Path;
                              _defect.sent = '미전송';
                              _defect.synced = 0;

                              try {
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