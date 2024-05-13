import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/defect_database.dart';
import '../model/defect.dart';
import '../model/user.dart';

class SendData extends StatefulWidget {
  const SendData({Key? key, required this.user , required this.function}) : super(key: key);

  final UserInfo user;
  final Function function;

  @override
  State<SendData> createState() => _SendDataState();
}

class _SendDataState extends State<SendData> {
  List<Defect> defectList = [];
  List<Defect> defectSendList = [];
  List<Defect> defectDeledtedList = [];

  int _total = 0;
  int _notSynced = 0;
  int _sent = 0;
  double percent = 0;
  String _buttonText = '전송';

  bool _sending = false;
  bool _done = false;
  bool _break = false;

  final DefectDatabase _databaseService = DefectDatabase();
  final supabase = Supabase.instance.client;
  late StreamSubscription<List<ConnectivityResult>> subscriptionComm;
  bool isMobile = false;
  bool isWifi = false;
  bool isEthernet = false;

  Future<void> getDefects() async {
    final defects = await _databaseService.getAllDefects(widget.user.uid!, widget.user.site_code!, widget.user.building_no!, widget.user.house_no!);
    if ( defectList.isNotEmpty ) {
      defectList.clear();
    }

    defectList.addAll(defects);

    setState(() {
      _total = defectList.length;
      defectSendList = defectList.where((item) => item.synced == 0).toList();
      _notSynced = defectSendList.length;
    });
  }

  Future<void> getDeletedDefects() async {
    final defects = await _databaseService.getAllDelDefects(widget.user.uid!, widget.user.site_code!, widget.user.building_no!, widget.user.house_no!);
    if ( defectDeledtedList.isNotEmpty ) {
      defectDeledtedList.clear();
    }

    defectDeledtedList.addAll(defects);
  }

  Stream<int> sendDefects() async* {
    String sent_date = '${DateFormat("yyyy/MM/dd").format(DateTime.now())}';

    // 우선 삭제된 항목을 서버DB와 동기화한다.
    for(int i=0 ; i < defectDeledtedList.length ; i++) {
      if( _break == true ) break;
      try {
        await supabase.rpc("defect_upsert", params: {
          "local_id_arg": defectDeledtedList[i].id,
          'uid_arg': defectDeledtedList[i].uid,
          'did_arg': defectDeledtedList[i].did,
          'site_code_arg': defectDeledtedList[i].site,
          'building_no_arg': defectDeledtedList[i].building,
          'house_no_arg': defectDeledtedList[i].house,
          'reg_name_arg': defectDeledtedList[i].reg_name,
          'reg_phone_arg': defectDeledtedList[i].reg_phone,
          'space_name_arg': defectDeledtedList[i].space,
          'area_name_arg': defectDeledtedList[i].area,
          'work_name_arg': defectDeledtedList[i].work,
          'sort_name_arg': defectDeledtedList[i].sort,
          'claim_arg': defectDeledtedList[i].claim,
          'pic1_arg': '',
          'pic2_arg': '',
          'deleted_arg': defectDeledtedList[i].deleted,
          'sent_date_arg': sent_date,
        });
      } catch (e) {
        print(e.toString());
        break;
      }
    }

    print('alive');
    // 아직 보내지 않았거나 수정된 항목을 서버DB와 동기화한다.
    for(int i=0 ; i < defectSendList.length ; i++) {
      String filepath1 = '';
      String filepath2 = '';

      if( _break == true ) break;

      try {
        if( defectSendList[i].pic1 != '' ) {
          Uint8List bytes = Base64Decoder().convert(defectSendList[i].pic1);
          filepath1 = 'Site${defectSendList[i].site}/${defectSendList[i].uid}/${defectSendList[i].building}_${defectSendList[i].house}_${defectSendList[i].did}_${defectSendList[i].id}_1.jpg';
          await supabase.storage.from('photos').uploadBinary(
              filepath1, bytes, fileOptions: const FileOptions(
              cacheControl: '3600', upsert: true));
        }

        if( defectSendList[i].pic2 != '' ) {
          Uint8List bytes = Base64Decoder().convert(defectSendList[i].pic2);
          filepath2 = 'Site${defectSendList[i].site}/${defectSendList[i].uid}/${defectSendList[i].building}_${defectSendList[i].house}_${defectSendList[i].did}_${defectSendList[i].id}_2.jpg';
          await supabase.storage.from('photos').uploadBinary(
              filepath2, bytes, fileOptions: const FileOptions(
              cacheControl: '3600', upsert: true));
        }

        await supabase.rpc("defect_upsert", params: {
          "local_id_arg": defectSendList[i].id,
          'uid_arg': defectSendList[i].uid,
          'did_arg': defectSendList[i].did,
          'site_code_arg': defectSendList[i].site,
          'building_no_arg': defectSendList[i].building,
          'house_no_arg': defectSendList[i].house,
          'reg_name_arg': defectSendList[i].reg_name,
          'reg_phone_arg': defectSendList[i].reg_phone,
          'space_name_arg': defectSendList[i].space,
          'area_name_arg': defectSendList[i].area,
          'work_name_arg': defectSendList[i].work,
          'sort_name_arg': defectSendList[i].sort,
          'claim_arg': defectSendList[i].claim,
          'pic1_arg': filepath1,
          'pic2_arg': filepath2,
          'deleted_arg': defectSendList[i].deleted,
          'sent_date_arg': sent_date,
        });

        Defect defect = defectSendList[i];
        defect.synced = 1;
        defect.sent = sent_date;
        await _databaseService.updateDefect(defect);
      } catch(e)  {
        print(e.toString());
        break;
      }

      setState(() {
        _sent++;
        percent = _sent.toDouble()/_notSynced.toDouble();
      });

      yield _sent;
    }
  }

  Future<bool> checkCurrentCommState() async {
    if( isMobile == false && isWifi == false && isEthernet == false )  {
      await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: Text('알림'),
              content: Text('인터넷이 연결되어 있지 않습니다. wifi 또는 모바일 데이터통신 연결 확인바랍니다.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
      );
      return false;
    } else
      return true;
  }

  @override
  void initState() {
    super.initState();

    subscriptionComm = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      isMobile = false;
      isWifi = false;
      isEthernet = false;
      if (result.contains(ConnectivityResult.mobile)) {
        isMobile = true;
      } else if (result.contains(ConnectivityResult.wifi)) {
        isWifi = true;
      } else if (result.contains(ConnectivityResult.ethernet)) {
        isEthernet = true;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getDefects();
      await getDeletedDefects();
    });
  }

  @override
  void dispose() {
    subscriptionComm.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context)  {
    return Container(
      padding: const EdgeInsets.all(30),
      height: MediaQuery.of(context).size.height*0.60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                '하자 내역 전송',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Divider(thickness: 1.2, color: Colors.grey.shade200,),
            Gap(12),
            Text('저장하신 하자 내역을 시공사 서버로 전송하겠습니다.'),
            Gap(20),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('동호수', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                        Gap(10),
                        Text('총 하자 건수', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                        Gap(10),
                        Text('미전송 건수', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                        Gap(10),
                        Text('전송완료 건수', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    )
                ),
                Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(': ${widget.user.building_no}동 ${widget.user.house_no}호', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                        Gap(10),
                        Text(': $_total 건', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                        Gap(10),
                        Text(': ${_notSynced-_sent} 건', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                        Gap(10),
                        Text(': $_sent 건', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    )
                ),
              ],
            ),
            Gap(20),
            LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey.shade300,
              color: Colors.black45,
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 10.0,
              semanticsLabel: 'semanticsLabel',
              semanticsValue: 'semanticsValue',
            ),
            Gap(30),
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
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.function();
                      },
                      child: Text('닫기'),
                    )
                ),
                Gap(10),
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
                      var commStatus = await checkCurrentCommState();
                      if(  commStatus == false ) return;

                      if( _sending == false ) {   // 전송할때
                        if( _done == true )  {
                          Fluttertoast.showToast(msg: '전송할 하자가 없습니다.', gravity: ToastGravity.CENTER);
                          return;
                        }

                        if( _notSynced == 0 )  {
                          Fluttertoast.showToast(msg: '전송할 하자가 없습니다.', gravity: ToastGravity.CENTER);
                          return;
                        }

                        Fluttertoast.showToast(msg: '전송이 시작되었습니다.', gravity: ToastGravity.CENTER);
                        setState(() {
                          _sent = 0;
                          _sending = true;
                          _done = false;
                          _break = false;
                          _buttonText = '전송중 ...';
                        });
                        sendDefects().listen((event) {
                          if( _sent >= _notSynced )  {   // 완료될때
                            _sending = false;
                            _done = true;
                            _break = true;
                            _buttonText = '전송 완료';

                            Fluttertoast.showToast(msg: '전송이 완료되었습니다.', gravity: ToastGravity.CENTER);
                          };
                        });
                      }  else {   // 중단할때
                        Fluttertoast.showToast(msg: '전송이 중단되었습니다.', gravity: ToastGravity.CENTER);

                        setState(() {
                          _sending = false;
                          _done = true;
                          _break = true;
                        });
                      }

                      widget.function();
                    },
                    child: Text(_buttonText),
                  ),
                )
              ],
            ),
          ]
      ),
    );

  }
}