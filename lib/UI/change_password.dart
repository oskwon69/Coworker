import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'app_style.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  var OTPController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordController2 = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    OTPController.dispose();
    passwordController.dispose();
    passwordController2.dispose();
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
                    child: Text('비밀번호 재설정', style: TextStyle(
                        fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                  ),
                  Gap(20),
                  Text(
                    '인증번호',
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
                      keyboardType: TextInputType.number,
                      controller: OTPController,
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '인증번호를 입력해 주세요.',
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
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '새로운 비밀번호를 입력해 주세요.',
                      ),
                      maxLines: 1,
                      obscureText: true,
                    ),
                  ),
                  Gap(6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: passwordController2,
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: '비밀번호를 다시 입력해 주세요.',
                      ),
                      maxLines: 1,
                      obscureText: true,
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
                            if( OTPController.text == '' ) {
                              Fluttertoast.showToast(msg: '인증번호를 입력해 주세요.', gravity: ToastGravity.CENTER);
                              return;
                            }
                            if( checkPasswordValidate() != true )  return;
                            if( passwordController.text != passwordController2.text )  {
                              Fluttertoast.showToast(msg: '재확인 비밀번호가 다릅니다.', gravity: ToastGravity.CENTER);
                              return;
                            }

                            try {
                              final recovery = await supabase.auth.verifyOTP(email: widget.email, token: OTPController.text, type: OtpType.recovery);
                              await supabase.auth.updateUser(UserAttributes(password: passwordController.text));

                              Fluttertoast.showToast(msg: '비밀번호 변경이 완료되었습니다. 로그인 페이지로 이동합니다.');
                              Navigator.pop(context);
                            } catch(e) {
                              Fluttertoast.showToast(msg: '인증번호가 틀리거나 새로운 비밀번호가 기존과 같습니다. 다시 시도해 주세요.');
                              //Fluttertoast.showToast(msg: e.toString());
                              print(e);
                            }
                          },
                          child: Text('비밀번호 변경'),
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
