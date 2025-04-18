import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';

import 'package:coworker/UI/show_sort.dart';
import 'package:coworker/UI/show_work.dart';
import 'package:coworker/model/user.dart';
import 'package:coworker/UI/app_style.dart';
import 'package:coworker/UI/picture_widget.dart';
import 'package:coworker/UI/show_space.dart';
import 'package:coworker/UI/show_area.dart';
import 'package:coworker/UI/textfield_widget.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';
import 'package:coworker/API/globals.dart' as globals;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AddNewDefectModel extends StatefulWidget {
  const AddNewDefectModel({Key? key, required this.user, required this.function}) : super(key: key);

  final UserInfo user;
  final Function function;

  @override
  State<AddNewDefectModel> createState() => _AddNewDefectState();
}

class _AddNewDefectState extends State<AddNewDefectModel> {
  String _uid='';
  String _did='';
  int _site_code = 0;
  String _building_no = '';
  String _house_no = '';
  String _reg_name = '';
  String _reg_phone = '';
  String _space = '';
  String _area = '';
  String _work = '';
  String _sort = '';
  String _claim = '';
  String _pic1='';
  String _pic2='';
  int _synced = 0;
  int _deleted = 0;

  var claimController = TextEditingController();
  FocusNode focusNode = FocusNode();

  final DefectDatabase _databaseService = DefectDatabase();

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _floatingText = '하자내용 음성인식 시작하기';
  double level = 0.0;

  @override
  void initState() {
    super.initState();

    _uid = widget.user.uid!;
    _did = widget.user.did!;
    _site_code = widget.user.site_code!;
    _building_no = widget.user.building_no!;
    _house_no = widget.user.house_no!;
    _reg_name = widget.user.user_name!;
    _reg_phone = widget.user.user_phone!;

    _initSpeech();
  }

  @override
  void dispose() {
    claimController.dispose();
    focusNode.dispose();

    super.dispose();
  }

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
    });
  }

  void getPic2(String str)  {
    setState(() {
      _pic2 = str;
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        localeId: 'ko_KR'
    );
    setState(() {
      _floatingText = "음성인식 중단하기";
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _floatingText = "하자내용 음성인식 시작하기";
      level = 0.0;
    });
  }

  void cancelListening() async {
    await _speechToText.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      claimController.text = _lastWords;

      _floatingText = _speechToText.isNotListening ? "하자내용 음성인식 시작하기":"음성인식 중단하기";
    });
  }

  @override
  Widget build(BuildContext context)  {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom==0.0;
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
                        '하자 입력',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    Divider(thickness: 1.2, color: Colors.grey.shade200,),
                    Gap(12),
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
                                              builder: (context) => SpaceSelect(site_code: _site_code, function: getSpaceName),
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
                                              builder: (context) => AreaSelect(site_code: _site_code, function: getAreaName),
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
                                              builder: (context) => WorkSelect(site_code: _site_code, function: getWorkName),
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
                                              builder: (context) => SortSelect(site_code: _site_code, function: getSortName),
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
                    TextFieldWidget(titleText: '내용', maxLines: 3, hintText: '신속한 A/S접수를 위해 선택하신 위치의 하자내용을 정확하게 입력해 주세요.', controller: claimController, focusNode: focusNode, readOnly: false),
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PictureWidget(titleText: '하자사진', image: _pic1, function: getPic1, readOnly: false,),
/*
                        Gap(22),
                        PictureWidget(titleText: '원경사진', image: _pic2, function: getPic2),
*/
                      ],
                    ),
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              if( _space == '' )  {
                                Fluttertoast.showToast(msg: '실명을 선택해 주세요.', gravity: ToastGravity.CENTER);
                                return;
                              }
                              if( _area == '' )  {
                                Fluttertoast.showToast(msg: '위치를 선택해 주세요.', gravity: ToastGravity.CENTER);
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
                                Fluttertoast.showToast(msg: '하자내용을 입력해 주세요.', gravity: ToastGravity.CENTER);
                                return;
                              }

                              print('globals.photo_lock='+globals.photo_lock.toString());
                              print('globals.manager_mode='+globals.manager_mode.toString());
                              if( _pic1 == '' && globals.photo_lock == true && globals.manager_mode == false )  {
                                Fluttertoast.showToast(msg: '하자 사진을 찍어 주세요.', gravity: ToastGravity.CENTER);
                                return;
                              }

                              try {
                                if( _pic1 != '' ) {
                                  String fileName = "${_building_no}_${_house_no}_${DateTime.now()}_pic1.jpg";
                                  String filePath = "${globals.appDirectory}/$fileName";
                                  print(filePath);
                                  File file = File(filePath);
                                  Uint8List imageBytes = await File(_pic1).readAsBytesSync();
                                  file.writeAsBytes(imageBytes);
                                  //await ImageGallerySaver.saveImage(imageBytes, name: fileName);
                                  _pic1 = fileName;
                                }

                                String _gentime = '${DateFormat("yyyy/MM/dd/HH/mm/ss").format(DateTime.now())}';

                                Defect defect = Defect(uid: _uid, did: _did, site: _site_code, building: _building_no, house: _house_no, reg_name: _reg_name, reg_phone: _reg_phone, space: _space, area: _area, work: _work, sort: _sort, claim: _claim, pic1: _pic1, pic2: _pic2, gentime: _gentime, synced: _synced, deleted: _deleted, sent: '미전송');
                                print(defect);

                                var result = await _databaseService.addDefect(defect);
                              } catch(e) {
                                Fluttertoast.showToast(msg: e.toString());
                                print(e.toString());
                              }

                              Navigator.pop(context);
                              widget.function();
                            },
                            child: Text('저장'),
                          ),
                        ),
                      ],
                    ),
                  ]
              ),
            ),
          ),
        ),
        floatingActionButton: showFab ?
          FloatingActionButton.extended(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green.shade700,
            splashColor: Colors.white,
            onPressed: () {
              _speechToText.isNotListening ? _startListening():_stopListening();
            },
            icon: Icon(Icons.mic),
            label: Text(_floatingText),
          ):null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}