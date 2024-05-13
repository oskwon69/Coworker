import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:coworker/UI/send_page.dart';
import 'package:coworker/model/user.dart';
import 'package:coworker/UI/login_page.dart';
import 'package:coworker/UI/show_model.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';
import 'card_defect_widget.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key, required this.user}) : super(key: key);

  final UserInfo user;

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  late UserInfo _user;
  List<Defect> defectList = [];
  bool isEditValid = false;

  final supabase = Supabase.instance.client;
  static final storage = FlutterSecureStorage();
  final DefectDatabase _databaseService = DefectDatabase();

  int _sent=0;
  int ownHouseNo = 0;

  getHouse(int site_code, String site_name, String building_no, String house_no, String type)  {
    setState(() {
      _user.site_code = site_code;
      _user.site_name = site_name;
      _user.building_no = building_no;
      _user.house_no = house_no;
    });
  }

  refreshScreen() {
    setState(() { });
  }

  Future<void> checkEditValid() async {
    String? localInfo = '';

    localInfo = await storage.read(key:'isEditValid');
    if (localInfo != null) {
      String value = localInfo;
      if( value == 'valid' )  {
        isEditValid = true;
      } else {
        isEditValid = false;
      }
    }
  }

  Future<List<Defect>> _getDefects() async {
    final defects = await _databaseService.getAllDefects(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!);
    if ( defectList.isNotEmpty )  {
      defectList.clear();
    }
    defectList.addAll(defects);

    _sent = await _databaseService.getSentDefects(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!);

    print('getDefectList');
    return defectList;
  }

  @override
  void initState() {
    super.initState();

    _user = widget.user;
    checkEditValid();
  }

  @override
  Widget build(BuildContext context)  {
    String _houseName = '';
    if( _user.site_name!.length>20)  {
      _houseName = '${_user.site_name!.substring(0,20)} ${_user.building_no}동 ${_user.house_no}호';
    }
    else  {
      _houseName = '${_user.site_name} ${_user.building_no}동 ${_user.house_no}호';
    }

    return Scaffold(
      drawer: NavigationDrawer(user: _user),
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: -5,
        title: ListTile(
          title: Text('${_user.user_name} 님', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          subtitle: Text('입주를 환영합니다!', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            onPressed: () {
              if( isEditValid == false )  {
                Fluttertoast.showToast(msg: '사전점검 기간이 아닙니다.', gravity: ToastGravity.CENTER);
                return;
              }
              //Navigator.push(context, MaterialPageRoute(builder: (context) => SendData(user: _user,function: refreshScreen)));
              showModalBottomSheet(
                isDismissible: false,
                isScrollControlled: true,
                context: context,
                builder: (context) => SendData(user: _user,function: refreshScreen),
              );
            },
            child: Text('전송'),
          ),
          Gap(15),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue.shade700,
          splashColor: Colors.white.withOpacity(0.25),
          onPressed: () {
            if( isEditValid == false )  {
              Fluttertoast.showToast(msg: '사전점검 기간이 아닙니다.', gravity: ToastGravity.CENTER);
              return;
            }
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => AddNewDefectModel(user: _user, function: refreshScreen),
            );
          },
          child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _getDefects(),
        builder: (BuildContext context, AsyncSnapshot<List<Defect>> snapshot) {
          if( snapshot.hasData )  {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('하자 내역', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(_houseName, style: TextStyle(color: Colors.black))
                          ],
                        ),
                      ]
                    ),
                    Gap(5),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(5),
                      width: double.infinity,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text('전체건수'),
                              Gap(5),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.all(Radius.circular(7))),
                                width: 30,
                                child: Text(defectList.length.toString(), style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('전송완료'),
                              Gap(5),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(7))),
                                width: 30,
                                child: Text(_sent.toString(), style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('미전송'),
                              Gap(5),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(7))),
                                width: 30,
                                child: Text((defectList.length-_sent).toString(), style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ]
                      ),
                    ),
                    Gap(5),
                    ListView.builder(
                      itemCount: defectList.length,
                      shrinkWrap: true,
                      primary: false,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Dismissible(
                            key: UniqueKey(),
                            child: CardDefectListWidget(defect: defectList[index], function: refreshScreen),
                            background: Container(color: Colors.grey.shade200),
                            onDismissed: (direction) async {
                                try {
                                  Defect defect = defectList[index];
                                  defect.deleted = 1;
                                  var result = await _databaseService.updateDefect(defect);
                                } catch(e) {
                                  print(e.toString());
                                }
                                setState(() {});
                            },
                            confirmDismiss: (direction)  {
                              if( isEditValid == false )  {
                                Fluttertoast.showToast(msg: '사전점검 기간이 아닙니다.', gravity: ToastGravity.CENTER);
                                return Future.value(false);
                              }
                              return showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('하자 내용을 삭제하시겠습니까?', style: TextStyle(fontSize: 15)),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text("취소", style: TextStyle(fontSize: 15))
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text("삭제", style: TextStyle(fontSize: 15))
                                        ),
                                      ],
                                    );
                                  },
                              );
                            },
                        );
                      }
                    ),
                  ],
                ),
              ),
            );
          }
          else {
            return Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key, required this.user}) : super(key: key);
  final UserInfo user;

  @override
  Widget build(BuildContext context)  => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Container(
    color: Colors.blue.shade700,
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top,),
    child: Column(
      children: [
        CircleAvatar(
          radius: 40,
          child: Icon(CupertinoIcons.house),
        ),
        Gap(10),
        Text('${user.user_name!} 님', style: TextStyle(fontSize: 25, color: Colors.white),),
        Text('${user.site_name!}', style: TextStyle(fontSize: 16, color: Colors.white),),
        Text('${user.building_no!}동 ${user.house_no!}호', style: TextStyle(fontSize: 16, color: Colors.white),),
        Gap(10),
      ],
    ),
  );

  Widget buildMenuItems(BuildContext context) => Container(
    padding: EdgeInsets.all(4),
    child : Wrap(
      runSpacing: 16,
      children: [
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('로그아웃'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('로그아웃 하시겠습니까?', style: TextStyle(fontSize: 15)),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text("취소", style: TextStyle(fontSize: 15))
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                        },
                        child: Text("로그아웃", style: TextStyle(fontSize: 15))
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    )
  );
}