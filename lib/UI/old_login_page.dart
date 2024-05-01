import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

import 'package:coworker/UI/signup_page.dart';
import 'package:coworker/UI/requset_page.dart';
import '../database/env_database.dart';
import '../model/env.dart';
import '../model/user.dart';
import 'app_style.dart';
import 'email_confirm.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final supabase = Supabase.instance.client;
  static final storage = FlutterSecureStorage();
  //List<dynamic> dataList = [];
  late UserInfo _user;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoginInfo();
    });
  }

  getLoginInfo() async {
    String? userInfo = '';

    userInfo = await storage.read(key:'login');

    if (userInfo != null) {
      emailController.text = userInfo.split(' ')[1];
      passwordController.text = userInfo.split(' ')[3];
    }
  }

  copyLocalDatabase(ProgressDialog pd) async {
    int ownHouseNo = 0;

    List<dynamic> dataList = [];
    final EnvDatabase _envdatabase = EnvDatabase();

    await _envdatabase.deleteAllSite();
    await _envdatabase.deleteAllHouse();
    await _envdatabase.deleteAllSpace();
    await _envdatabase.deleteAllArea();
    await _envdatabase.deleteAllWork();

    var sites = await supabase.from('site').select();
    if (sites.isNotEmpty) {
      dataList = sites.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addSite(Site.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    pd.update(value:30);

    print('site info ok!');

    int _site_code = 0;
    String _site_name = '';
    String _building_no = '';
    String _house_no = '';
    String _type = '';

    int _site_code_local = 0;
    String _site_name_local = '';
    String _building_no_local = '';
    String _house_no_local = '';
    String _type_local = '';

    var queryInfo = await storage.read(key: 'selectedHouse');
    if (queryInfo != null) {
      _site_code_local = int.parse(queryInfo.split(',')[1]);
      _site_name_local = queryInfo.split(',')[3];
      _building_no_local = queryInfo.split(',')[5];
      _house_no_local = queryInfo.split(',')[7];
      _type_local = queryInfo.split(',')[9];
    }

    var houses = await supabase.from('house').select().match({
      'owner_name': _user.user_name,
      'owner_phone': _user.user_phone,
      'birth_date': _user.birth_date
    });
    print('house query ok!');
    pd.update(value:40);

    if (houses.isNotEmpty) {
      dataList = houses.toList();
      bool isMatched = false;
      for (int i = 0; i < dataList.length; i++) {
        var response = await supabase.from('site').select().match({'site_code': dataList[i]['site_code'], 'status': 1});
        if (response.isNotEmpty) {
          dataList[i]['site_name'] = response[0]['site_name'];
          await _envdatabase.addHouse(House.fromMap(dataList[i]));
          ownHouseNo++;

          _site_code = dataList[i]['site_code'];
          _site_name = dataList[i]['site_name'];
          _building_no = dataList[i]['building_no'];
          _house_no = dataList[i]['house_no'];
          _type = dataList[i]['type'];

          if (dataList[i]['site_code'] == _site_code_local &&
              dataList[i]['building_no'] == _building_no_local &&
              dataList[i]['house_no'] == _house_no_local) {
            isMatched = true;
          }
        }
      }
      if( isMatched == true ) {
        _site_code = _site_code_local;
        _site_name = _site_name_local;
        _building_no = _building_no_local;
        _house_no = _house_no_local;
        _type = _type_local;
      }
      dataList.clear();
    }
    print('house search ok!');

    _user.site_code = _site_code;
    _user.site_name = _site_name;
    _user.building_no = _building_no;
    _user.house_no = _house_no;
    _user.type = _type;
    print('house info ok!');

    pd.update(value:60);


    var spaces = await supabase.from('space').select().match({'site_code': _site_code});
    if (spaces.isNotEmpty) {
      dataList = spaces.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addSpace(Space.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    print('space info ok!');
    pd.update(value:70);

    var areas = await supabase.from('area').select().match({'site_code': _site_code});
    if (areas.isNotEmpty) {
      dataList = areas.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addArea(Area.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    print('area info ok!');
    pd.update(value:80);

    var works = await supabase.from('work').select().match({'site_code': _site_code});
    if (works.isNotEmpty) {
      dataList = works.toList();
      for (int i = 0; i < dataList.length; i++) {
        await _envdatabase.addWork(Work.fromMap(dataList[i]));
      }
      dataList.clear();
    }
    print('work info ok!');
    pd.update(value:90);

    setState(() { });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool checkPasswordValidate() {
    Pattern pattern = r'^(?=.*[a-zA-z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,15}$';

    if( passwordController.text == '' )  {
      Fluttertoast.showToast(msg: '비밀번호를 입력해 주세요.');
      return false;
    }

    RegExp regExp = RegExp(pattern.toString());
    if(!regExp.hasMatch(passwordController.text))   {
      Fluttertoast.showToast(msg: '비밀번호는 특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력해 주세요.');
      return false;
    }

    return true;
  }

  bool checkEmailValidate() {
    Pattern pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

    RegExp regExp = RegExp(pattern.toString());
    if( emailController.text == '')   {
      Fluttertoast.showToast(msg: '이메일을 입력해 주세요.');
      return false;
    }
    if(!regExp.hasMatch(emailController.text))   {
      Fluttertoast.showToast(msg: '이메일 형식(user@xxx.xx)으로 입력해 주세요.');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text('', style: TextStyle(
            fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Container(
          child:
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text('로그인', style: TextStyle(
                        fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Gap(20),
                  Text(
                    '이메일',
                    style: AppStyle.headingOne,
                  ),
                  Gap(6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '이메일 주소를 입력해 주세요.',
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Gap(20),
                  Text(
                    '비밀번호',
                    style: AppStyle.headingOne,
                  ),
                  Gap(6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '비밀번호를 입력해 주세요.',

                      ),
                      maxLines: 1,
                      obscureText: true,
                    ),
                  ),
                  Gap(10),
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmailConfirm()));
                      },
                      child: Text('비밀번호를 잊어버리셨나요?'),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(color: Colors.blue.shade800),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            if( checkEmailValidate() != true ) return;
                            if( checkPasswordValidate() != true ) return;

                            try {
                              ProgressDialog pd = ProgressDialog(context: context);
                              pd.show(max: 100, msg: '서버로 부터 데이터를 받고 있습니다...');

                              final email = emailController.text;
                              final password = passwordController.text;
                              await supabase.auth.signInWithPassword(email: email,password: password);
                              print('Login successfully!');
                              await storage.write(key: "login", value: "email " + emailController.text + " " + "password " + passwordController.text);
                              print('Save Login Information');
                              pd.update(value: 10);

                              var response = await supabase.from('accounts').select().match({'email':email});
                              if( response.isNotEmpty ) {
                                _user = UserInfo(uid: response[0]['id'], user_name: response[0]['user_name'], birth_date: response[0]['birth_date'], user_phone: response[0]['phone_number']);
                                await storage.write(
                                    key: "profile",
                                    value: "id ${_user.uid} user_name ${_user.user_name} birth_date ${_user.birth_date} phone_number ${_user.user_phone}"
                                );
                                print('Load User Profiles');
                                pd.update(value: 20);

                                await copyLocalDatabase(pd);
                                print('Establish Local DB');
                                pd.update(value: 100);
                                pd.close();

                                print(_user.toString());
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RequestPage(user: _user)));
                              }
                            } catch (e) {
                              Fluttertoast.showToast(msg: '로그인에 실패했습니다. 이메일과 비밀번호를 다시 확인해 주세요.');
                              print(e.toString());
                            }
                          },
                          child: Text('로그인'),
                        ),
                      ),
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                          },
                          child: Text('회원가입'),
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
    );
  }
}
