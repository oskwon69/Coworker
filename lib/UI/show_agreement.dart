import 'package:coworker/UI/requset_page.dart';
import 'package:coworker/UI/show_html.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({Key? key, required this.user}) : super(key: key);
  final user;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isAllChecked = false;
  bool _isAbove14 = false;
  bool _isTermsChecked = false;
  bool _isPrivacyChecked = false;
  final supabase = Supabase.instance.client;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약관 동의'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Gap(20),
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
                              _isAbove14 = value;
                              _isTermsChecked = value!;
                              _isPrivacyChecked = value!;
                            });
                          },
                        ),
                        Text('전체동의'),
                      ]
                  ),
                ]
            ),
            Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isAbove14,
                        onChanged: (value) {
                          setState(() {
                            _isAbove14 = value!;
                          });
                        },
                      ),
                      Text('(필수) 만 14세 이상입니다.'),
                    ]
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
                        value: _isTermsChecked,
                        onChanged: (value) {
                          setState(() {
                            _isTermsChecked = value!;
                          });
                        },
                      ),
                      Text('서비스 이용약관 동의'),
                    ]
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(80, 35),
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: Colors.blue.shade800),
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HTMLPage(file: 'http://www.focusgroup.co.kr/doc/terms.htm',)));
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
                        value: _isPrivacyChecked,
                        onChanged: (value) {
                          setState(() {
                            _isPrivacyChecked = value!;
                          });
                        },
                      ),
                      Text('개인정보 수집/이용 동의'),
                    ]
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(80, 35),
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(color: Colors.blue.shade800),
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HTMLPage(file: 'http://www.focusgroup.co.kr/doc/privacy.html')));
                  },
                  child: Text('전문보기'),
                ),
              ],
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
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text('이전'),
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
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () async {
                      if( _isAbove14 != true || _isTermsChecked != true || _isPrivacyChecked != true ) {
                        Fluttertoast.showToast(msg: '약관에 모두 동의해 주세요.');
                        return;
                      }

                      List<Map<String, dynamic>> result = await supabase.from('users').select().eq('id', widget.user.uid);
                      if (result.isNotEmpty) {
                        await supabase.from('users').update({
                          'last_login': '${DateFormat("yy-MM-dd hh:mm a").format(DateTime.now())}',
                          'terms_agree': 1
                        }).eq('id', widget.user.uid);
                      }
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RequestPage(user: widget.user)));
                    },
                    child: Text('다음'),
                  ),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}
