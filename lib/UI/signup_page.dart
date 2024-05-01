import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_style.dart';


class SignUpPage extends StatefulWidget  {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPagePageState();
}

class _SignUpPagePageState extends  State<SignUpPage>  {
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordController2 = TextEditingController();
  var userNameController = TextEditingController();
  var birthDateController = TextEditingController();
  var phoneNumberController = TextEditingController();

  bool _isAllChecked = false;
  bool _isTermsChecked = false;
  bool _isInfoChecked = false;

  bool checkPasswordValidate() {
    Pattern pattern = r'^(?=.*[a-zA-z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,15}$';

    if( passwordController.text == '' )  {
      Fluttertoast.showToast(msg: '비밀번호를 입력해 주세요.');
      return false;
    }

    if( passwordController2.text == '' )  {
      Fluttertoast.showToast(msg: '비밀번호를 다시 입력해 주세요.');
      return false;
    }

    if( passwordController.text != passwordController2.text ) {
      Fluttertoast.showToast(msg: '재확인 비밀번호가 틀립니다. 다시 확인바랍니다.');
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

  void showMessage(String? title, String? content)  {
    showDialog<String> (
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title!),
        content: Text(content!),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordController2.dispose();
    birthDateController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text('회원가입', style: TextStyle(
              fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          child: Form(
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
                  Text('이메일', style: AppStyle.headingOne),
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
                    ),
                  ),
                  Gap(10),
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
                      obscureText: true,
                    ),
                  ),
                  Gap(10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: passwordController2,
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '비밀번호를 다시 입력해 주세요.',

                      ),
                      obscureText: true,
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
                  Gap(10),
                  Text(
                    '약관동의',
                    style: AppStyle.headingOne,
                  ),
                  Gap(6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _isAllChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        _isAllChecked = value!;
                                        _isTermsChecked = value!;
                                        _isInfoChecked = value!;
                                      });
                                    },
                                  ),
                                  Text('전체동의'),
                                ]
                            ),
                          ]
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                value: _isTermsChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      _isTermsChecked = value!;
                                    });
                                  },
                                ),
                                Text('서비스 이용약관'),
                              ]
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(70, 20),
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                side: BorderSide(color: Colors.blue.shade800),
                                padding: EdgeInsets.symmetric(vertical: 5),
                              ),
                              onPressed: () {
                              },
                              child: Text('전문보기'),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _isInfoChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        _isInfoChecked = value!;
                                      });
                                    },
                                  ),
                                  Text('개인정보 수집/이용'),
                                ]
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(70, 20),
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                side: BorderSide(color: Colors.blue.shade800),
                                padding: EdgeInsets.symmetric(vertical: 5),
                              ),
                              onPressed: () {
                              },
                              child: Text('전문보기'),
                            ),
                          ],
                        )
                      ],
                    )
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

                            if( checkEmailValidate() != true ) return;
                            if( checkPasswordValidate() != true ) return;

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

                            if( _isTermsChecked != true || _isInfoChecked != true ) {
                              Fluttertoast.showToast(msg: '약관에 모두 동의해 주세요.');
                              return;
                            }

                            try {
                              final AuthResponse res = await supabase.auth.signUp(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  data: {
                                    'user_name': userNameController.text,
                                    'birth_date': birthDateController.text,
                                    'phone_number': phoneNumberController.text
                                  }
                              );

                              Fluttertoast.showToast(msg: '회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.');
                              Navigator.pop(context);
                            } catch(e) {
                              Fluttertoast.showToast(msg: '회원가입시 오류가 발생했습니다. 다시 시도해 주세요.');
                              //Fluttertoast.showToast(msg: e.toString());
                              print(e);
                            }
                          },
                          child: Text('회원가입'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        )
      )
    );
  }
}