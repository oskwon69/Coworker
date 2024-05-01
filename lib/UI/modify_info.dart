import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_style.dart';
import 'login_page.dart';


class ModifyInfo extends StatefulWidget  {
  const ModifyInfo({Key? key}) : super(key: key);

  @override
  State<ModifyInfo> createState() => _ModifyInfoState();
}

class _ModifyInfoState extends  State<ModifyInfo>  {
  final _formKey = GlobalKey<FormState>();

  String _user_id = '';
  var userNameController = TextEditingController();
  var birthDateController = TextEditingController();
  var phoneNumberController = TextEditingController();

  bool islogIdCheck= false;

  _getProfile() async {
    final storage = FlutterSecureStorage();
    String? queryInfo = '';

    queryInfo = await storage.read(key: 'profile');

    if (queryInfo != null) {
      _user_id = queryInfo.split(' ')[1];
      userNameController.text = queryInfo.split(' ')[3];
      birthDateController.text = queryInfo.split(' ')[5];
      phoneNumberController.text = queryInfo.split(' ')[7];
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getProfile();
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    birthDateController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text('회원정보 수정', style: TextStyle(
              fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이름', style: AppStyle.headingOne),
                Gap(6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: userNameController,
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '이름을 입력해 주세요.',
                    ),
                    maxLines: 1,
                  ),
                ),
                Gap(10),
                Text(
                  '생년월일',
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
                    controller: birthDateController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MultiMaskedTextInputFormatter(masks: ['xx.xx.xx'], separator: '.'),
                    ],
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '생년월일(6자리)를 입력해 주세요.',

                    ),
                  ),
                ),
                Gap(10),
                Text(
                  '전화번호',
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
                    controller: phoneNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MultiMaskedTextInputFormatter(masks: ['xxx-xxxx-xxxx', 'xxx-xxx-xxxx'], separator: '-'),
                    ],
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '휴대폰번호를 입력해 주세요.',

                    ),
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
                          if( userNameController.text == '') {
                            Fluttertoast.showToast(msg: '이름을 입력해 주세요.');
                            return;
                          }

                          if( birthDateController.text == '') {
                            Fluttertoast.showToast(msg: '생년월일을 입력해 주세요.');
                            return;
                          }
                          if( birthDateController.text.trim().length != 8 ) {
                            Fluttertoast.showToast(msg: '유효한 생년월일(YY.MM.DD)을 입력해 주세요.');
                            return;
                          }

                          if( phoneNumberController.text == '') {
                            Fluttertoast.showToast(msg: '휴대폰 번호를 입력해 주세요.');
                            return;
                          }
                          if( phoneNumberController.text.trim().length < 12 || phoneNumberController.text.trim().length > 13 ) {
                            Fluttertoast.showToast(msg: '유효한 휴대전화 번호를 입력해 주세요.');
                            return;
                          }

                          try {
                            var response = await supabase.from('accounts')
                                .update({
                                  'user_name': userNameController.text,
                                  'birth_date': birthDateController.text,
                                  'phone_number': phoneNumberController.text,
                                })
                                .match({'id': _user_id});

                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('회원정보 수정이 완료되었습니다.\n 로그인 페이지로 이동합니다.', style: TextStyle(fontSize: 15)),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                                        },
                                        child: Text("확인", style: TextStyle(fontSize: 15))
                                    ),
                                  ],
                                );
                              },
                            );
                          } catch(e) {
                            Fluttertoast.showToast(msg: '정보수정시 오류가 발생했습니다. 다시 시도해 주세요.');
                            Fluttertoast.showToast(msg: e.toString());
                            print(e);
                          }
                        },
                        child: Text('정보 수정'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }
}