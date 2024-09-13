import 'dart:io';

import 'package:coworker/UI/show_defects_sent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:coworker/UI/send_page.dart';
import 'package:coworker/model/user.dart';
import 'package:coworker/UI/login_page.dart';
import 'package:coworker/UI/show_model.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_database.dart';
import 'package:coworker/UI/card_defect_widget.dart';
import 'package:coworker/API/globals.dart' as globals;


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
  int maxDefects = 300;

  final supabase = Supabase.instance.client;
  static final storage = FlutterSecureStorage();
  final DefectDatabase _databaseService = DefectDatabase();

  static const _pageSize = 20;
  final PagingController<int, Defect> _pagingController = PagingController(firstPageKey: 0);

  int _total=0;
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
    setState(() {
      _pagingController.refresh();
    });
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

  Future<int> _getDefectsCount() async {
    _total = await _databaseService.getTotalDefectsCount(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!);
    _sent = await _databaseService.getSentDefectsCount(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!);
    return 0;
  }

/*
  Future<List<Defect>> _getDefects() async {
    try {
      final defects = await _databaseService.getAllDefects(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!);
      if (defectList.isNotEmpty) {
        defectList.clear();
      }
      defectList.addAll(defects);

      _sent = await _databaseService.getSentDefects(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!);
    } catch(e) {
      print(e.toString());
    }
    return defectList;
  }
*/

  Future<void> deleteAllDefect() async {
    try {
      final defects = await _databaseService.getAllDefects(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!);
      if (defectList.isNotEmpty) {
        defectList.clear();
      }
      defectList.addAll(defects);
    } catch(e) {
      print(e.toString());
    }

    try {
      for(int i=0;i<defectList.length;i++) {
        if (defectList[i].pic1 != '') {
          var file = File(defectList[i].pic1);
          file.delete();
        }

        await _databaseService.deleteDefect(defectList[i].id!);
      }
    } catch(e)  {
      print(e.toString());
    }

    setState(() {
      _pagingController.refresh();
    });
  }

  @override
  void initState() {
    super.initState();

    _user = widget.user;
    checkEditValid();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _databaseService.getAllDefectsByPage(_user.uid!, _user.site_code!, _user.building_no!, _user.house_no!, pageKey, _pageSize);
      //final newItems = await _databaseService.getAllDefects(3, '207', '201', pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
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
      drawer: NavigationDrawer(user: _user, initFunction: deleteAllDefect),
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
              showModalBottomSheet(
                isDismissible: false,
                isScrollControlled: true,
                context: context,
                builder: (context) => SendData(user: _user, function: refreshScreen),
              );
            },
            child: Text('전송'),
          ),
/*
          Gap(5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            onPressed: () async {
              String _building_no = _user.building_no!;
              String _house_no = _user.house_no!;
              String _pic1 = '';

              try {
                _pic1 = '/storage/emulated/0/Pictures/101_101_2024-06-03 11_07_31.331632_pic1.jpg';
                if (_pic1 != '') {
                  String fileName = "${_building_no}_${_house_no}_${DateTime
                      .now()}_pic1.jpg";
                  String filePath = "${globals.appDirectory}/$fileName";
                  File file = File(filePath);
                  Uint8List imageBytes = await File(_pic1).readAsBytesSync();
                  file.writeAsBytes(imageBytes);
                  _pic1 = fileName;
                }
              } catch(e) {
                print(e.toString());
              }

              Defect defect = Defect(uid: _user.uid!,
                  did: _user.did!,
                  site: _user.site_code!,
                  building: _user.building_no!,
                  house: _user.house_no!,
                  reg_name: _user.user_name!,
                  reg_phone: _user.user_phone!,
                  space: '실명이름',
                  area: '부위이름',
                  work: '공종이름',
                  sort: '유형이름',
                  claim: '하자가 없어야 하는데 많이 있네요. ^^',
                  pic1: _pic1,
                  pic2: "",
                  synced: 0,
                  deleted: 0,
                  sent: '미전송');

              var result = await _databaseService.addDefect(defect);
              setState(() {
                _pagingController.refresh();
              });
            },
            child: Text('DB테스트'),
          ),
*/
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

            if( _total >= maxDefects )  {
              Fluttertoast.showToast(msg: '최대 저장 갯수($maxDefects건)를 초과하였습니다.', gravity: ToastGravity.CENTER);
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
      body: Padding(
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
              child: FutureBuilder(
                  future: _getDefectsCount(),
                  builder: (context, snapshot) {
                    if ( snapshot.hasData ) {
                      return Row(
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
                                  child: Text(_total.toString(), style: TextStyle(color: Colors.white)),
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
                                  child: Text((_total-_sent).toString(), style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ]
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  }
              ),
            ),
            Gap(5),
            Expanded(
              child: PagedListView<int, Defect>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Defect>(
                  itemBuilder: (context, item, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      child: CardDefectListWidget(defect: item, function: refreshScreen),
                      background: Container(color: Colors.grey.shade200),
                      onDismissed: (direction) async {
                        try {
                          Defect defect = item;
                          defect.deleted = 1;
                          await _databaseService.updateDefect(defect);
                        } catch(e) {
                          print(e.toString());
                        }
                        setState(() {
                          _pagingController.refresh();
                        });
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
                  },
                  firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('하자정보를 가져오는 주 에러가 발생했습니다!'),),
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('작성된 하자 내용이 없습니다.'),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key, required this.user, required this.initFunction}) : super(key: key);
  final UserInfo user;
  final Function initFunction;

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
          leading: Icon(CupertinoIcons.arrow_right_arrow_left),
          title: Text('접수현황'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShowDefectsSent(user:user)));
          },
        ),
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
        ListTile(
          leading: Icon(CupertinoIcons.trash),
          title: Text('초기화'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('초기화는 모든 데이터를 삭제하는 기능입니다. 초기화시 복구가 불가능합니다.', style: TextStyle(fontSize: 15)),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text("취소", style: TextStyle(fontSize: 15))
                    ),
                    TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('[경고!!!] 다시한번 확인합니다. 초기화는 최대저장 한도를 넘는 경우에만 사용하는 기능입니다. 따라서, 초기화시 복구가 불가능하므로 신중한 결정바랍니다.', style: TextStyle(fontSize: 15)),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text("취소", style: TextStyle(fontSize: 15))
                                  ),
                                  TextButton(
                                      onPressed: () async {
                                        await initFunction();

                                        Navigator.of(context).pop(false);
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text("초기화 확인", style: TextStyle(fontSize: 15))
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text("초기화", style: TextStyle(fontSize: 15))
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