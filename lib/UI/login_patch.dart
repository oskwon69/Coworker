import 'dart:async';
import 'dart:io';
import 'package:coworker/UI/dropdown_widget.dart';
import 'package:coworker/UI/requset_page.dart';
import 'package:coworker/UI/show_agreement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_id/android_id.dart';

import '../database/defect_database.dart';
import '../database/env_database.dart';
import '../model/env.dart';
import '../model/user.dart';
import 'app_style.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<SiteWidgetState> _siteKey = GlobalKey<SiteWidgetState>();
  final GlobalKey<BuildingWidgetState> _buildingKey = GlobalKey<BuildingWidgetState>();
  final GlobalKey<HouseWidgetState> _houseKey = GlobalKey<HouseWidgetState>();

  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var dateController = TextEditingController();

  String _uid = '';
  String? _did;
  int _site_code = 999;
  String _site_name = '단지 선택';
  String _building_no = '동 선택';
  String _house_no = '호 선택';
  String _owner_name = '';
  String _owner_phone = '';
  String _birth_date = '';
  String _type = '';

  final supabase = Supabase.instance.client;
  final EnvDatabase _envdatabase = EnvDatabase();
  final DefectDatabase _databaseService = DefectDatabase();

  static final storage = FlutterSecureStorage();
  late StreamSubscription<List<ConnectivityResult>> subscriptionComm;
  bool isMobile = false;
  bool isWifi = false;
  bool isEthernet = false;
  late UserInfo _user;

  Future<String?> getDeviceUniqueId() async {
    String? uniqueDeviceId;

    if (Platform.isIOS) {
      var deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      uniqueDeviceId = iosDeviceInfo.identifierForVendor!;
    } else if(Platform.isAndroid) {
      const androidId = AndroidId();
      uniqueDeviceId = await androidId.getId();
      print(uniqueDeviceId);
    }

    return uniqueDeviceId;
  }

  copyLocalDatabase(ProgressDialog pd) async {
    List<dynamic> dataList = [];

    await _envdatabase.deleteAllSpace();
    await _envdatabase.deleteAllArea();
    await _envdatabase.deleteAllWork();
    await _envdatabase.deleteAllSort();

    var spaces = await supabase.from('space').select().match({'site_code': _site_code});
    if (spaces.isNotEmpty) {
      dataList = spaces.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addSpace(Space.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    print('space info ok!');
    pd.update(value:50);

    var areas = await supabase.from('area').select().match({'site_code': _site_code});
    if (areas.isNotEmpty) {
      dataList = areas.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addArea(Area.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    print('area info ok!');
    pd.update(value:60);

    var works = await supabase.from('work').select().match({'site_code': _site_code});
    if (works.isNotEmpty) {
      dataList = works.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addWork(Work.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    print('work info ok!');
    pd.update(value:70);

    var sorts = await supabase.from('sort').select().match({'site_code': _site_code});
    if (sorts.isNotEmpty) {
      dataList = sorts.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addSort(Sort.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    print('sort info ok!');
    pd.update(value:80);

    try {
      String remoteDir = '';
      String fileName = _type + ".jpg";
      var result = await supabase.from('site').select().eq('site_code',_site_code);
      if( result.isNotEmpty )  {
        remoteDir = result[0]['image_folder'].toString();
      }  else return;

      String _url = remoteDir + "/" + fileName;
      final http.Response response = await http.get(Uri.parse(_url));
      Directory fileDir = await getApplicationDocumentsDirectory();
      String filePath = fileDir.path + '/' + fileName;
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await storage.write(key: "typeImage", value: "path " + filePath + " " + "type " + _type);
      pd.update(value: 90);

      _did = await getDeviceUniqueId();

      result = await supabase.from('site').select().eq('site_code',_site_code);
      if( result.isNotEmpty )  {
        DateTime startDate = DateTime.parse(result[0]['check_startdate'].toString());
        DateTime endDate = DateTime.parse(result[0]['check_enddate'].toString());
        DateTime today = DateTime.now();

        if( today.compareTo(startDate) >= 0 && today.compareTo(endDate) <= 0 )  {
          await storage.write(key: "isEditValid", value: "valid");
        }  else {
          await storage.write(key: "isEditValid", value: "invalid");
        }
      }

      pd.update(value: 100);
    } catch(e)  {
      print(e.toString());
    }
  }

  Future<void> defaultSite() async {
    var result = await supabase.from('site').select().eq('status',1);
    if( result.isNotEmpty )  {
      _site_code = int.parse(result[0]['site_code'].toString());
      _site_name = result[0]['site_name'].toString();
      _building_no = '동 선택';
      _siteKey.currentState?.refreshList(_site_code);
      await _buildingKey.currentState?.refreshList(_site_code);
      await _houseKey.currentState?.refreshList(_site_code, _building_no);
    }  else return;

    setState(() { });
  }

  changeSite(int site, String name) async {
    _site_code = site;
    _site_name = name;
    _building_no = '동 선택';
    await _buildingKey.currentState?.refreshList(_site_code);
    await _houseKey.currentState?.refreshList(_site_code, _building_no);
    setState(() { });
  }

  changeBuilding(String building) async {
    _building_no = building;
    await _houseKey.currentState?.refreshList(_site_code, _building_no);
    setState(() { });
  }

  changeHouse(String house) {
    _house_no = house;
    setState(() { });
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
/*
      WidgetsBinding.instance.addPostFrameCallback((_) {
        defaultSite();
        checkInitCommState();
      });

      nameController.text = '홍길동';
      phoneController.text = '010-1234-5678';
      dateController.text = '01.01.01';
*/
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    subscriptionComm.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child:
              Form(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(30),
                      Container(
                        alignment: Alignment.center,
                        child: Text('Coworker', style: TextStyle(fontSize: 60, color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                      SiteWidget(key: _siteKey, function: changeSite),
                      Gap(10),
                      Row(
                        children: [
                          BuildingWidget(key: _buildingKey, function: changeBuilding),
                          Gap(10),
                          HouseWidget(key: _houseKey, function: changeHouse),
                        ],
                      ),
                      Gap(10),
                      Text('이름', style: AppStyle.headingOne,),
                      Gap(6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: nameController,
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '이름을 입력해 주세요.',

                            ),
                            textInputAction: TextInputAction.next
                        ),
                      ),
                      Gap(10),
                      Text('전화번호', style: AppStyle.headingOne,),
                      Gap(6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: phoneController,
                            inputFormatters: [
                              MultiMaskedTextInputFormatter(
                                  masks: ['xxx-xxxx-xxxx', 'xxx-xxx-xxxx'],
                                  separator: '-'),
                            ],
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '휴대전화번호를 입력해 주세요.',

                            ),
                            textInputAction: TextInputAction.next
                        ),
                      ),
                      Gap(10),
                      Text('생년월일', style: AppStyle.headingOne,),
                      Gap(6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: dateController,
                            inputFormatters: [
                              MultiMaskedTextInputFormatter(
                                  masks: ['xx.xx.xx'], separator: '.'),
                            ],
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '생년월일(6자리)을 입력해 주세요.',

                            ),
                            textInputAction: TextInputAction.done
                        ),
                      ),
                      Gap(30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8)),
                                side: BorderSide(
                                    color: Colors.blue.shade800),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              onPressed: () async {
                                var commStatus = await checkCurrentCommState();
                                if(  commStatus == false ) return;

                                if( _site_code >= 999 )  {
                                  Fluttertoast.showToast(msg: '단지를 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( _building_no == "동 선택" )  {
                                  Fluttertoast.showToast(msg: '동을 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( _house_no == "호 선택" )  {
                                  Fluttertoast.showToast(msg: '호를 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                if( nameController.text == '' )  {
                                  Fluttertoast.showToast(msg: '이름을 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                if( phoneController.text == '' )  {
                                  Fluttertoast.showToast(msg: '휴대전화번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                if( phoneController.text.trim().length < 12 || phoneController.text.trim().length > 13 ) {
                                  Fluttertoast.showToast(msg: '유효한 휴대전화 번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                if( dateController.text == '' )  {
                                  Fluttertoast.showToast(msg: '생년월일(6자리)를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                if( dateController.text.trim().length != 8 ) {
                                  Fluttertoast.showToast(msg: '유효한 생년월일(YY.MM.DD)을 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                try {
                                  _owner_name = nameController.text.trim();
                                  _owner_phone = phoneController.text;
                                  _birth_date = dateController.text.replaceAll('.', '');

                                  List<Map<String, dynamic>> result = await supabase.from('owner').select().match({
                                    'site_code': _site_code,
                                    'building_no': _building_no,
                                    'house_no': _house_no,
                                    'owner_name': _owner_name,
                                    'owner_phone': _owner_phone,
                                    'birth_date': _birth_date});
                                  if (result.isNotEmpty) {
                                    _type = result[0]['type'].toString();
                                  } else {
                                    Fluttertoast.showToast(msg: '입력하신 정보로 등록된 세대가 없습니다.', gravity: ToastGravity.CENTER);
                                    return;
                                  }

/*
                                  List<Map<String, dynamic>> result = await supabase.from('owner').select().match({
                                    'site_code': _site_code,
                                    'building_no': _building_no,
                                    'house_no': _house_no});
                                  if (result.isNotEmpty) {
                                    _type = result[0]['type'].toString();
                                  } else {
                                    Fluttertoast.showToast(msg: '입력하신 정보로 등록된 세대가 없습니다.', gravity: ToastGravity.CENTER);
                                    return;
                                  }
                                  _owner_name = result[0]['owner_name'].toString();
                                  _owner_phone = result[0]['owner_phone'].toString();
                                  _birth_date = result[0]['birth_date'].toString();
*/

                                  ProgressDialog pd = ProgressDialog(context: context);
                                  pd.show(max: 100, msg: '데이터 다운로드 중 ...');

                                  result = await supabase.from('users').select().match({
                                    'user_name': _owner_name,
                                    'phone_number': _owner_phone,
                                    'birth_date': _birth_date});
                                  if (result.isNotEmpty) {
                                    await supabase.from('users').update({
                                      'last_login': '${DateFormat("yy-MM-dd hh:mm a").format(DateTime.now())}'
                                    }).match({
                                      'user_name': _owner_name,
                                      'phone_number': _owner_phone,
                                      'birth_date': _birth_date});
                                  } else {
                                    result =  await supabase.from('users').insert({
                                      'user_name': _owner_name,
                                      'phone_number': _owner_phone,
                                      'birth_date': _birth_date,
                                      'last_login': '${DateFormat("yy-MM-dd hh:mm a").format(DateTime.now())}'}).select();
                                  }
                                  _uid = result[0]['id'];
                                  pd.update(value: 30);

                                  await copyLocalDatabase(pd);
                                  print('Establish Local DB');

                                  pd.update(value: 100);
                                  pd.close();

                                  _user = UserInfo(uid: _uid, did: _did, site_code: _site_code, site_name: _site_name, building_no: _building_no, house_no: _house_no, user_name: _owner_name, birth_date: _birth_date, user_phone: _owner_phone, type: _type);
                                  print(_user);

                                  result = await supabase.from('users').select().eq('id', _user.uid!);
                                  if( result.isNotEmpty )  {
                                    if( result[0]['terms_agree'] == 0 )  {  // 아직 동의하지 않음.
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => AgreementPage(user: _user)));
                                    }  else {  // 이미 동의함.
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RequestPage(user: _user)));
                                    }
                                  } else { // 유저DB에 자료가 없다는 것은 이상함.
                                    Fluttertoast.showToast(msg: 'DB 오류 : 고객센터 문의바랍니다.', gravity: ToastGravity.CENTER);
                                  }
                                } catch(e) {
                                  Fluttertoast.showToast(msg: e.toString());
                                  print(e.toString());
                                }
                              },
                              child: Text('로그인'),
                            ),
                          ),
                        ],
                      ),
                      Gap(10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8)),
                                side: BorderSide(
                                    color: Colors.blue.shade800),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              onPressed: () async {
                                var commStatus = await checkCurrentCommState();
                                if(  commStatus == false ) return;

                                if( _site_code >= 999 )  {
                                  Fluttertoast.showToast(msg: '단지를 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( _building_no == "동 선택" )  {
                                  Fluttertoast.showToast(msg: '동을 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( _house_no == "호 선택" )  {
                                  Fluttertoast.showToast(msg: '호를 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( nameController.text == '' )  {
                                  Fluttertoast.showToast(msg: '이름을 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( phoneController.text == '' )  {
                                  Fluttertoast.showToast(msg: '휴대전화번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( phoneController.text.trim().length < 12 || phoneController.text.trim().length > 13 ) {
                                  Fluttertoast.showToast(msg: '유효한 휴대전화 번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( dateController.text == '' )  {
                                  Fluttertoast.showToast(msg: '생년월일(6자리)를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                if( dateController.text.trim().length != 8 ) {
                                  Fluttertoast.showToast(msg: '유효한 생년월일(YY.MM.DD)을 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                try {
                                  _owner_name = nameController.text.trim();
                                  _owner_phone = phoneController.text;
                                  _birth_date =
                                      dateController.text.replaceAll('.', '');

                                  List<Map<String,
                                      dynamic>> result = await supabase.from(
                                      'owner').select().match({
                                    'site_code': _site_code,
                                    'building_no': _building_no,
                                    'house_no': _house_no,
                                    'owner_name': _owner_name,
                                    'owner_phone': _owner_phone,
                                    'birth_date': _birth_date});
                                  if (result.isNotEmpty) {
                                    _type = result[0]['type'].toString();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: '입력하신 정보로 등록된 세대가 없습니다.',
                                        gravity: ToastGravity.CENTER);
                                    return;
                                  }

                                  result =
                                  await supabase.from('users').select().match({
                                    'user_name': _owner_name,
                                    'phone_number': _owner_phone,
                                    'birth_date': _birth_date});
                                  if (result.isNotEmpty) {
                                    await supabase.from('users').update({
                                      'last_login': '${DateFormat(
                                          "yy-MM-dd hh:mm a").format(
                                          DateTime.now())}'
                                    }).match({
                                      'user_name': _owner_name,
                                      'phone_number': _owner_phone,
                                      'birth_date': _birth_date});
                                  } else {
                                    result =
                                    await supabase.from('users').insert({
                                      'user_name': _owner_name,
                                      'phone_number': _owner_phone,
                                      'birth_date': _birth_date,
                                      'last_login': '${DateFormat(
                                          "yy-MM-dd hh:mm a").format(
                                          DateTime.now())}'}).select();
                                  }
                                  _uid = result[0]['id'];

                                  await _databaseService.deletePic2(_uid);
                                  Fluttertoast.showToast(msg: '원경사진 삭제가 완료되었습니다.', gravity: ToastGravity.CENTER);

                                } catch(e) {
                                  print(e.toString());
                                }
                              },
                              child: Text('원경 사진지우기'),
                            ),
                          ),
                        ],
                      ),
                      Gap(10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8)),
                                side: BorderSide(
                                    color: Colors.blue.shade800),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              onPressed: () async {
                                var commStatus = await checkCurrentCommState();
                                if(  commStatus == false ) return;

                                if( _site_code >= 999 )  {
                                  Fluttertoast.showToast(msg: '단지를 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( _building_no == "동 선택" )  {
                                  Fluttertoast.showToast(msg: '동을 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( _house_no == "호 선택" )  {
                                  Fluttertoast.showToast(msg: '호를 선택해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( nameController.text == '' )  {
                                  Fluttertoast.showToast(msg: '이름을 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( phoneController.text == '' )  {
                                  Fluttertoast.showToast(msg: '휴대전화번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( phoneController.text.trim().length < 12 || phoneController.text.trim().length > 13 ) {
                                  Fluttertoast.showToast(msg: '유효한 휴대전화 번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }
                                if( dateController.text == '' )  {
                                  Fluttertoast.showToast(msg: '생년월일(6자리)를 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                if( dateController.text.trim().length != 8 ) {
                                  Fluttertoast.showToast(msg: '유효한 생년월일(YY.MM.DD)을 입력해 주세요.', gravity: ToastGravity.CENTER);
                                  return;
                                }

                                try {
                                  _owner_name = nameController.text.trim();
                                  _owner_phone = phoneController.text;
                                  _birth_date =
                                      dateController.text.replaceAll('.', '');

                                  List<Map<String,
                                      dynamic>> result = await supabase.from(
                                      'owner').select().match({
                                    'site_code': _site_code,
                                    'building_no': _building_no,
                                    'house_no': _house_no,
                                    'owner_name': _owner_name,
                                    'owner_phone': _owner_phone,
                                    'birth_date': _birth_date});
                                  if (result.isNotEmpty) {
                                    _type = result[0]['type'].toString();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: '입력하신 정보로 등록된 세대가 없습니다.',
                                        gravity: ToastGravity.CENTER);
                                    return;
                                  }

                                  result =
                                  await supabase.from('users').select().match({
                                    'user_name': _owner_name,
                                    'phone_number': _owner_phone,
                                    'birth_date': _birth_date});
                                  if (result.isNotEmpty) {
                                    await supabase.from('users').update({
                                      'last_login': '${DateFormat(
                                          "yy-MM-dd hh:mm a").format(
                                          DateTime.now())}'
                                    }).match({
                                      'user_name': _owner_name,
                                      'phone_number': _owner_phone,
                                      'birth_date': _birth_date});
                                  } else {
                                    result =
                                    await supabase.from('users').insert({
                                      'user_name': _owner_name,
                                      'phone_number': _owner_phone,
                                      'birth_date': _birth_date,
                                      'last_login': '${DateFormat(
                                          "yy-MM-dd hh:mm a").format(
                                          DateTime.now())}'}).select();
                                  }
                                  _uid = result[0]['id'];

                                  await _databaseService.deletePic1(_uid);
                                  Fluttertoast.showToast(msg: '근접사진 삭제가 완료되었습니다.', gravity: ToastGravity.CENTER);

                                } catch(e) {
                                  print(e.toString());
                                }
                              },
                              child: Text('근접 사진지우기'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
