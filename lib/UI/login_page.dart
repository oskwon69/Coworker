import 'dart:async';
import 'dart:io';
import 'package:coworker/UI/dropdown_widget.dart';
import 'package:coworker/UI/requset_page.dart';
import 'package:coworker/UI/send_page.dart';
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

import '../database/env_database.dart';
import '../model/env.dart';
import '../model/user.dart';
import 'app_style.dart';
import '../API/globals.dart' as globals;

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

  static final storage = FlutterSecureStorage();
  late StreamSubscription<List<ConnectivityResult>> subscriptionComm;
  bool isMobile = false;
  bool isWifi = false;
  bool isEthernet = false;
  late UserInfo _user;

  bool manager_mode = false;

  Future<String?> getDeviceUniqueId() async {
    String? uniqueDeviceId;

    if (Platform.isIOS) {
      var deviceInfo = DeviceInfoPlugin();
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      uniqueDeviceId = iosDeviceInfo.identifierForVendor!;
    } else if(Platform.isAndroid) {
      const androidId = AndroidId();
      uniqueDeviceId = await androidId.getId();
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

    _did = await getDeviceUniqueId();
    print('did'+_did.toString());

    Directory fileDir = await getApplicationDocumentsDirectory();
    globals.appDirectory = fileDir.path;
    print('appDirectory:${globals.appDirectory}');

    try {
      String remoteDir = '';
      String fileName = _type + ".jpg";
      var result = await supabase.from('site').select().eq('site_code',_site_code);
      if( result.isNotEmpty )  {
        remoteDir = result[0]['image_folder'].toString();
        globals.initAllow = result[0]['initallow'];
      }  else return;

      String _url = remoteDir + "/" + fileName;
      final http.Response response = await http.get(Uri.parse(_url));
      String filePath = fileDir.path + '/' + fileName;
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await storage.write(key: "typeImage", value: "path " + filePath + " " + "type " + _type);
    } catch(e)  {
      print(e.toString());
    }

    pd.update(value: 90);

    try {
      var result = await supabase.from('site').select().eq('site_code',_site_code);
      if( result.isNotEmpty )  {
        DateTime startDate = DateTime.parse(result[0]['check_startdate'].toString());
        DateTime endDate = DateTime.parse(result[0]['check_enddate'].toString());
        DateTime today = DateTime.now();

        if( today.compareTo(startDate) >= 0 && today.compareTo(endDate) <= 0 )  {
          globals.isEditValid = 1;
        }  else {
          globals.isEditValid = 0;
        }
      }

    } catch(e)  {
      print(e.toString());
    }

    pd.update(value: 100);
  }

  Future<void> defaultSite() async {
    var result = await supabase.from('site').select().eq('status',1);
    if( result.isNotEmpty )  {
      _site_code = int.parse(result[0]['site_code'].toString());
      _site_name = result[0]['site_name'].toString();
      _building_no = '동 선택';
      _siteKey.currentState?.refreshList();
      await _buildingKey.currentState?.refreshList(_site_code);
      await _houseKey.currentState?.refreshList(_site_code, _building_no);
    }  else return;

    setState(() { });
  }

  Future<void> changeSite(int site, String name) async {
    _site_code = site;
    _site_name = name;
    _building_no = '동 선택';
    await _buildingKey.currentState?.refreshList(_site_code);
    await _houseKey.currentState?.refreshList(_site_code, _building_no);
    setState(() { });
  }

  Future<void> changeBuilding(String building) async {
    _building_no = building;
    await _houseKey.currentState?.refreshList(_site_code, _building_no);
    setState(() { });
  }

  Future<void> changeHouse(String house) async {
    _house_no = house;
    setState(() { });
  }

  Future<bool> checkCurrentCommState() async {
    isMobile = false;
    isWifi = false;
    isEthernet = false;

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      isMobile = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      isWifi = true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      isEthernet = true;
    }

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

  Future<bool> checkLoginStatus(bool manager_mode) async {
    var commStatus = await checkCurrentCommState();
    if (commStatus == false) return false;

    if( _site_code >= 999 )  {
      Fluttertoast.showToast(msg: '단지를 선택해 주세요.', gravity: ToastGravity.CENTER);
      return false;
    }
    if( _building_no == "동 선택" )  {
      Fluttertoast.showToast(msg: '동을 선택해 주세요.', gravity: ToastGravity.CENTER);
      return false;
    }
    if( _house_no == "호 선택" )  {
      Fluttertoast.showToast(msg: '호를 선택해 주세요.', gravity: ToastGravity.CENTER);
      return false;
    }

    if( manager_mode == false ) {
      if (nameController.text == '') {
        Fluttertoast.showToast(msg: '이름을 입력해 주세요.', gravity: ToastGravity.CENTER);
        return false;
      }

      if (phoneController.text == '') {
        Fluttertoast.showToast(msg: '휴대전화번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
        return false;
      }

      if (phoneController.text.trim().length < 12 || phoneController.text.trim().length > 13) {
        Fluttertoast.showToast(msg: '유효한 휴대전화 번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
        return false;
      }

      if (dateController.text == '') {
        Fluttertoast.showToast(msg: '생년월일(6자리)를 입력해 주세요.', gravity: ToastGravity.CENTER);
        return false;
      }

      if (dateController.text.trim().length != 8) {
        Fluttertoast.showToast(msg: '유효한 생년월일(YY.MM.DD)을 입력해 주세요.', gravity: ToastGravity.CENTER);
        return false;
      }
    }

    try {
      if(manager_mode == false ) {
        _owner_name = nameController.text.trim();
        _owner_phone = phoneController.text;
        _birth_date = dateController.text.replaceAll('.', '');
      } else {
        List<Map<String, dynamic>> result = await supabase.from('owner').select().match({
          'site_code': _site_code,
          'building_no': _building_no,
          'house_no': _house_no});
        if (result.isNotEmpty) {
          _owner_name = result[0]['owner_name'].toString();
          _owner_phone = result[0]['owner_phone'].toString();
          _birth_date = result[0]['birth_date'].toString().replaceAll('.', '');
        }
      }

      print({
        'site_code': _site_code,
        'building_no': _building_no,
        'house_no': _house_no,
        'owner_name': _owner_name,
        'owner_phone': _owner_phone,
        'birth_date': _birth_date});

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
        return false;
      }
    } catch (e) {
      print(e.toString());
    }

    return true;
  }

  Future<void> getLastLoginInfo() async {
    await Future.delayed(Duration.zero);

    String? localInfo = '';

    localInfo = await storage.read(key:'loginInfo');
    if (localInfo != null) {
      _site_code = int.parse(localInfo.split(' ')[1]);
      _site_name = localInfo.split(' ')[3].replaceAll('_', ' ');
      _building_no = localInfo.split(' ')[5];
      _house_no = localInfo.split(' ')[7];
      nameController.text = localInfo.split(' ')[9];
      phoneController.text = localInfo.split(' ')[11];
      dateController.text = localInfo.split(' ')[13];

      _siteKey.currentState?.setList(_site_code);
      await _buildingKey.currentState?.refreshList(_site_code);
      _buildingKey.currentState?.setList(_building_no);

      await _houseKey.currentState?.refreshList(_site_code, _building_no);
      _houseKey.currentState?.setList(_house_no);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () => getLastLoginInfo());
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
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
                      Gap(20),
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
                                if( await checkLoginStatus(manager_mode) == false )  return;

                                ProgressDialog pd = ProgressDialog(context: context);
                                pd.show(max: 100, msg: '데이터 다운로드 중 ...');

                                try {
                                  var result = await supabase.from('users').select().match({
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

                                  await storage.write(key: "loginInfo", value: "site_code "+_site_code.toString()+" site_name "+_site_name.replaceAll(" ","_")+" building_no "+_building_no+" house_no "+_house_no+
                                      " owner_name "+_owner_name+" owner_phone "+_owner_phone+" birth_date "+_birth_date.substring(0,2)+"."+_birth_date.substring(2,4)+"."+_birth_date.substring(4,6));

                                  result = await supabase.from('users').select().eq('id', _user.uid!);
                                  if( result.isNotEmpty )  {
                                    if( result[0]['terms_agree'] == 0 && manager_mode == false )  {  // 아직 동의하지 않음.
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade800,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () async {
                              await checkLoginStatus(true);

                              var result = await supabase.from('users').select().match({
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
                              _did = await getDeviceUniqueId();

                              _user = UserInfo(uid: _uid, did: _did, site_code: _site_code, site_name: _site_name, building_no: _building_no, house_no: _house_no, user_name: _owner_name, birth_date: _birth_date, user_phone: _owner_phone, type: _type);
                              print(_user);

                              await showDialog<String>(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) =>
                                    AlertDialog(
                                      title: Text('알림'),
                                      content: Text('저장된 데이터를 서버로 전송하시겠습니까?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('닫기'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);

                                            showModalBottomSheet(
                                              isDismissible: false,
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) => SendData(user: _user, function: null),
                                            );
                                          },
                                          child: Text('전송'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            child: Text('백업 전송하기'),
                          )
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
