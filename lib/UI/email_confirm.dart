import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'app_style.dart';
import 'change_password.dart';

class EmailConfirm extends StatefulWidget {
  const EmailConfirm({Key? key}) : super(key: key);

  @override
  State<EmailConfirm> createState() => _EmailConfirmState();
}

class _EmailConfirmState extends State<EmailConfirm> {
  final _formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
                    child: Text('비밀번호 재설정', style: TextStyle(
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

                            try {
                              final email = emailController.text;
                              await supabase.auth.resetPasswordForEmail(emailController.text);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChangePassword(email: emailController.text)));
                              Fluttertoast.showToast(msg: '입력하신 이메일 주소로 인증번호가 전송되었습니다.', gravity: ToastGravity.CENTER);
                            } catch(e) {
                              Fluttertoast.showToast(msg: '입력하신 이메일 주소가 등록되어 있지 않습니다.', gravity: ToastGravity.CENTER);
                              print(e.toString());
                            }
                          },
                          child: Text('인증번호 이메일 전송'),
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
